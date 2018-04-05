module Jq
  class ReportUploader < ::ReportUploader
    def upload_report
      report_id = @report_attributes["id"]
      now = Time.now
      puts "Getting Report #{report_id}"
      methods = []
      @report = Vger::Resources::Jq::UserAssessmentReport.find(report_id,
        :methods => methods
      )
      
      @report.report_hash = @report.report_data

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
      html = ApplicationController.render(
         template: "jq/user_assessment_reports/#{template}",
         layout: "layouts/jq_reports",
         handlers: [ :haml ],
         formats: [ :html ],
         assigns: { report: @report, view_mode: @view_mode, 
        norm_buckets: @norm_buckets, report_attributes: @report_attributes}
      )

      @view_mode = "pdf"
      pdf = WickedPdf.new.pdf_from_string(
        ApplicationController.render(
          "jq/user_assessment_reports/#{template}.pdf.haml",
          layout: "layouts/jq_reports.pdf.haml",
          handlers: [ :haml ],
          formats: [:pdf],
          assigns: { report: @report, view_mode: @view_mode, 
          norm_buckets: @norm_buckets, report_attributes: @report_attributes}
        ),
        margin: { :left => 0,:right => 0, :top => 0, :bottom => 8 },
        footer: {
          :content => ApplicationController.render("shared/reports/pdf/_report_footer.pdf.haml",
                      layout: "layouts/jq_reports.pdf.haml",
                      assigns: { report: @report, view_mode: @view_mode, 
                      norm_buckets: @norm_buckets, report_attributes: @report_attributes })
        }
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
    end
    
    def set_report_status_to_failed
      Vger::Resources::Jq::UserAssessmentReport.save_existing(
        @report_attributes[:id],
        :status => Vger::Resources::Jq::UserAssessmentReport::Status::FAILED
      )
    end
    
    def error_email_subject
      "Failed to upload jq report #{@report_attributes[:id]}"
    end
  end
end  
