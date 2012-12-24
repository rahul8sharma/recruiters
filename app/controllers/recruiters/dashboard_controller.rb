class Recruiters::DashboardController < ApplicationController
  layout "recruiters/dashboard"
  def dashboard
  	@jobs = {
      :incomplete => Recruiters::Job.find(:status => 1, :posted_by => current_user.sid).paginate(:page => 1, :per_page => 2),
      :pending => Recruiters::Job.find(:status => 2, :posted_by => current_user.sid).paginate(:page => 1, :per_page => 2),
      :open => Recruiters::Job.find(:status => 4, :posted_by => current_user.sid).paginate(:page => 1, :per_page => 2),
      :closed => Recruiters::Job.find(:status => 5, :posted_by => current_user.sid).paginate(:page => 1, :per_page => 2)
    }
  end
  def job_posting
    # Rails.logger.ap current_user
    # Rails.logger.ap current_user.leonidas_resource.company
    # r = current_user.leonidas_resource.company rescue nil
    # Rails.logger.ap r
    # Rails.logger.ap r.present?
    @job = Recruiters::Job.create
    
    company = current_user.leonidas_resource.company
    
    if company.present?
      redirect_to edit_recruiters_jobs_path(:id => @job.uuid, :section => "job-details")
    else
      redirect_to new_recruiters_company_profile_path(:redirect_to => edit_recruiters_jobs_path(:id => @job.uuid, :section => "job-details"))
    end

  end
end
