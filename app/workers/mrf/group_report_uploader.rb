module Mrf
  class GroupReportUploader < Mrf::ReportUploader
    def perform(report_data, auth_token, patch = {})
      tries = 0

      report_data = HashWithIndifferentAccess.new report_data
      RequestStore.store[:auth_token] = auth_token
      report_id = report_data["id"]

      begin
        puts "Getting Report #{report_id}"
        @report = Vger::Resources::Mrf::AssessmentReport.find(report_id, report_data)
        
        @assessment = Vger::Resources::Mrf::Assessment.find(@report.assessment_id, company_id: report_data[:company_id])
        
        @report.report_hash = @report.report_data
        
        get_norm_buckets(report_data)
        
        Vger::Resources::Mrf::AssessmentReport.save_existing(report_id,
          :status => Vger::Resources::Mrf::AssessmentReport::Status::UPLOADING
        )
        
        template = @report.report_data[:assessment][:use_competencies] ? "competency_group_report" : "fit_group_report"

        report_status = {
          :errors => [],
          :message => "",
          :status => "success"
        }
        
        @view_mode = "html"
        html = render_to_string(
           template: "mrf/assessments/assessment_reports/#{template}.html.haml",
           layout: "layouts/mrf/group_reports.html.haml",
           handlers: [ :haml ],
           formats: [ :html ]
        )
        
        FileUtils.mkdir_p(Rails.root.join("tmp"))
        html_file_id = "mrf_report_#{@report.id}.html"      
        html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")
        File.open(html_save_path, 'wb') do |file|
          file << html
        end
        html_s3 = upload_file_to_s3("mrf_group_reports/html/#{html_file_id}",html_save_path)
        
        File.delete(html_save_path)
        
        attributes = {
          :html_bucket => html_s3[:bucket],
          :html_key => html_s3[:key],
          :status => Vger::Resources::Mrf::AssessmentReport::Status::UPLOADED
        }
=begin          
        @view_mode = "pdf"
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string(
            "mrf/assessments/assessment_reports/#{template}.pdf.haml",
            layout: "layouts/mrf/group_reports.pdf.haml",
            handlers: [ :haml ],
            formats: [:pdf]
          ),
          margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
          footer: {
            content: render_to_string("shared/reports/pdf/_report_footer.pdf.haml",
                                        layout: "layouts/mrf/assessment_reports.pdf.haml")
          }
        )
        pdf_file_id = "mrf_report_#{@report.id}.pdf"
        pdf_save_path = File.join(Rails.root.to_s,'tmp',"#{pdf_file_id}")
        File.open(pdf_save_path, 'wb') do |file|
          file << pdf
        end
        pdf_s3 = upload_file_to_s3("mrf_group_reports/pdf/#{pdf_file_id}",pdf_save_path)
        
        attributes[:pdf_bucket] = pdf_s3[:bucket]
        attributes[:pdf_key] = pdf_s3[:key]
        
        File.delete(pdf_save_path)
=end
        Vger::Resources::Mrf::AssessmentReport.save_existing(report_id,attributes)
        JombayNotify::Email.create_from_mail(SystemMailer.send_mrf_group_report(@report.id, @report.report_data), "send_mrf_group_report")
      rescue Exception => e
        Rails.logger.debug e.message
        puts e.message
        tries = tries + 1
        if tries < 5
          retry
        else
          Vger::Resources::Mrf::AssessmentReport.save_existing(report_id,
            :status => Vger::Resources::Mrf::AssessmentReport::Status::FAILED
          )
        end
        JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("MRF Group Report Uploader","Failed to upload MRF group report {report_id}",{
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
