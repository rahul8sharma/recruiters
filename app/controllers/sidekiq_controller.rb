class SidekiqController < ApplicationController
  before_filter :check_superadmin
  before_filter :check_auth_token

  def generate_factor_benchmarks
    Vger::Resources::Candidate.get("/sidekiq/queue-job?job_klass=SuitabilityFactorBenchmarker")
    render :json => { :status => "Job Started" }
  end

  def generate_mrf_scores
    Vger::Resources::Candidate.get("/sidekiq/queue-job?job_klass=Mrf::MrfScorer")
    render :json => { :status => "Job Started" }
  end
  
  def queue_job
    Vger::Resources::Candidate.get("/sidekiq/queue-job?#{params.to_param}")
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
      Suitability::ReportUploader.perform_async(report_data, params[:auth_token], params[:patch])
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
      Mrf::ReportUploader.perform_async(report_data, params[:auth_token], params[:patch])
    end
    render :json => { :status => "Job Started", :reports => reports.map(&:id) }
  end
  
  def upload_mrf_group_reports
    reports = Vger::Resources::Mrf::AssessmentReport.where(
      :query_options => {
        :status =>  Vger::Resources::Mrf::AssessmentReport::Status::SCORED
      },
      :include => [:assessment],
      :page => params[:page],
      :per => 25
    ).all.to_a

    reports.each do |report|
      report_data = {
        :id => report.id,
        :assessment_id => report.assessment_id,
        :company_id => report.assessment.company_id
      }
      Mrf::GroupReportUploader.perform_async(report_data, params[:auth_token], params[:patch])
    end
    render :json => { :status => "Job Started", :reports => reports.map(&:id) }
  end

  def upload_engagement_reports
    reports = Vger::Resources::Engagement::Report.where(
      :query_options => {
        :status => Vger::Resources::Engagement::Report::Status::SCORED
      },
      :include =>[:survey],
      :page => params[:page],
      :per => 25
    ).all.to_a


    reports.each do |report|
      report_data = {
        :id => report.id,
        :survey_id => report.survey.id,
        :candidate_id => report.candidate_id,
        :company_id => report.survey.company_id

      }
      Engagement::ReportUploader.perform_async(report_data,params[:auth_token],params[:patch])
    end
    render :json => { :status => "Job Started",:reports => reports.map(&:id)}
  end


  def upload_exit_reports
    reports = Vger::Resources::Exit::Report.where(
      :query_options => {
        :status => Vger::Resources::Exit::Report::Status::SCORED
      },
      :include =>[:survey],
      :page => params[:page],
      :per => 25
    ).all.to_a


    reports.each do |report|
      report_data = {
        :id => report.id,
        :survey_id => report.survey.id,
        :candidate_id => report.candidate_id,
        :company_id => report.survey.company_id

      }
      Exit::ReportUploader.perform_async(report_data,params[:auth_token],params[:patch])
    end
    render :json => { :status => "Job Started",:reports => reports.map(&:id)}
  end
  
  def upload_exit_group_reports
    reports = Vger::Resources::Exit::GroupReport.where(
      :query_options => {
        :status => Vger::Resources::Exit::GroupReport::Status::SCORED
      },
      :include =>[:survey],
      :page => params[:page],
      :per => 25
    ).all.to_a


    reports.each do |report|
      report_data = {
        :id => report.id,
        :survey_id => report.survey.id,
        :company_id => report.survey.company_id
      }
      Exit::GroupReportUploader.perform_async(report_data,params[:auth_token],params[:patch])
    end
    render :json => { :status => "Job Started",:reports => reports.map(&:id)}
  end


  def upload_training_requirements_reports
    assessment_reports = Vger::Resources::Suitability::AssessmentReport.where(:query_options => {
                    :status => Vger::Resources::Suitability::AssessmentReport::Status::SCORED,
                    :report_type => Vger::Resources::Suitability::CustomAssessment::ReportType::TRAINING_REQUIREMENT
                  }, methods: [:company_id]).all.to_a
    job_ids = {}
    assessment_reports.each do |assessment_report|
      report_data = {
        :assessment_id => assessment_report.assessment_id,
        :assessment_report_id => assessment_report.id,
        :company_id => assessment_report.company_id
      }
      job_ids[assessment_report.assessment_id] = assessment_report.id
      Suitability::TrainingRequirementsReportUploader.perform_async(report_data, params[:auth_token])
    end
    render :json => { :status => "Job Started", :report_ids => job_ids }
  end

  def upload_training_requirement_groups_reports
    training_requirement_group_reports = Vger::Resources::Suitability::AssessmentGroupReport.where(:query_options => {
                    :status => Vger::Resources::Suitability::AssessmentGroupReport::Status::SCORED,
                    :report_type => Vger::Resources::Suitability::AssessmentGroup::ReportType::TRAINING_REQUIREMENT
                  }, methods: [:company_id]).all.to_a
    job_ids = {}
    training_requirement_group_reports.each do |training_requirement_group_report|
      report_data = {
        :training_requirement_group_id => training_requirement_group_report.assessment_group_id,
        :training_requirement_group_report_id => training_requirement_group_report.id,
        :company_id => training_requirement_group_report.company_id
      }
      job_ids[training_requirement_group_report.assessment_group_id] = training_requirement_group_report.id
      Suitability::TrainingRequirementGroupReportUploader.perform_async(report_data, params[:auth_token])
    end
    render :json => { :status => "Job Started", :job_ids => job_ids }
  end

  def upload_benchmark_reports
    assessment_reports = Vger::Resources::Suitability::AssessmentReport.where(:query_options => {
                    :status => Vger::Resources::Suitability::AssessmentReport::Status::SCORED,
                    :report_type => Vger::Resources::Suitability::CustomAssessment::ReportType::BENCHMARK
                  }).all.to_a
    job_ids = []
    assessment_reports.each do |assessment_report|
      report_data = {
        :assessment_id => assessment_report.assessment_id,
        :assessment_report_id => assessment_report.id
      }
      job_ids << Suitability::BenchmarkReportUploader.perform_async(report_data, params[:auth_token])
    end
    render :json => { :status => "Job Started", :job_ids => job_ids }
  end
  
  protected
  
  def check_auth_token
    if params[:auth_token].blank?
      render :json => { :status => :unauthorized }
      return 
    end
  end
end
