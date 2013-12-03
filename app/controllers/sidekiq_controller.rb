class SidekiqController < ApplicationController
  before_filter :check_superadmin
  
	def upload_reports
	  reports = Vger::Resources::Suitability::CandidateAssessmentReport.where(
      :query_options => { 
        :status =>  Vger::Resources::Suitability::CandidateAssessmentReport::Status::SCORED
      },
      :methods => [ :assessment_id, :candidate_id, :company_id ]
    ).all.to_a

    reports.each do |report|
      report_data = {
        :id => report.id,
        :company_id => report.company_id,
        :assessment_id => report.assessment_id,
        :candidate_id => report.candidate_id
      }
      ReportUploader.perform_async(report_data, RequestStore.store[:auth_token])
    end
    render :json => { :status => "Job Started", :reports => reports }
	end
	
	def regenerate_reports
	  if params[:args][:assessment_id].present? && params[:args][:email].present?
	    assessment = Vger::Resources::Suitability::Assessment.regenerate_reports(params)
	    render :json => { :status => "Job Started", :job_id => assessment.job_id }
	  else
	    redirect_to report_management_path, alert: "Please specify email and assessment_id."
	  end
	end
end
