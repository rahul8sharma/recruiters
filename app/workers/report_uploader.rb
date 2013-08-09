class ReportUploader < AbstractController::Base
  include Sidekiq::Worker
  
  include AbstractController::Rendering
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include Rails.application.routes.url_helpers
  helper ApplicationHelper
  helper ReportsHelper
  self.view_paths = "app/views"
  
  def perform(report_id, auth_token)
    RequestStore.store[:auth_token] = auth_token
    
    @report = Vger::Resources::Suitability::CandidateAssessmentReport.find(report_id, :methods => [ :report_hash ])
    
    tries = 0
    report_status = {
      :errors => [],
      :message => "",
      :status => "success"
    }
    begin
      html = render_to_string(
         template: 'assessment_reports/assessment_report.html.haml', 
         layout: "layouts/reports.html.haml", 
         handlers: [ :haml ],
         locals: { :@view_mode => "html" }
      )
      
      pdf = WickedPdf.new.pdf_from_string(render_to_string(
         template: 'assessment_reports/assessment_report.html.haml', 
         layout: "layouts/reports.html.haml", 
         handlers: [ :haml ], margin: { :left => "5mm",:right => "5mm", :top => "20mm", :bottom => "0mm" },
         locals: { :@view_mode => "pdf" }
      ))
      
      FileUtils.mkdir_p(Rails.root.join("tmp"))
      pdf_file_id = "report_#{@report.id}.pdf"
      html_file_id = "report_#{@report.id}.html"
      pdf_save_path = Rails.root.join('tmp',"#{pdf_file_id}")
      html_save_path = Rails.root.join('tmp',"#{html_file_id}")
      
      Vger::Resources::Suitability::CandidateAssessmentReport.save_existing(@report.id,  
        :status => Vger::Resources::Suitability::CandidateAssessmentReport::Status::UPLOADING
      )
      File.open(html_save_path, 'wb') do |file|
        file << html
      end
      File.open(pdf_save_path, 'wb') do |file|
        file << pdf
      end
      pdf_s3 = upload_file_to_s3(pdf_file_id,pdf_save_path)
      html_s3 = upload_file_to_s3(html_file_id,html_save_path)
      Vger::Resources::Suitability::CandidateAssessmentReport.save_existing(@report.id,  
        :s3_keys => { :pdf => pdf_s3, :html => html_s3 },
        :status => Vger::Resources::Suitability::CandidateAssessmentReport::Status::UPLOADED
      )
      File.delete(pdf_save_path)
      File.delete(html_save_path)
      SystemMailer.delay.send_report(@report.report_hash)
      #SystemMailer.delay.notify_report_status("Report Uploader","Upload report #{@report.id}",{
      #  :report => {
      #    :status => "Success",
      #    :candidate_assessment_id => @report.report_hash[:candidate_assessment_id],
      #    
      #    :candidate => {
      #      :name => @report.report_hash[:candidate][:name],
      #      :email => @report.report_hash[:candidate][:email]
      #    },
      #    :assessment => {
      #      :id => @report.report_hash[:assessment][:id],
      #      :name => @report.report_hash[:assessment][:name],
      #      :assessable_id => @report.report_hash[:assessment][:assessable_id],
      #      :assessable_type => @report.report_hash[:assessment][:assessable_type]
      #    } 
      #  }
      #})
    rescue Exception => e
      Rails.logger.debug e.message
      tries = tries + 1
      if tries < 5
        retry
      else   
        Vger::Resources::Suitability::CandidateAssessmentReport.save_existing(@report.id,  
          :status => Vger::Resources::Suitability::CandidateAssessmentReport::Status::FAILED
        )
      end
      SystemMailer.delay.notify_report_status("Report Uploader","Failed to upload report #{@report.id}",{
        :report => {
          :status => "Failed",
          :candidate_assessment_id => @report.report_hash[:candidate_assessment_id],
          
          :candidate => {
            :name => @report.report_hash[:candidate][:name],
            :email => @report.report_hash[:candidate][:email]
          },
          :assessment => {
            :id => @report.report_hash[:assessment][:id],
            :name => @report.report_hash[:assessment][:name],
            :assessable_id => @report.report_hash[:assessment][:assessable_id],
            :assessable_type => @report.report_hash[:assessment][:assessable_type]
          } 
        },
        :errors => {
          :backtrace => [e.message] + e.backtrace[0..20]
        }
      })
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
