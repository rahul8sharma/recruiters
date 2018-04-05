class Companies::Jq::JobsController < ApplicationController
  layout 'jq'
  
  before_action :get_company
  
  def index
    @jobs = Vger::Resources::Jq::Job.where(query_options: { 
      company_id: params[:company_id] 
    }, include: { :locations => { methods: :address } }).where(page: params[:page], per: 10).all
    
    @ignored_user_jobs = Vger::Resources::Jq::UserJob.group_count({ 
      query_options: {
        user_status: Vger::Resources::Jq::UserJob::UserStatus::APPLIED,
        recruiter_status: Vger::Resources::Jq::UserJob::RecruiterStatus::IGNORED,
        job_id: @jobs.map(&:id)
      },
      :group => [ :job_id ],
      :select => [ :job_id ] 
    })
    
    @user_jobs = Vger::Resources::Jq::UserJob.group_count({ 
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
    
    @ignored_user_jobs_count = Vger::Resources::Jq::UserJob.count({ 
      query_options: {
        user_status: Vger::Resources::Jq::UserJob::UserStatus::APPLIED,
        recruiter_status: Vger::Resources::Jq::UserJob::RecruiterStatus::IGNORED,
        job_id: @job.id
      }
    })
    
    @all_user_jobs_count = Vger::Resources::Jq::UserJob.count({ 
      query_options: {
        user_status: Vger::Resources::Jq::UserJob::UserStatus::APPLIED,
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
