module Exit
  class ReportUploader < ::ReportUploader
    def upload_report
      report_id = @report_attributes["id"]
      survey_id = @report_attributes["survey_id"]
      user_id = @report_attributes["user_id"]
      company_id = @report_attributes["company_id"]
      puts "Getting Report #{report_id}"
      params = {}
      user_survey = Vger::Resources::Exit::UserSurvey.where(:survey_id => survey_id,
                    :query_options => { :user_id => user_id }).all[0]
      params[:survey_id] = survey_id
      params[:user_id] = user_id
      params[:company_id] = company_id
      @report = Vger::Resources::Exit::Report.find(report_id, params)
      @report.report_hash = @report.report_data
      
      if @report.status == Vger::Resources::Exit::Report::Status::UPLOADING
       puts "Report #{report_id} is being uploaded already..."
       return
      end

      Vger::Resources::Exit::Report.save_existing(report_id,
        :survey_id => survey_id,
        :user_id => user_id,
        :status => Vger::Resources::Exit::Report::Status::UPLOADING
      )

      user_name = @report.report_hash[:user][:name]
      company_name = @report.report_hash[:company][:name]
      @report.report_hash[:company_id] = company_id
      @report.report_hash[:survey_id] = survey_id
      @report.report_hash[:user_id] = user_id
      @report.report_hash[:report_id] = @report.id

      report_status = {
        :errors => [],
        :message => "",
        :status => "success"
      }

      @view_mode = "html"
      html =  ApplicationController.render(
         template: "exit/surveys/reports/exit_report.html.haml",
         layout: "layouts/exit_report.html.haml",
         handlers: [ :haml ],
         formats: [ :html ],
         assigns: { report: @report, view_mode: @view_mode, report_attributes: @report_attributes }
      )
      FileUtils.mkdir_p(Rails.root.join("tmp"))

      html_file_id = "exit_report_#{@report.id}.html"


      html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")


      File.open(html_save_path, 'wb') do |file|
        file << html
      end

      html_s3 = upload_file_to_s3("exit_reports/html/#{html_file_id}",html_save_path)

      Vger::Resources::Exit::Report.save_existing(report_id,
        :survey_id => survey_id,
        :user_id => user_id,
        :s3_keys => { :html => html_s3 },
        :status => Vger::Resources::Exit::Report::Status::UPLOADED
      )

      File.delete(html_save_path)
      JombayNotify::Email.create_from_mail(ExitMailer.send_exit_report(@report.id, @report.report_hash), "send_exit_report")
    end
    
    def set_report_status_to_failed
      Vger::Resources::Exit::Report.save_existing(
        @report_attributes[:id],
        :survey_id => @report_attributes[:survey_id],
        :user_id => @report_attributes[:user_id],
        :status => Vger::Resources::Exit::Report::Status::FAILED
      )
    end
    
    def error_email_subject
      "Failed to upload exit report #{@report_attributes[:id]}"
    end
  end
end  
