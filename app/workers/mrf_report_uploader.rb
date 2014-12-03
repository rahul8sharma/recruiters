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

    begin
      puts "Getting Report #{report_id}"
      @report = Vger::Resources::Mrf::Report.find(report_id, report_data)   
      
      @report.report_hash = @report.report_data
      
      Vger::Resources::Mrf::Report.save_existing(report_id,
        :status => Vger::Resources::Mrf::Report::Status::UPLOADING
      )
      
      @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                      order: "weight ASC", query_options: {
                        company_id: report_data[:company_id]
                      }).all
    
      if @norm_buckets.empty?
        @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                        order: "weight ASC", query_options: {
                          company_id: nil
                        }).all
      end
      @norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]

      template = @report.report_data[:assessment][:use_competencies] ? "competency_report" : "fit_report"

      report_status = {
        :errors => [],
        :message => "",
        :status => "success"
      }
      
      @view_mode = "html"
      html = render_to_string(
         template: "mrf/assessments/reports/#{template}.html.haml",
         layout: "layouts/reports_360.html.haml",
         handlers: [ :haml ],
         formats: [ :html ]
      )
      
      @view_mode = "pdf"
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string(
          "assessment_reports/#{template}.pdf.haml",
          layout: "layouts/reports_360.pdf.haml",
          handlers: [ :haml ],
          formats: [:pdf]
        ),
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        footer: {
          :content => render_to_string("shared/reports/pdf/_report_footer.pdf.haml",layout: "layouts/candidate_reports.pdf.haml")
        }
      )


      FileUtils.mkdir_p(Rails.root.join("tmp"))
      html_file_id = "mrf_report_#{@report.id}.html"      
      html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")

      pdf_file_id = "#{candidate_name.underscore.gsub(' ','-').gsub('_','-')}-#{company_name.underscore.gsub(' ','-').gsub('_','-')}-#{@report.id}.pdf"
      pdf_save_path = File.join(Rails.root.to_s,'tmp',"#{pdf_file_id}")

      File.open(html_save_path, 'wb') do |file|
        file << html
      end
      File.open(pdf_save_path, 'wb') do |file|
        file << pdf
      end
      
      html_s3 = upload_file_to_s3(html_file_id,html_save_path)
      pdf_s3 = upload_file_to_s3(pdf_file_id,pdf_save_path)
  
      Vger::Resources::Mrf::Report.save_existing(report_id,
        :html_key => html_s3[:key],
        :pdf_key => pdf_s3[:key],
        :html_bucket => html_s3[:bucket],
        :pdf_bucket => pdf_s3[:bucket],
        :status => Vger::Resources::Mrf::Report::Status::UPLOADED
      )
      
      File.delete(html_save_path)
      File.delete(pdf_save_path)
     
      JombayNotify::Email.create_from_mail(SystemMailer.send_mrf_report(@report.id, @report.report_data), "send_mrf_report")
  
    
    rescue Exception => e
      Rails.logger.debug e.message
      puts e.message
      tries = tries + 1
      if tries < 5
        retry
      else
        Vger::Resources::Mrf::Report.save_existing(report_id,
          :status => Vger::Resources::Mrf::Report::Status::FAILED
        )
      end
      JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("MRF Report Uploader","Failed to upload MRF report #{report_id}",{
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
