class TrainingRequirementGroupReportUploader < AbstractController::Base
  include Sidekiq::Worker
  
  include AbstractController::Rendering
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include Rails.application.routes.url_helpers
  helper ApplicationHelper
  helper ReportsHelper
  self.view_paths = "app/views"
  
  def perform(report_data, auth_token, patch = {})
    report_data = HashWithIndifferentAccess.new report_data
    Rails.logger.debug "************* #{report_data} ******************"
    RequestStore.store[:auth_token] = auth_token
    training_requirement_group_id = report_data["training_requirement_group_id"]
    training_requirement_group_report_id = report_data["training_requirement_group_report_id"]
    @training_requirement_group = Vger::Resources::Suitability::TrainingRequirementGroup.find(training_requirement_group_id, methods: [ :training_requirements_report ])
    @training_requirement_group_report = Vger::Resources::Suitability::AssessmentGroupReport.find(training_requirement_group_report_id)
    @training_requirement_group_report.report_data = @training_requirement_group.training_requirements_report
    return if !@training_requirement_group_report.report_data[:factor_scores].present?
    @report_data = @training_requirement_group.training_requirements_report
    report_data["company_id"] = @training_requirement_group.company_id
    tries = 0
    report_status = {
      :errors => [],
      :message => "",
      :status => "success"
    }
    begin
      @view_mode = "html"
      
      Vger::Resources::Suitability::AssessmentGroupReport.save_existing(training_requirement_group_report_id,
        :status      => Vger::Resources::Suitability::AssessmentGroupReport::Status::UPLOADING,
      )
      
      html = render_to_string(
         template: "assessment_group_reports/training_requirements_report", 
         layout: "layouts/assessment_reports", 
         handlers: [ :haml ]
      )
      
      @view_mode = "pdf"
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string(
          "assessment_group_reports/training_requirements_report", 
          layout: "layouts/assessment_reports.html.haml", 
          handlers: [ :haml ],
          formats: [:html]
        ),
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        footer: {
          :content => render_to_string("shared/reports/_report_footer.html.haml",layout: "layouts/assessment_reports.html.haml")
        }
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
      pdf_s3 = upload_file_to_s3(pdf_file_id,pdf_save_path)
      html_s3 = upload_file_to_s3(html_file_id,html_save_path)
      File.delete(pdf_save_path)
      File.delete(html_save_path)
      
      
      # Update report_urls hash for training_requirement
      pdf_url = S3Utils.get_url("#{Rails.env.to_s}_training_requirements_reports", "training_requirements_report_training_requirement_group_#{@training_requirement_group.id}.pdf")
      html_url = S3Utils.get_url("#{Rails.env.to_s}_training_requirements_reports", "training_requirements_report_training_requirement_group_#{@training_requirement_group.id}.html")
      
      Vger::Resources::Suitability::AssessmentGroupReport.save_existing(training_requirement_group_report_id,
        :status      => Vger::Resources::Suitability::AssessmentGroupReport::Status::UPLOADED,
        :pdf_bucket  => "#{Rails.env.to_s}_training_requirements_reports",
        :pdf_key     => "training_requirements_report_training_requirement_group_#{@training_requirement_group.id}.pdf",
        :html_bucket => "#{Rails.env.to_s}_training_requirements_reports",
        :html_key    => "training_requirements_report_training_requirement_group_#{@training_requirement_group.id}.html",
        :report_data => @report_data
      )
      
      patch["send_report"] ||= "Yes"
      if patch["send_report"] == "Yes"
        JombayNotify::Email.create_from_mail(SystemMailer.send_training_requirement_group_report(report_data), "send_report")
      end
    rescue Exception => e
      Rails.logger.debug e.message
      tries = tries + 1
      if tries < 5
        retry
      end
      JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("Report Uploader","Failed to upload training_requirements report for Assessment Group with ID #{report_data[:training_requirement_group_id]}",{
        :report => {
          :status => "Failed",
          :training_requirement_id => @training_requirement_group.id
        },
        :errors => {
          :backtrace => [e.message] + e.backtrace[0..20]
        }
      }), "notify_report_status")
    end 
  end
  
  def upload_file_to_s3(file_id,file_path)
    File.open(file_path,"r") do |file|
      Rails.logger.debug "Uploading #{file_id} to s3 ........."
      s3_bucket_name = "#{Rails.env.to_s}_training_requirements_reports"
      s3_key = "#{file_id}"
      url = S3Utils.upload(s3_bucket_name, s3_key, file)
      Rails.logger.debug "Uploaded #{file_id} with url #{url} to s3"
      return { :bucket => s3_bucket_name, :key => s3_key }
    end
  end
end
