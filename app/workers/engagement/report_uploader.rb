module Engagement
  class ReportUploader < ::ReportUploader
    def perform(report_data, auth_token, patch = {})
      tries = 0
      patch ||= {}
      report_data = HashWithIndifferentAccess.new report_data
      report_id = report_data["id"]
      survey_id = report_data["survey_id"]
      candidate_id = report_data["candidate_id"]
      company_id = report_data["company_id"]
      patch ||= {}
      begin
        RequestStore.store[:auth_token] = get_token({ auth_token: auth_token }).token
        puts "Getting Report #{report_id}"
        params = {}
        candidate_survey = Vger::Resources::Engagement::CandidateSurvey.where(:survey_id => survey_id,
                      :query_options => { :candidate_id => candidate_id }).all[0]
        params[:survey_id] = survey_id
        params[:candidate_id] = candidate_id
        params[:company_id] = company_id
        @report = Vger::Resources::Engagement::Report.find(report_id, params)


        @report.report_hash = @report.report_data if patch.empty?
        if @report.status == Vger::Resources::Engagement::Report::Status::UPLOADING
         puts "Report #{report_id} is being uploaded already..."
         return
        end

        Vger::Resources::Engagement::Report.save_existing(report_id,
          :survey_id => survey_id,
          :candidate_id => candidate_id,
          :status => Vger::Resources::Engagement::Report::Status::UPLOADING
        )

        candidate_name = @report.report_hash[:candidate][:name]
        company_name = @report.report_hash[:company][:name]
        @report.report_hash[:company_id] = company_id
        @report.report_hash[:survey_id] = survey_id
        @report.report_hash[:candidate_id] = candidate_id
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
          :candidate_id => candidate_id,
          :s3_keys => { :html => html_s3 },
          :status => Vger::Resources::Engagement::Report::Status::UPLOADED
        )

        File.delete(html_save_path)
        JombayNotify::Email.create_from_mail(SystemMailer.send_engagement_report(@report.id, @report.report_hash), "send_engagement_report")
      rescue Exception => e
        Rails.logger.debug e.message
        puts e.message
        tries = tries + 1
        if tries < 5
          retry
        else
          Vger::Resources::Engagement::Report.save_existing(report_id,
            :survey_id => survey_id,
            :candidate_id => candidate_id,
            :status => Vger::Resources::Engagement::Report::Status::FAILED
          ) rescue nil
        end
        JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("Report Uploader","Failed to upload engagement report #{report_id}",{
          :report => {
            :status => "Failed",
            :survey_id => survey_id,
            :candidate_id => candidate_id,
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
