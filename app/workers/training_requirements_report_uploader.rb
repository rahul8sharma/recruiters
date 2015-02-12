class TrainingRequirementsReportUploader < AbstractController::Base
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
      @norm_buckets = Vger::Resources::Suitability::NormBucket.where(order: "weight ASC").all.to_a
      @assessment = Vger::Resources::Suitability::CustomAssessment.find(assessment_id)
      @report = Vger::Resources::Suitability::AssessmentReport.find(assessment_report_id)

      @report.report_hash = @report.report_data
      if !@report.report_data[:factor_scores].present?
        Vger::Resources::Suitability::AssessmentReport.save_existing(assessment_report_id,
          :status      => Vger::Resources::Suitability::AssessmentReport::Status::FAILED,
        )
        JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("TRR Report Uploader","Failed to upload training_requirements report for Assessment with ID #{assessment_id} due to insufficient data.",{
          :report => {
            :status => "Failed",
            :assessment_id => assessment_id
          }
        }), "notify_report_status")
        return
      end
      @report_data = @report.report_data
      @report_data[:company_id] = @assessment.company_id

      @view_mode = "html"

      Vger::Resources::Suitability::AssessmentReport.save_existing(assessment_report_id,
        :status      => Vger::Resources::Suitability::AssessmentReport::Status::UPLOADING,
      )

      html = render_to_string(
         template: "assessment_reports/training_requirements_report.html.haml",
         layout: "layouts/training_requirements_report.html.haml",
         formats: [:html],
         handlers: [ :haml ]
      )

      @view_mode = "pdf"
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string(
          "assessment_reports/training_requirements_report.pdf.haml",
          layout: "layouts/training_requirements_report.pdf.haml",
          handlers: [ :haml ],
          formats: [:pdf]
        ),
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        footer: {
          content: render_to_string("shared/reports/pdf/_report_footer.pdf.haml",
          layout: "layouts/training_requirements_report.pdf.haml")
        }
      )

      FileUtils.mkdir_p(Rails.root.join("tmp"))
      pdf_file_id = "training_requirements_report_assessment_#{@assessment.id}.pdf"
      html_file_id = "training_requirements_report_assessment_#{@assessment.id}.html"
      pdf_save_path = Rails.root.join('tmp',"#{pdf_file_id}")
      html_save_path = Rails.root.join('tmp',"#{html_file_id}")

      File.open(html_save_path, 'wb') do |file|
        file << html
      end
      File.open(pdf_save_path, 'wb') do |file|
        file << pdf
      end
      pdf_s3 = upload_file_to_s3("training_requirement_reports/pdf/#{pdf_file_id}",pdf_save_path)
      html_s3 = upload_file_to_s3("training_requirement_reports/html/#{html_file_id}",html_save_path)
      File.delete(pdf_save_path)
      File.delete(html_save_path)

      Vger::Resources::Suitability::AssessmentReport.save_existing(assessment_report_id,
        :status      => Vger::Resources::Suitability::AssessmentReport::Status::UPLOADED,
        :pdf_bucket  => html_s3[:bucket],
        :pdf_key     => pdf_s3[:key],
        :html_bucket => html_s3[:bucket],
        :html_key    => html_s3[:key]
      )

      patch["send_report"] ||= "Yes"
      if patch["send_report"] == "Yes"
        JombayNotify::Email.create_from_mail(SystemMailer.send_training_requirements_report(report_data), "send_report")
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
      JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("Report Uploader","Failed to upload training_requirements report for Assessment with ID #{assessment_id}",{
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
