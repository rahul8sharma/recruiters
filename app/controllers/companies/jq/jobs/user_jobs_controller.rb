class Companies::Jq::Jobs::UserJobsController < ApplicationController
  layout 'jq'
  before_filter :get_company, :get_job
  
  def index
    order = params[:order_by] || "default"
    order_type = params[:order_type] || "ASC"
    joins = []
    case order
      when "default"
        order = "jq_user_jobs.created_at DESC"
      when "name"
        joins << :user
        order = "jombay_users.name #{order_type}"
      when "created_at"
        order = "jq_user_jobs.created_at #{order_type}"
    end
    query_options = {
      user_status: Vger::Resources::Jq::UserJob::UserStatus::APPLIED,
      job_id: @job.id
    }
    scope = Vger::Resources::Jq::UserJob.where({
      include: {
        user: { include: :location },
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
    @user_jobs = scope.all
    
    @reports = {}   
    @user_jobs.each do |user_job|
      begin
        report = Vger::Resources::Suitability::UserAssessmentReport.get_raw("/suitability/user_assessment_reports/#{user_job.user_id}/jq_report")
        report = Vger::Resources::Suitability::UserAssessmentReport.new report[:parsed_data][:data][:user_assessment_report]
        @reports[user_job.id] = report
      rescue Exception => e
      end
    end
    @all_user_jobs_count = Vger::Resources::Jq::UserJob.count({ 
      query_options: {
        user_status: Vger::Resources::Jq::UserJob::UserStatus::APPLIED,
        job_id: @job.id
      }
    })
    
    @accepted_user_jobs_count = Vger::Resources::Jq::UserJob.count({ 
      query_options: {
        user_status: Vger::Resources::Jq::UserJob::UserStatus::APPLIED,
        recruiter_status: Vger::Resources::Jq::UserJob::RecruiterStatus::ACCEPTED,
        job_id: @job.id
      }
    })
    
    @rejected_user_jobs_count = Vger::Resources::Jq::UserJob.count({ 
      query_options: {
        user_status: Vger::Resources::Jq::UserJob::UserStatus::APPLIED,
        recruiter_status: Vger::Resources::Jq::UserJob::RecruiterStatus::REJECTED,
        job_id: @job.id
      }
    })
    
    @ignored_user_jobs_count = Vger::Resources::Jq::UserJob.count({ 
      query_options: {
        user_status: Vger::Resources::Jq::UserJob::UserStatus::APPLIED,
        recruiter_status: Vger::Resources::Jq::UserJob::RecruiterStatus::IGNORED,
        job_id: @job.id
      }
    })
  end
  
  def show
    @user_job = Vger::Resources::Jq::UserJob.find(params[:id],
      include: {
        user: { include: {:location => {}}, methods: [:large_profile_picture_url] },
      }
    )
    
    @multimedia_answers = Vger::Resources::Jq::MultimediaAnswer.where(
      query_options: {
        user_id: @user_job.user_id,
        job_id: @user_job.job_id
      },
      methods: [:original_attachment_url, :hd_attachment_url, :sd_attachment_url],
      include: {
       :interview_question => {
       }
     }
    )
    begin
      @report = Vger::Resources::Suitability::UserAssessmentReport.get_raw("/suitability/user_assessment_reports/#{@user_job.user_id}/jq_report")
      @report = Vger::Resources::Suitability::UserAssessmentReport.new @report[:parsed_data][:data][:user_assessment_report]
    rescue Exception => e
    end
  end
  
  def update
    status = params[:status] == "ACCEPT" ? Vger::Resources::Jq::UserJob::RecruiterStatus::ACCEPTED : 
                                  Vger::Resources::Jq::UserJob::RecruiterStatus::REJECTED
    @user_job = Vger::Resources::Jq::UserJob.save_existing(params[:id], { 
      recruiter_status: status
    })
    
    redirect_to company_jq_job_user_job_path(params[:company_id], params[:job_id], params[:id])
  end
  
  private
  
  def get_company
    @company = Vger::Resources::Company.find(params[:company_id])
  end
  
  def get_job
    @job = Vger::Resources::Jq::Job.find(params[:job_id], include: { locations: { methods: [:address] } })
  end
end
