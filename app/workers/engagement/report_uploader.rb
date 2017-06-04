module Engagement
  class ReportUploader < ::ReportUploader
    def upload_report
      report_id = @report_attributes["id"]
      survey_id = @report_attributes["survey_id"]
      user_id = @report_attributes["user_id"]
      company_id = @report_attributes["company_id"]
      puts "Getting Report #{report_id}"
      params = {}
      user_survey = Vger::Resources::Engagement::UserSurvey.where(:survey_id => survey_id,
                    :query_options => { :user_id => user_id }).all[0]
      params[:survey_id] = survey_id
      params[:user_id] = user_id
      params[:company_id] = company_id
      @report = Vger::Resources::Engagement::Report.find(report_id, params)


      @report.report_hash = @report.report_data
      if @report.status == Vger::Resources::Engagement::Report::Status::UPLOADING
       puts "Report #{report_id} is being uploaded already..."
       return
      end

      Vger::Resources::Engagement::Report.save_existing(report_id,
        :survey_id => survey_id,
        :user_id => user_id,
        :status => Vger::Resources::Engagement::Report::Status::UPLOADING
      )

      user_name = @report.report_hash[:user][:name]
      company_name = @report.report_hash[:company][:name]
      @report.report_hash[:company_id] = company_id
      @report.report_hash[:survey_id] = survey_id
      @report.report_hash[:user_id] = user_id
      @report.report_hash[:report_id] = @report.id


    #   template = ["fit", "benchmark"].include?(@report.report_hash[:assessment][:assessment_type]) ? "assessment_report" : "competency_report"

      report_status = {
        :errors => [],
        :message => "",
        :status => "success"
      }

      @view_mode = "html"
      html = render_to_string(
         template: "engagement/surveys/reports/engagement_report.html.haml",
         layout: "layouts/engagement_report.html.haml",
         handlers: [ :haml ],
         formats: [ :html ]
      )
      FileUtils.mkdir_p(Rails.root.join("tmp"))

      html_file_id = "engagement_report_#{@report.id}.html"


      html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")


      File.open(html_save_path, 'wb') do |file|
        file << html
      end


      html_s3 = upload_file_to_s3("engagement_reports/html/#{html_file_id}",html_save_path)

      Vger::Resources::Engagement::Report.save_existing(report_id,
        :survey_id => survey_id,
        :user_id => user_id,
        :s3_keys => { :html => html_s3 },
        :status => Vger::Resources::Engagement::Report::Status::UPLOADED
      )

      File.delete(html_save_path)
      JombayNotify::Email.create_from_mail(
        SystemMailer.send_engagement_report(@report.id, @report.report_hash), 
        "send_engagement_report"
      )
    end
    
    def set_report_status_to_failed
      Vger::Resources::Engagement::Report.save_existing(
        @report_attributes[:id],
        :survey_id => @report_attributes[:survey_id],
        :user_id => @report_attributes[:user_id],
        :status => Vger::Resources::Engagement::Report::Status::FAILED
      )
    end
    
    def error_email_subject
      "Failed to upload engagement report #{@report_attributes[:id]}"
    end
  end
end  
