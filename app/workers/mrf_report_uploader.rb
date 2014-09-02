class MrfReportUploader < AbstractController::Base
  include Sidekiq::Worker

  include AbstractController::Rendering
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include Rails.application.routes.url_helpers
  helper ApplicationHelper
  helper ReportsHelper
  helper_method :protect_against_forgery?
  self.view_paths = "app/views"
  
  def protect_against_forgery?
    false
  end

  def perform(report_data, auth_token, patch = {})
    tries = 0

    report_data = HashWithIndifferentAccess.new report_data
    RequestStore.store[:auth_token] = auth_token
    report_id = report_data["id"]

    # begin
      puts "Getting Report #{report_id}"
      @report = Vger::Resources::Mrf::Report.find(report_id)   
      
      Vger::Resources::Mrf::Report.save_existing(report_id,
        :status => Vger::Resources::Mrf::Report::Status::UPLOADING
      )
      
      @norm_buckets = Vger::Resources::Suitability::NormBucket.all

      template = @report.report_data[:assessment][:use_competencies] ? "competency_report" : "fit_report"

      report_status = {
        :errors => [],
        :message => "",
        :status => "success"
      }
      
      @view_mode = "html"
      html = render_to_string(
         template: "mrf/assessments/reports/#{template}",
         layout: "layouts/reports_360",
         handlers: [ :haml ],
         formats: [ :html ]
      )
      
      FileUtils.mkdir_p(Rails.root.join("tmp"))
      html_file_id = "mrf_report_#{@report.id}.html"      
      html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")

      File.open(html_save_path, 'wb') do |file|
        file << html
      end
      html_s3 = upload_file_to_s3(html_file_id,html_save_path)
  
      Vger::Resources::Mrf::Report.save_existing(report_id,
        :html_key => html_s3[:key],
        :html_bucket => html_s3[:bucket],
        :status => Vger::Resources::Mrf::Report::Status::UPLOADED
      )
      File.delete(html_save_path)
     
      JombayNotify::Email.create_from_mail(SystemMailer.send_mrf_report(@report.id, @report.report_data), "send_mrf_report")
  
    
    # rescue Exception => e
    #   Rails.logger.debug e.message
    #   puts e.message
    #   tries = tries + 1
    #   if tries < 5
    #     retry
    #   else
    #     Vger::Resources::Mrf::Report.save_existing(report_id,
    #       :status => Vger::Resources::Mrf::Report::Status::FAILED
    #     )
    #   end
    #   JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("MRF Report Uploader","Failed to upload MRF report #{report_id}",{
    #     :report => {
    #       :status => "Failed",
    #       :report_id => report_id
    #     },
    #     :errors => {
    #       :backtrace => [e.message] + e.backtrace[0..20]
    #     }
    #   }), "notify_report_status")
    # end
  end

  def upload_file_to_s3(file_id,file_path)
    File.open(file_path,"r") do |file|
      Rails.logger.debug "Uploading #{file_id} to s3 ........."
      s3_bucket_name = Rails.application.config.s3_buckets[Rails.env.to_s]["bucket_name"]
      s3_key = "#{file_id}"
      url = S3Utils.upload(s3_bucket_name, s3_key, file)
      Rails.logger.debug "Uploaded #{file_id} with url #{url} to s3"
      return { :bucket => s3_bucket_name, :key => s3_key }
    end
  end
end
