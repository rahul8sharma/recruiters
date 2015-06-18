module Suitability
  class ReportUploader < AbstractController::Base
    include Sidekiq::Worker

    include AbstractController::Rendering
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths
    include Rails.application.routes.url_helpers
    include UploadHelper
    helper ApplicationHelper
    helper ReportsHelper
    helper_method :protect_against_forgery?
    self.view_paths = "app/views"

    def protect_against_forgery?
      false
    end

    def perform(report_data, auth_token, patch = {})
      tries = 0
      patch ||= {}
      report_data = HashWithIndifferentAccess.new report_data
      RequestStore.store[:auth_token] = auth_token
      report_id = report_data["id"]
      company_id = report_data["company_id"]
      assessment_id = report_data["assessment_id"]
      candidate_id = report_data["candidate_id"]
      patch ||= {}
      begin
        puts "Getting Report #{report_id}"
        methods = []
        methods = [:report_hash] if !patch.empty?
        @report = Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.find(report_id,
          :custom_assessment_id => assessment_id,
          :candidate_id => candidate_id,
          :company_id => company_id,
          :patch => patch,
          :methods => methods
        )
        
        @report.report_hash = @report.report_data if patch.empty?
        #if @report.status == Vger::Resources::Suitability::CandidateAssessmentReport::Status::UPLOADING
        #  puts "Report #{report_id} is being uploaded already..."
        #  return
        #end

        Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.save_existing(report_id,
          :custom_assessment_id => assessment_id,
          :candidate_id => candidate_id,
          :company_id => company_id,
          :status => Vger::Resources::Suitability::Assessments::CandidateAssessmentReport::Status::UPLOADING
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

        candidate_name = @report.report_hash[:candidate][:name]
        company_name = @report.report_hash[:company][:name]

        template = if @report.configuration[:is_functional_assessment]
          "functional_report"
        elsif @report.report_hash[:assessment][:assessment_type] == "competency"
          "competency_report"
        else
          "assessment_report"
        end
        report_status = {
          :errors => [],
          :message => "",
          :status => "success"
        }

        @view_mode = "html"
        html = render_to_string(
           template: "assessment_reports/#{template}",
           layout: "layouts/candidate_reports",
           handlers: [ :haml ],
           formats: [ :html ]
        )

        @view_mode = "feedback"
        feedback_html = render_to_string(
           template: "assessment_reports/assessment_report_feedback.html.haml",
           layout: "layouts/feedback_reports.html.haml",
           handlers: [ :haml ],
           formats: [ :html ]
        )

        @view_mode = "pdf"
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string(
            "assessment_reports/#{template}.pdf.haml",
            layout: "layouts/candidate_reports.pdf.haml",
            handlers: [ :haml ],
            formats: [:pdf]
          ),
          margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
          footer: {
            :content => render_to_string("shared/reports/pdf/_report_footer.pdf.haml",layout: "layouts/candidate_reports.pdf.haml")
          }
        )

        FileUtils.mkdir_p(Rails.root.join("tmp"))
        file_id = "#{candidate_name.underscore.gsub('/','-').gsub(' ','-').gsub('_','-')}-#{company_name.underscore.gsub('/','-').gsub(' ','-').gsub('_','-')}-#{@report.id}"
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
        Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.save_existing(report_id,
          :custom_assessment_id => assessment_id,
          :candidate_id => candidate_id,
          :company_id => company_id,
          :notifications_sent_at => notifications_sent_at,
          :uploaded_at => now,
          :s3_keys => { :pdf => pdf_s3, :html => html_s3, :feedback => feedback_html_s3 },
          :status => Vger::Resources::Suitability::Assessments::CandidateAssessmentReport::Status::UPLOADED
        )
        File.delete(pdf_save_path)
        File.delete(html_save_path)
        File.delete(feedback_html_save_path)
        
        mailer_data = {
          report_id: @report.report_hash[:id],
          candidate: @report.report_hash[:candidate],
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
            # if report_email_recipients is same as candidate email
            # use send_report_to_candidate template
            # else use send_report template
            puts "Sending Report"
            report_email_recipients = @report.report_hash[:report_email_recipients].to_s.split(',')
            if report_email_recipients.include? @report.report_hash[:candidate][:email]
              JombayNotify::Email.create_from_mail(SystemMailer.send_report_to_candidate(mailer_data), "send_report_to_candidate")
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
          Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.save_existing(report_id,
            :custom_assessment_id => assessment_id,
            :candidate_id => candidate_id,
            :company_id => company_id,
            :status => Vger::Resources::Suitability::Assessments::CandidateAssessmentReport::Status::FAILED
          )
        end
        JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("Report Uploader","Failed to upload report #{report_id}",{
          :report => {
            :status => "Failed",
            :company_id => company_id,
            :custom_assessment_id => assessment_id,
            :candidate_id => candidate_id,
            :report_id => report_id
          },
          :errors => {
            :backtrace => [e.message] + e.backtrace[0..20]
          }
        }), "notify_report_status")
      end
    end
  end
end  
