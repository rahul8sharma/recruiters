class SidekiqController < ApplicationController
  before_filter :authenticate_user!
  
	def upload_reports
	  reports = Vger::Resources::Suitability::CandidateAssessmentReport.where(
      :query_options => { 
        :status =>  Vger::Resources::Suitability::CandidateAssessmentReport::Status::SCORED
      }
    ).all.to_a

    reports.each do |report|
      ReportUploader.perform_async(report.id, RequestStore.store[:auth_token])
    end
    render :json => { :status => "Job Started", :reports => reports }
	end
end
