module Jq
  class ReportUploader < ::ReportUploader
    def perform(report_data, auth_token, patch = {})
      tries = 0
      patch ||= {}
      report_data = HashWithIndifferentAccess.new report_data
      report_id = report_data["id"]
      patch ||= {}
      now = Time.now
      begin
        RequestStore.store[:auth_token] = get_token({ auth_token: auth_token }).token
        puts "Getting Report #{report_id}"
        methods = []
        methods = [:report_hash] if !patch.empty?
        @report = Vger::Resources::Jq::UserAssessmentReport.find(report_id,
          :patch => patch,
          :methods => methods
        )
        
        @report.report_hash = @report.report_data if patch.empty?

        Vger::Resources::Jq::UserAssessmentReport.save_existing(report_id,
          :status => Vger::Resources::Jq::UserAssessmentReport::Status::UPLOADING
        )


        @norm_buckets = Vger::Resources::Suitability::NormBucket\
                        .where(order: "weight ASC").all

        user_name = @report.report_hash[:user][:name]

        template = "jq_report"
        
        report_status = {
          :errors => [],
          :message => "",
          :status => "success"
        }

        @view_mode = "html"
        html = render_to_string(
           template: "jq/user_assessment_reports/#{template}",
           layout: "layouts/jq_reports",
           handlers: [ :haml ],
           formats: [ :html ]
        )

        @view_mode = "pdf"
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string(
            "jq/user_assessment_reports/#{template}.pdf.haml",
            layout: "layouts/jq_reports.pdf.haml",
            handlers: [ :haml ],
            formats: [:pdf]
          ),
          margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
          footer: {
            :content => render_to_string("shared/reports/pdf/_report_footer.pdf.haml",layout: "layouts/jq_reports.pdf.haml")
          },
          zoom: 1.5,
          disable_smart_shrinking: false
        )

        FileUtils.mkdir_p(Rails.root.join("tmp"))
        file_id = "#{user_name.underscore.gsub('/','-').gsub(' ','-').gsub('_','-')}-#{@report.id}"
        pdf_file_id = "#{file_id}.pdf"
        html_file_id = "#{file_id}.html"
        pdf_save_path = File.join(Rails.root.to_s,'tmp',"#{pdf_file_id}")
        html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")

        File.open(html_save_path, 'wb') do |file|
          file << html
        end
        File.open(pdf_save_path, 'wb') do |file|
          file << pdf
        end
        pdf_s3 = upload_file_to_s3("jq_reports/pdf/#{pdf_file_id}",pdf_save_path)
        html_s3 = upload_file_to_s3("jq_reports/html/#{html_file_id}",html_save_path)
        
          
        status = Vger::Resources::Jq::UserAssessmentReport::Status::UPLOADED
        Vger::Resources::Jq::UserAssessmentReport.save_existing(report_id,
          :uploaded_at => now,
          :s3_keys => { :pdf => pdf_s3, :html => html_s3 },
          :status => status
        )
        File.delete(pdf_save_path)
        File.delete(html_save_path)
        
        mailer_data = {
          report_id: @report.report_hash[:id],
          user: @report.report_hash[:user],
          assessment: @report.report_hash[:assessment]
        }
        
        JombayNotify::Email.create_from_mail(SystemMailer.send_jq_report(mailer_data), "send_report")
      rescue Exception => e
        Rails.logger.debug e.message
        puts e.message
        tries = tries + 1
        if tries < 5
          retry
        else
          Vger::Resources::Jq::UserAssessmentReport.save_existing(report_id,
            :status => Vger::Resources::Jq::UserAssessmentReport::Status::FAILED
          ) rescue nil
        end
        JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("Jq Report Uploader","Failed to upload jq report #{report_id}",{
          :report => {
            :status => "Failed",
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
