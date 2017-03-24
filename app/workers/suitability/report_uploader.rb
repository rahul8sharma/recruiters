module Suitability
  class ReportUploader < ::ReportUploader
    helper Suitability::ReportsHelper

    def perform(report_data, auth_token, patch = {})
      tries = 0
      patch ||= {}
      report_data = HashWithIndifferentAccess.new report_data
      report_id = report_data["id"]
      company_id = report_data["company_id"]
      assessment_id = report_data["assessment_id"]
      user_id = report_data["user_id"]
      patch ||= {}
      begin
        RequestStore.store[:auth_token] = get_token({ auth_token: auth_token }).token
        puts "Getting Report #{report_id}"
        methods = []
        methods = [:report_hash] if !patch.empty?
        @report = Vger::Resources::Suitability::Assessments::UserAssessmentReport.find(report_id,
          :custom_assessment_id => assessment_id,
          :user_id => user_id,
          :company_id => company_id,
          :patch => patch,
          :methods => methods
        )
        
        @report.report_hash = @report.report_data if patch.empty?
        #if @report.status == Vger::Resources::Suitability::UserAssessmentReport::Status::UPLOADING
        #  puts "Report #{report_id} is being uploaded already..."
        #  return
        #end

        Vger::Resources::Suitability::Assessments::UserAssessmentReport.save_existing(report_id,
          :custom_assessment_id => assessment_id,
          :user_id => user_id,
          :company_id => company_id,
          :status => Vger::Resources::Suitability::Assessments::UserAssessmentReport::Status::UPLOADING
        )


        @norm_buckets = Vger::Resources::Suitability::NormBucket.where(order: "weight ASC").all

        @company_norm_buckets = Vger::Resources::Suitability::CompanyNormBucket\
                            .where(query_options: {
                              company_id: company_id
                            })\
                            .where(order: "weight ASC").all
        
        if @company_norm_buckets.empty?
          @company_norm_buckets = Vger::Resources::Suitability::CompanyNormBucket\
                            .where(query_options: {
                              company_id: nil
                            })\
                            .where(order: "weight ASC").all                    
        end      

        user_name = @report.report_hash[:user][:name]
        company_name = @report.report_hash[:company][:name]

        template = if @report.configuration[:is_functional_assessment]
          "functional_report"
        else
          @report.report_hash[:assessment][:assessment_type]+"_report"
        end
        
        report_status = {
          :errors => [],
          :message => "",
          :status => "success"
        }

        @view_mode = "html"
        html = render_to_string(
           template: "assessment_reports/#{template}",
           layout: "layouts/user_reports",
           formats: [ :html ]
        )

        @view_mode = "feedback"
        feedback_html = render_to_string(
           template: "assessment_reports/feedback_report",
           layout: "layouts/feedback_reports",
           formats: [ :html ]
        )

        hash_toc = {
          margin: { :left => "0mm",:right => "0mm", :top => "13mm", :bottom => "12mm" },
          footer: {
            :content => render_to_string(
              "shared/reports/pdf/_report_footer",
              layout: "layouts/user_reports",
              formats: [:pdf]
            )
          },
          zoom: 1.5,
          disable_smart_shrinking: false,
          header: {
            :content => render_to_string(
              "shared/reports/pdf/_report_header",
              layout: "layouts/user_reports",
              formats: [:pdf]
            ),
            :spacing => 15
          }
        }

        if @report.report_hash[:enable_table_of_contents]
          hash_toc.merge!({
            cover: report_cover_url().gsub("http://", ''),
            toc: {}
          })
        end

        @view_mode = "pdf"
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string("assessment_reports/#{template}",
            layout: "layouts/user_reports",
            formats: [:pdf]
          ), hash_toc
        )

        FileUtils.mkdir_p(Rails.root.join("tmp"))
        file_id = "#{safe_name(user_name)}-#{safe_name(company_name)}-#{@report.id}"
        pdf_file_id = "#{file_id}.pdf"
        html_file_id = "#{file_id}.html"
        feedback_html_file_id = "feedback-#{file_id}.html"
        pdf_save_path = File.join(Rails.root.to_s,'tmp',"#{pdf_file_id}")
        html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")
        feedback_html_save_path = File.join(Rails.root.to_s,'tmp',"feedback_#{html_file_id}")

        File.open(html_save_path, 'wb') do |file|
          file << html
        end
        File.open(feedback_html_save_path, 'wb') do |file|
          file << feedback_html
        end
        File.open(pdf_save_path, 'wb') do |file|
          file << pdf
        end
        pdf_s3 = upload_file_to_s3("suitability_reports/pdf/#{pdf_file_id}",pdf_save_path)
        html_s3 = upload_file_to_s3("suitability_reports/html/#{html_file_id}",html_save_path)
        feedback_html_s3 = upload_file_to_s3("suitability_reports/feedback/#{feedback_html_file_id}",feedback_html_save_path)

        should_send_notifications = (patch["send_report"] == "Yes" || @report.configuration[:should_send_notifications])
        
        now = Time.now.strftime("%d_%m_%Y_%H_%M")
        notifications_sent_at = (should_send_notifications ? now : @report.configuration[:notifications_sent_at])
        status = nil
        if notifications_sent_at
          status = Vger::Resources::Suitability::Assessments::UserAssessmentReport::Status::UPLOADED
        else
          status = Vger::Resources::Suitability::Assessments::UserAssessmentReport::Status::HIVE_SCORES_PENDING
        end
        Vger::Resources::Suitability::Assessments::UserAssessmentReport.save_existing(report_id,
          :custom_assessment_id => assessment_id,
          :user_id => user_id,
          :company_id => company_id,
          :notifications_sent_at => notifications_sent_at,
          :uploaded_at => now,
          :s3_keys => { :pdf => pdf_s3, :html => html_s3, :feedback => feedback_html_s3 },
          :status => status
        )
        File.delete(pdf_save_path)
        File.delete(html_save_path)
        File.delete(feedback_html_save_path)
        
        mailer_data = {
          report_id: @report.report_hash[:id],
          user: @report.report_hash[:user],
          company: @report.report_hash[:company],
          assessment: @report.report_hash[:assessment],
          report_email_recipients: @report.report_hash[:report_email_recipients],
          report_receiver: @report.report_hash[:report_receiver]
        }
        
        if should_send_notifications
          #Execute this line Unless report_notify is set to false
          puts "Regenerated at - #{@report.configuration[:regenerated_at]}"
          puts "Regenerate Notify - #{@report.configuration[:regenerate_notify]}"
          unless @report.configuration[:regenerated_at] && !@report.configuration[:regenerate_notify]
            # if report_email_recipients is same as user email
            # use send_report_to_user template
            # else use send_report template
            puts "Sending Report"
            report_email_recipients = @report.report_hash[:report_email_recipients].to_s.split(',')
            if report_email_recipients.include? @report.report_hash[:user][:email]
              JombayNotify::Email.create_from_mail(SystemMailer.send_report_to_user(mailer_data), "send_report_to_user")
            end  
            JombayNotify::Email.create_from_mail(SystemMailer.send_report(mailer_data), "send_report")
            if @report.report_hash[:report_receiver] && @report.report_hash[:report_receiver][:email].present? && @report.report_hash[:send_report_links_to_manager]
              JombayNotify::Email.create_from_mail(SystemMailer.send_report_to_manager(mailer_data), "send_report_to_manager")
            end
          end
        end
      rescue Exception => e
        Rails.logger.debug e.message
        puts e.message
        tries = tries + 1
        if tries < 5
          retry
        else
          Vger::Resources::Suitability::Assessments::UserAssessmentReport.save_existing(report_id,
            :custom_assessment_id => assessment_id,
            :user_id => user_id,
            :company_id => company_id,
            :status => Vger::Resources::Suitability::Assessments::UserAssessmentReport::Status::FAILED
          ) rescue nil
        end
        JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("Report Uploader","Failed to upload report #{report_id}",{
          :report => {
            :status => "Failed",
            :company_id => company_id,
            :custom_assessment_id => assessment_id,
            :user_id => user_id,
            :report_id => report_id
          },
          :errors => {
            :backtrace => [e.message] + e.backtrace[0..20]
          }
        }), "notify_report_status")
      end
    end
    
    def safe_name(name)
      name.underscore.gsub('/','-').gsub(' ','-').gsub('_','-')
    end
  end
end  
