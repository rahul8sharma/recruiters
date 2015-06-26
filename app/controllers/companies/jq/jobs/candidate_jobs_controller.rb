class Companies::Jq::Jobs::CandidateJobsController < ApplicationController
  layout 'jq'
  before_filter :get_company, :get_job
  
  def index
    order = params[:order_by] || "default"
    order_type = params[:order_type] || "ASC"
    joins = []
    case order
      when "default"
        order = "jq_candidate_jobs.created_at DESC"
      when "name"
        joins << :candidate
        order = "candidates.name #{order_type}"
      when "created_at"
        order = "jq_candidate_jobs.created_at #{order_type}"
    end
    query_options = {
      candidate_status: Vger::Resources::Jq::CandidateJob::CandidateStatus::APPLIED,
      job_id: @job.id
    }
    scope = Vger::Resources::Jq::CandidateJob.where({
      include: {
        candidate: { include: :location },
      },
      joins: joins,
      order: order,
      page: params[:page],
      per: 10
    })
    
    params[:search] ||= {}
    params[:search] = params[:search].reject{|column,value| value.blank? }
    if params[:search].present?
      query_options.merge!(params[:search])
    end
    scope = scope.where(:query_options => query_options)
    @candidate_jobs = scope.all
    
    @reports = {}   
    @candidate_jobs.each do |candidate_job|
      begin
        report = Vger::Resources::Suitability::CandidateAssessmentReport.get_raw("/suitability/candidate_assessment_reports/#{candidate_job.candidate_id}/jq_report")
        report = Vger::Resources::Suitability::CandidateAssessmentReport.new report[:parsed_data][:data][:candidate_assessment_report]
        @reports[candidate_job.id] = report
      rescue Exception => e
      end
    end
    @all_candidate_jobs_count = Vger::Resources::Jq::CandidateJob.count({ 
      query_options: {
        candidate_status: Vger::Resources::Jq::CandidateJob::CandidateStatus::APPLIED,
        job_id: @job.id
      }
    })
    
    @accepted_candidate_jobs_count = Vger::Resources::Jq::CandidateJob.count({ 
      query_options: {
        candidate_status: Vger::Resources::Jq::CandidateJob::CandidateStatus::APPLIED,
        recruiter_status: Vger::Resources::Jq::CandidateJob::RecruiterStatus::ACCEPTED,
        job_id: @job.id
      }
    })
    
    @rejected_candidate_jobs_count = Vger::Resources::Jq::CandidateJob.count({ 
      query_options: {
        candidate_status: Vger::Resources::Jq::CandidateJob::CandidateStatus::APPLIED,
        recruiter_status: Vger::Resources::Jq::CandidateJob::RecruiterStatus::REJECTED,
        job_id: @job.id
      }
    })
    
    @ignored_candidate_jobs_count = Vger::Resources::Jq::CandidateJob.count({ 
      query_options: {
        candidate_status: Vger::Resources::Jq::CandidateJob::CandidateStatus::APPLIED,
        recruiter_status: Vger::Resources::Jq::CandidateJob::RecruiterStatus::IGNORED,
        job_id: @job.id
      }
    })
  end
  
  def show
    @candidate_job = Vger::Resources::Jq::CandidateJob.find(params[:id],
      include: {
        candidate: { include: {:location => {}}, methods: [:large_profile_picture_url] },
      }
    )
    
    @multimedia_answers = Vger::Resources::Jq::MultimediaAnswer.where(
      query_options: {
        candidate_id: @candidate_job.candidate_id,
        job_id: @candidate_job.job_id
      },
      methods: [:original_attachment_url, :hd_attachment_url, :sd_attachment_url],
      include: {
       :interview_question => {
       }
     }
    )
    begin
      @report = Vger::Resources::Suitability::CandidateAssessmentReport.get_raw("/suitability/candidate_assessment_reports/#{@candidate_job.candidate_id}/jq_report")
      @report = Vger::Resources::Suitability::CandidateAssessmentReport.new @report[:parsed_data][:data][:candidate_assessment_report]
    rescue Exception => e
    end
  end
  
  def update
    status = params[:status] == "ACCEPT" ? Vger::Resources::Jq::CandidateJob::RecruiterStatus::ACCEPTED : 
                                  Vger::Resources::Jq::CandidateJob::RecruiterStatus::REJECTED
    @candidate_job = Vger::Resources::Jq::CandidateJob.save_existing(params[:id], { 
      recruiter_status: status
    })
    
    redirect_to company_jq_job_candidate_job_path(params[:company_id], params[:job_id], params[:id])
  end
  
  private
  
  def get_company
    @company = Vger::Resources::Company.find(params[:company_id])
  end
  
  def get_job
    @job = Vger::Resources::Jq::Job.find(params[:job_id], include: { locations: { methods: [:address] } })
  end
end
