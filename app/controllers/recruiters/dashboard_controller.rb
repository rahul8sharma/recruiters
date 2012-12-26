class Recruiters::DashboardController < ApplicationController
  layout "recruiters/dashboard"
  def dashboard
  	@jobs = {
      :incomplete => Recruiters::Job.find(:status => Recruiters::Job::STATUSES::INCOMPLETE, :posted_by => current_user.sid).paginate(:page => 1, :per_page => 2),
      :pending => Recruiters::Job.find(:status => Recruiters::Job::STATUSES::PENDING, :posted_by => current_user.sid).paginate(:page => 1, :per_page => 2),
      :open => Recruiters::Job.open(current_user.leonidas_resource.id, {:page => 1, :per_page => 2}),
      :closed => Recruiters::Job.closed(current_user.leonidas_resource.id, {:page => 1, :per_page => 2})
    }

    Rails.logger.ap @jobs
  end

  def job_posting
    @job = Recruiters::Job.create
    
    company = current_user.leonidas_resource.company
    
    if company.present?
      redirect_to edit_recruiters_jobs_path(:id => @job.uuid, :section => "job-details")
    else
      redirect_to new_recruiters_company_profile_path(:redirect_to => edit_recruiters_jobs_path(:id => @job.uuid, :section => "job-details"))
    end

  end
end
