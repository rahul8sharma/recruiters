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
  
  def upload_training_requirements_reports
    assessment_reports = Vger::Resources::Suitability::AssessmentReport.where(:query_options => { 
                    :status => Vger::Resources::Suitability::AssessmentReport::Status::NEW, 
                    :report_type => Vger::Resources::Suitability::Assessment::ReportType::TRAINING_REQUIREMENT
                  }).all.to_a
    job_ids = []
    assessment_reports.each do |assessment_report|
      report_data = {
        :assessment_id => assessment_report.assessment_id,
        :assessment_report_id => assessment_report.id
      }
      job_ids << TrainingRequirementsReportUploader.perform_async(report_data, RequestStore.store[:auth_token])
    end
    render :json => { :status => "Job Started", :job_ids => job_ids }
  end

  def upload_benchmark_reports
    assessment_reports = Vger::Resources::Suitability::AssessmentReport.where(:query_options => { 
                    :status => Vger::Resources::Suitability::AssessmentReport::Status::NEW, 
                    :report_type => Vger::Resources::Suitability::Assessment::ReportType::BENCHMARK
                  }).all.to_a
    job_ids = []
    assessment_reports.each do |assessment_report|
      report_data = {
        :assessment_id => assessment_report.assessment_id,
        :assessment_report_id => assessment_report.id
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
