class Companies::Jq::JobsController < ApplicationController
  layout 'jq'
  
  before_filter :get_company
  
  def index
    @jobs = Vger::Resources::Jq::Job.where(query_options: { 
      company_id: params[:company_id] 
    }, include: { :locations => { methods: :address } }).where(page: params[:page], per: 10).all
    
    @ignored_candidate_jobs = Vger::Resources::Jq::CandidateJob.group_count({ 
      query_options: {
        candidate_status: Vger::Resources::Jq::CandidateJob::CandidateStatus::APPLIED,
        recruiter_status: Vger::Resources::Jq::CandidateJob::RecruiterStatus::IGNORED,
        job_id: @jobs.map(&:id)
      },
      :group => [ :job_id ],
      :select => [ :job_id ] 
    })
    
    @candidate_jobs = Vger::Resources::Jq::CandidateJob.group_count({ 
      query_options: {
        job_id: @jobs.map(&:id)
      },
      :group => [ :job_id ],
      :select => [ :job_id ] 
    })
  end
  
  def show
    @job = Vger::Resources::Jq::Job.find(params[:id], 
      include: { 
        :locations => { methods: :address } 
      }
    )
    
    @ignored_candidate_jobs_count = Vger::Resources::Jq::CandidateJob.count({ 
      query_options: {
        candidate_status: Vger::Resources::Jq::CandidateJob::CandidateStatus::APPLIED,
        recruiter_status: Vger::Resources::Jq::CandidateJob::RecruiterStatus::IGNORED,
        job_id: @job.id
      }
    })
    
    @all_candidate_jobs_count = Vger::Resources::Jq::CandidateJob.count({ 
      query_options: {
        candidate_status: Vger::Resources::Jq::CandidateJob::CandidateStatus::APPLIED,
        job_id: @job.id
      }
    })
    
    @interview_questions = Vger::Resources::Jq::InterviewQuestion.where({ 
      query_options: {
        job_id: @job.id
      }
    }).all
  end
  
  def get_company
    @company = Vger::Resources::Company.find(params[:company_id])
  end
end
