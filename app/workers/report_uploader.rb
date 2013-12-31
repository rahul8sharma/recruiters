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
  
  def perform(report_data, auth_token, patch = {})
    report_data = HashWithIndifferentAccess.new report_data
    Rails.logger.debug "************* #{report_data} ******************"
    RequestStore.store[:auth_token] = auth_token
    report_id = report_data["id"]
    company_id = report_data["company_id"]
    assessment_id = report_data["assessment_id"]
    candidate_id = report_data["candidate_id"]
    
    @report = Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.find(report_id, 
      :assessment_id => assessment_id, 
      :candidate_id => candidate_id, 
      :company_id => company_id, 
      :patch => patch, 
      :methods => [ :report_hash ]
    )
    
    template = ["fit", "benchmark"].include?(@report.report_hash[:assessment][:assessment_type]) ? "assessment_report" : "competency_report"
    
    tries = 0
    report_status = {
      :errors => [],
      :message => "",
      :status => "success"
    }
    begin
      @view_mode = "html"
      html = render_to_string(
         template: "assessment_reports/#{template}", 
         layout: "layouts/reports", 
         handlers: [ :haml ]
      )
      
      @view_mode = "pdf"
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string(
          "assessment_reports/#{template}", 
          layout: "layouts/reports.html.haml", 
          handlers: [ :haml ],
          formats: [:html]
        ),
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        header: { 
          :content => render_to_string("shared/_report_header.html.haml",layout: "layouts/reports.html.haml")
        },
        footer: {
          :content => render_to_string("shared/_report_footer.html.haml",layout: "layouts/reports.html.haml")
        }
      )
      
      FileUtils.mkdir_p(Rails.root.join("tmp"))
      pdf_file_id = "report_#{@report.id}.pdf"
      html_file_id = "report_#{@report.id}.html"
      pdf_save_path = Rails.root.join('tmp',"#{pdf_file_id}")
      html_save_path = Rails.root.join('tmp',"#{html_file_id}")
      
      Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.save_existing(report_id, 
        :assessment_id => assessment_id, 
        :candidate_id => candidate_id, 
        :company_id => company_id,  
        :status => Vger::Resources::Suitability::Assessments::CandidateAssessmentReport::Status::UPLOADING
      )
      File.open(html_save_path, 'wb') do |file|
        file << html
      end
      File.open(pdf_save_path, 'wb') do |file|
        file << pdf
      end
      pdf_s3 = upload_file_to_s3(pdf_file_id,pdf_save_path)
      html_s3 = upload_file_to_s3(html_file_id,html_save_path)
      Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.save_existing(report_id, 
        :assessment_id => assessment_id, 
        :candidate_id => candidate_id, 
        :company_id => company_id,  
        :s3_keys => { :pdf => pdf_s3, :html => html_s3 },
        :status => Vger::Resources::Suitability::Assessments::CandidateAssessmentReport::Status::UPLOADED
      )
      File.delete(pdf_save_path)
      File.delete(html_save_path)
      patch["send_report"] ||= "Yes"
      if patch["send_report"] == "Yes"
        # if report_email_recipients is same as candidate email
        # use send_report_to_candidate template
        # else use send_report template
        if @report.report_hash[:report_email_recipients] == @report.report_hash[:candidate][:email]
          JombayNotify::Email.create_from_mail(SystemMailer.send_report_to_candidate(@report.report_hash), "send_report_to_candidate")
        else
          JombayNotify::Email.create_from_mail(SystemMailer.send_report(@report.report_hash), "send_report")
        end
      end
    rescue Exception => e
      Rails.logger.debug e.message
      tries = tries + 1
      if tries < 5
        retry
      else   
        Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.save_existing(report_id, 
          :assessment_id => assessment_id, 
          :candidate_id => candidate_id, 
          :company_id => company_id,  
          :status => Vger::Resources::Suitability::Assessments::CandidateAssessmentReport::Status::FAILED
        )
      end
      JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("Report Uploader","Failed to upload report #{@report.id}",{
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
