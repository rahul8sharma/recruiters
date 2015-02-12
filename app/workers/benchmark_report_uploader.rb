class BenchmarkReportUploader < AbstractController::Base
  include Sidekiq::Worker
  
  include AbstractController::Rendering
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include Rails.application.routes.url_helpers
  include UploadHelper
  helper ApplicationHelper
  helper ReportsHelper
  self.view_paths = "app/views"
  
  def perform(report_data, auth_token, patch = {})
    report_data = HashWithIndifferentAccess.new report_data
    Rails.logger.debug "************* #{report_data} ******************"
    RequestStore.store[:auth_token] = auth_token
    assessment_id = report_data["assessment_id"]
    assessment_report_id = report_data["assessment_report_id"]
    tries = 0
    report_status = {
      :errors => [],
      :message => "",
      :status => "success"
    }
    begin
      @assessment = Vger::Resources::Suitability::CustomAssessment.find(assessment_id, methods: [ :benchmark_report ])
      @assessment_report = Vger::Resources::Suitability::AssessmentReport.find(assessment_report_id)
      @assessment_report.report_data = @assessment.benchmark_report
      @report = @assessment.benchmark_report
      
      report_data["company_id"] = @assessment.company_id
      @norm_buckets = Vger::Resources::Suitability::NormBucket.all.to_a
      
      @view_mode = "html"
      
      Vger::Resources::Suitability::AssessmentReport.save_existing(assessment_report_id,
        :status      => Vger::Resources::Suitability::AssessmentReport::Status::UPLOADING,
      )
      
      html = render_to_string(
         template: "assessment_reports/benchmark_report", 
         layout: "layouts/benchmark_report.html.haml", 
         handlers: [ :haml ]
      )
      
      @view_mode = "pdf"
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string(
          "assessment_reports/benchmark_report", 
          layout: "layouts/benchmark_report.html.haml", 
          handlers: [ :haml ],
          formats: [:html]
        ),
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        footer: {
          content: render_to_string("shared/reports/pdf/_report_footer.pdf.haml",
          layout: "layouts/benchmark_report.html.haml")
        }
      )
      
      FileUtils.mkdir_p(Rails.root.join("tmp"))
      pdf_file_id = "benchmark_report_assessment_#{@assessment.id}.pdf"
      html_file_id = "benchmark_report_assessment_#{@assessment.id}.html"
      pdf_save_path = Rails.root.join('tmp',"#{pdf_file_id}")
      html_save_path = Rails.root.join('tmp',"#{html_file_id}")
      
      File.open(html_save_path, 'wb') do |file|
        file << html
      end
      File.open(pdf_save_path, 'wb') do |file|
        file << pdf
      end
      pdf_s3 = upload_file_to_s3("benchmark_reports/pdf/#{pdf_file_id}",pdf_save_path)
      html_s3 = upload_file_to_s3("benchmark_reports/html/#{html_file_id}",html_save_path)
      File.delete(pdf_save_path)
      File.delete(html_save_path)
      
      Vger::Resources::Suitability::AssessmentReport.save_existing(@assessment_report.id,
        :status      => Vger::Resources::Suitability::AssessmentReport::Status::UPLOADED,
        :pdf_bucket  => pdf_s3[:bucket],
        :pdf_key     => pdf_s3[:key],
        :html_bucket => html_s3[:bucket],
        :html_key    => html_s3[:key],
        :report_data => @report
      )
      
      patch["send_report"] ||= "Yes"
      if patch["send_report"] == "Yes"
        JombayNotify::Email.create_from_mail(SystemMailer.send_benchmark_report(report_data), "send_report")
      end
    rescue Exception => e
      Rails.logger.debug e.message
      tries = tries + 1
      if tries < 5
        retry
      else
        Vger::Resources::Suitability::AssessmentReport.save_existing(assessment_report_id,
        :status      => Vger::Resources::Suitability::AssessmentReport::Status::FAILED,
        )
      end
      JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("Report Uploader","Failed to upload benchmark report for Assessment with ID #{assessment_id}",{
        :report => {
          :status => "Failed",
          :assessment_id => assessment_id
        },
        :errors => {
          :backtrace => [e.message] + e.backtrace[0..20]
        }
      }), "notify_report_status")
    end 
  end
end
