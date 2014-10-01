class SidekiqController < ApplicationController
  before_filter :check_superadmin

  def generate_factor_benchmarks
    Vger::Resources::Candidate.get("/sidekiq/queue-job?job_klass=SuitabilityFactorBenchmarker")
    render :json => { :status => "Job Started" }
  end
  
  def generate_mrf_scores
    Vger::Resources::Candidate.get("/sidekiq/queue-job?job_klass=Mrf::MrfScorer")
    render :json => { :status => "Job Started" }
  end

  def upload_reports
    reports = Vger::Resources::Suitability::CandidateAssessmentReport.where(
      :query_options => {
        :status =>  Vger::Resources::Suitability::CandidateAssessmentReport::Status::SCORED
      },
      :page => params[:page],
      :per => 25,
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
      ReportUploader.perform_async(report_data, RequestStore.store[:auth_token], params[:patch])
    end
    render :json => { :status => "Job Started", :reports => reports.map(&:id) }
  end

  def upload_mrf_reports
    reports = Vger::Resources::Mrf::Report.where(
      :query_options => {
        :status =>  Vger::Resources::Mrf::Report::Status::SCORED
      },
      :include => [:assessment],
      :page => params[:page],
      :per => 25
    ).all.to_a
    
    reports.each do |report|
      report_data = {
        :id => report.id,
        :assessment_id => report.assessment_id,
        :candidate_id => report.candidate_id,
        :company_id => report.assessment.company_id
      }
      MrfReportUploader.perform_async(report_data, RequestStore.store[:auth_token], params[:patch])
    end
    render :json => { :status => "Job Started", :reports => reports.map(&:id) }  
  end

  
  def upload_training_requirements_reports
    assessment_reports = Vger::Resources::Suitability::AssessmentReport.where(:query_options => { 
                    :status => Vger::Resources::Suitability::AssessmentReport::Status::NEW, 
                    :report_type => Vger::Resources::Suitability::CustomAssessment::ReportType::TRAINING_REQUIREMENT
                  }).all.to_a
    job_ids = {}
    assessment_reports.each do |assessment_report|
      report_data = {
        :assessment_id => assessment_report.assessment_id,
        :assessment_report_id => assessment_report.id
      }
      job_ids[assessment_report.assessment_id] = assessment_report.id
      TrainingRequirementsReportUploader.perform_async(report_data, RequestStore.store[:auth_token])
    end
    render :json => { :status => "Job Started", :report_ids => job_ids }
  end
  
  def upload_training_requirement_groups_reports
    training_requirement_group_reports = Vger::Resources::Suitability::AssessmentGroupReport.where(:query_options => { 
                    :status => Vger::Resources::Suitability::AssessmentGroupReport::Status::NEW, 
                    :report_type => Vger::Resources::Suitability::AssessmentGroup::ReportType::TRAINING_REQUIREMENT
                  }).all.to_a
    job_ids = []
    training_requirement_group_reports.each do |training_requirement_group_report|
      report_data = {
        :training_requirement_group_id => training_requirement_group_report.assessment_group_id,
        :training_requirement_group_report_id => training_requirement_group_report.id
      }
      job_ids << TrainingRequirementGroupReportUploader.perform_async(report_data, RequestStore.store[:auth_token])
    end
    render :json => { :status => "Job Started", :job_ids => job_ids }
  end

  def upload_benchmark_reports
    assessment_reports = Vger::Resources::Suitability::AssessmentReport.where(:query_options => { 
                    :status => Vger::Resources::Suitability::AssessmentReport::Status::NEW, 
                    :report_type => Vger::Resources::Suitability::CustomAssessment::ReportType::BENCHMARK
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
      assessment = Vger::Resources::Suitability::CustomAssessment.regenerate_reports(params)
      render :json => { :status => "Job Started", :job_id => assessment.job_id }
    else
      redirect_to report_management_path, alert: "Please specify email and assessment_id."
    end
  end
  
  def regenerate_mrf_reports
    if params[:args][:assessment_id].present? && params[:args][:email].present?
      assessment = Vger::Resources::Mrf::Assessment.regenerate_reports(company_id: params[:args][:company_id], :args => params[:args])
      render :json => { :status => "Job Started", :job_id => assessment.job_id }
    else
      redirect_to report_management_path, alert: "Please specify email and assessment_id."
    end
  end
end
