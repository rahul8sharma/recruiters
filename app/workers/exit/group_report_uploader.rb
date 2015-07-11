module Exit
  class GroupReportUploader < ::ReportUploader
    def perform(report_data, auth_token, patch = {})
      tries = 0
      patch ||= {}
      report_data = HashWithIndifferentAccess.new report_data
      report_id = report_data["id"]
      survey_id = report_data["survey_id"]
      company_id = report_data["company_id"]
      patch ||= {}
      begin
        RequestStore.store[:auth_token] = get_token({ auth_token: auth_token }).token
        puts "Getting Report #{report_id}"
        params = {}
        params[:survey_id] = survey_id
        params[:company_id] = company_id
        @report = Vger::Resources::Exit::GroupReport.find(report_id, params)
        @report.report_hash = @report.report_data if patch.empty?
        if @report.status == Vger::Resources::Exit::GroupReport::Status::UPLOADING
         puts "Report #{report_id} is being uploaded already..."
         return
        end

        Vger::Resources::Exit::GroupReport.save_existing(report_id,
          :survey_id => survey_id,
          :status => Vger::Resources::Exit::GroupReport::Status::UPLOADING
        )

        company_name = @report.report_hash[:company][:name]
        @report.report_hash[:company_id] = company_id
        @report.report_hash[:survey_id] = survey_id
        @report.report_hash[:report_id] = @report.id
        @report.report_hash[:name] = @report.name

        report_status = {
          :errors => [],
          :message => "",
          :status => "success"
        }

        @view_mode = "html"
        html = render_to_string(
           template: "exit/surveys/group_reports/exit_report.html.haml",
           layout: "layouts/exit_group_report.html.haml",
           handlers: [ :haml ],
           formats: [ :html ]
        )
        FileUtils.mkdir_p(Rails.root.join("tmp"))

        html_file_id = "exit_group_report_#{@report.id}.html"
        html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")

        File.open(html_save_path, 'wb') do |file|
          file << html
        end

        html_s3 = upload_file_to_s3("exit_group_reports/html/#{html_file_id}",html_save_path)

        Vger::Resources::Exit::GroupReport.save_existing(report_id,
          :survey_id => survey_id,
          :s3_keys => { :html => html_s3 },
          :status => Vger::Resources::Exit::GroupReport::Status::UPLOADED
        )

        File.delete(html_save_path)
        JombayNotify::Email.create_from_mail(ExitMailer.send_exit_group_report(@report.id, @report.report_hash), "send_exit_group_report")
      rescue Exception => e
        Rails.logger.debug e.message
        puts e.message
        tries = tries + 1
        if tries < 5
          retry
        else
          Vger::Resources::Exit::GroupReport.save_existing(report_id,
            :survey_id => survey_id,
            :status => Vger::Resources::Exit::GroupReport::Status::FAILED
          )
        end
        JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("Exit Group Report Uploader","Failed to upload exit report #{report_id}",{
          :report => {
            :status => "Failed",
            :survey_id => survey_id,
            :report_id => report_id
          },
          :errors => {
            :backtrace => [e.message] + e.backtrace[0..20]
          }
        }), "notify_report_status")
      end
    end
  end
end
