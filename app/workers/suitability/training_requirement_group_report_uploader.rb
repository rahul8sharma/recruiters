module Suitability
  class TrainingRequirementGroupReportUploader < ::ReportUploader
    def upload_report
      training_requirement_group_id = @report_attributes["training_requirement_group_id"]
      training_requirement_group_report_id = @report_attributes["training_requirement_group_report_id"]
      report_status = {
        errors: [],
        message: "",
        status: "success"
      }
      @norm_buckets = Vger::Resources::Suitability::NormBucket.where(order: "weight ASC").all.to_a
      @training_requirement_group = Vger::Resources::Suitability::TrainingRequirementGroup.find(training_requirement_group_id)
      @report = Vger::Resources::Suitability::AssessmentGroupReport.find(training_requirement_group_report_id)

      if !@report.report_data || !@report.report_data[:factor_scores].present?
        Vger::Resources::Suitability::AssessmentGroupReport.save_existing(training_requirement_group_report_id,
          status: Vger::Resources::Suitability::AssessmentGroupReport::Status::FAILED,
        )
        JombayNotify::Email.create_from_mail(
          SystemMailer.notify_report_status(
            "TR Group Report Uploader",
            "Failed to upload training requirements group report for Assessment Group with ID #{training_requirement_group_id} due to insufficient data.",
            {
              report: {
                status: "Failed",
                training_requirement_id: training_requirement_group_report_id
              }
            }
          ), 
          "notify_report_status"
        )  
        return
      end
      @report_data = @report.report_data
      @report_data[:company_id] = @training_requirement_group.company_id
      @report.report_hash = @report.report_data

      @view_mode = "html"
      html = render_to_string(
              template: "assessment_group_reports/training_requirements_report",
              layout: "layouts/training_requirements_report",
              handlers: [ :haml ],
              formats: [:html]
            )

      @view_mode = "pdf"
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string(
          "assessment_group_reports/training_requirements_report",
          layout: "layouts/training_requirements_report",
          handlers: [ :haml ],
          formats: [:pdf]
        ),
        margin: pdf_margin,
        footer: {
          content: render_to_string(
            "shared/reports/pdf/_report_footer",
            layout: "layouts/training_requirements_report",
            handlers: [ :haml ],
            formats: [:pdf]
          )
        }
      )

      Vger::Resources::Suitability::AssessmentGroupReport.save_existing(training_requirement_group_report_id,
        status: Vger::Resources::Suitability::AssessmentGroupReport::Status::UPLOADING
      )

      FileUtils.mkdir_p(Rails.root.join("tmp"))
      pdf_file_id = "training_requirements_report_training_requirement_group_#{@training_requirement_group.id}.pdf"
      html_file_id = "training_requirements_report_training_requirement_group_#{@training_requirement_group.id}.html"
      pdf_save_path = Rails.root.join('tmp',"#{pdf_file_id}")
      html_save_path = Rails.root.join('tmp',"#{html_file_id}")

      File.open(html_save_path, 'wb') do |file|
        file << html
      end
      File.open(pdf_save_path, 'wb') do |file|
        file << pdf
      end
      pdf_s3 = upload_file_to_s3("training_requirement_group_reports/pdf/#{pdf_file_id}",pdf_save_path)
      html_s3 = upload_file_to_s3("training_requirement_group_reports/html/#{html_file_id}",html_save_path)
      File.delete(pdf_save_path)
      File.delete(html_save_path)

      Vger::Resources::Suitability::AssessmentGroupReport.save_existing(
        training_requirement_group_report_id,
        status:      Vger::Resources::Suitability::AssessmentGroupReport::Status::UPLOADED,
        pdf_bucket:  html_s3[:bucket],
        pdf_key:     pdf_s3[:key],
        html_bucket: html_s3[:bucket],
        html_key:    html_s3[:key]
      )

      JombayNotify::Email.create_from_mail(SystemMailer.send_training_requirement_group_report(@report_attributes), "send_report")
    end
    
    def set_report_status_to_failed
      Vger::Resources::Suitability::AssessmentGroupReport.save_existing(
        @report_attributes["training_requirement_group_report_id"],
        status: Vger::Resources::Suitability::AssessmentGroupReport::Status::FAILED
      )
    end
    
    def error_email_subject
      "Failed to upload training_requirements report for Assessment Group with ID #{@report_attributes[:training_requirement_group_id]}"
    end
  end
end  
