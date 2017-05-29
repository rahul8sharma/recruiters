module Suitability
  class TrainingRequirementsReportUploader < ::ReportUploader
    def upload_report
      assessment_id = @report_attributes["assessment_id"]
      assessment_report_id = @report_attributes["assessment_report_id"]
      report_status = {
        :errors => [],
        :message => "",
        :status => "success"
      }
      @norm_buckets = Vger::Resources::Suitability::NormBucket.where(order: "weight ASC").all.to_a
      @assessment = Vger::Resources::Suitability::CustomAssessment.find(assessment_id)
      @report = Vger::Resources::Suitability::AssessmentReport.find(assessment_report_id)

      @report.report_hash = @report.report_data
      if !@report.report_data || !@report.report_data[:factor_scores].present?
        Vger::Resources::Suitability::AssessmentReport.save_existing(assessment_report_id,
          :status      => Vger::Resources::Suitability::AssessmentReport::Status::FAILED
        )
        JombayNotify::Email.create_from_mail(
          SystemMailer.notify_report_status(
            "TRR Report Uploader",
            "Failed to upload training_requirements report for Assessment with ID #{assessment_id} due to insufficient data.",
            {
              :report => {
                :status => "Failed",
                :assessment_id => assessment_id
              }
            }
          ), 
          "notify_report_status"
        )
        return
      end
      @report_data = @report.report_data
      @report_data[:company_id] = @assessment.company_id

      @view_mode = "html"
      
      html = render_to_string(
           template: "assessment_reports/training_requirements_report",
           layout: "layouts/training_requirements_report",
           formats: [:html],
           handlers: [ :haml ]
        )
        
      @view_mode = "pdf"
      
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string(
          "assessment_reports/training_requirements_report",
          layout: "layouts/training_requirements_report",
          handlers: [ :haml ],
          formats: [:pdf]
        ),
        margin: { :left => 0,:right => 0, :top => 0, :bottom => 8 },
        footer: {
          content: render_to_string(
            "shared/reports/pdf/_report_footer",
            layout: "layouts/training_requirements_report",
            handlers: [ :haml ],
            formats: [:pdf]
          )
        }
      )

      Vger::Resources::Suitability::AssessmentReport.save_existing(assessment_report_id,
        :status      => Vger::Resources::Suitability::AssessmentReport::Status::UPLOADING,
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

      JombayNotify::Email.create_from_mail(SystemMailer.send_training_requirements_report(@report_attributes), "send_report")
    end
    
    def set_report_status_to_failed
      Vger::Resources::Suitability::AssessmentReport.save_existing(
        @report_attributes[:assessment_report_id],
        :status => Vger::Resources::Suitability::AssessmentReport::Status::FAILED,
      )
    end
    
    def error_email_subject
      "Failed to upload training_requirements report for Assessment with ID #{@report_attributes[:assessment_id]}"
    end
  end
end  
