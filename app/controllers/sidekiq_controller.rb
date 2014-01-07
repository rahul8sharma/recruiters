class SidekiqController < ApplicationController
  before_filter :check_superadmin

  def generate_factor_benchmarks
    Vger::Resources::Candidate.get("/sidekiq/queue-job?job_klass=SuitabilityFactorBenchmarker")
    render :json => { :status => "Job Started" }
  end

	def upload_reports
	  reports = Vger::Resources::Suitability::CandidateAssessmentReport.where(
      :query_options => {
        :status =>  Vger::Resources::Suitability::CandidateAssessmentReport::Status::SCORED
      },
      :methods => [
                    :assessment_id,
                    :candidate_id,
                    :company_id
                  ]
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

	def upload_benchmark_reports
	  candidate_assessments = Vger::Resources::Suitability::CandidateAssessment.get("/suitability/candidate_assessments/benchmarked?query_options[status]=#{Vger::Resources::Suitability::CandidateAssessment::Status::BENCHMARKED}").to_a
    job_ids = []
    candidate_assessments.map(&:assessment_id).uniq.each do |assessment_id|
      report_data = {
        :assessment_id => assessment_id,
        :candidate_assessment_ids => candidate_assessments.select{|x| x.assessment_id == assessment_id }.map(&:id)
      }
      job_ids << BenchmarkReportUploader.perform_async(report_data, RequestStore.store[:auth_token])
    end
    render :json => { :status => "Job Started", :job_ids => job_ids }
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
