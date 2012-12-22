class Recruiters::DashboardController < ApplicationController
  layout "recruiters/dashboard"
  def dashboard
  	@jobs = {
      :incomplete => Recruiters::Job.find(:status => 1).paginate(:page => 1, :per_page => 2),
      :pending => Recruiters::Job.find(:status => 2).paginate(:page => 1, :per_page => 2),
      :open => Recruiters::Job.find(:status => 4).paginate(:page => 1, :per_page => 2),
      :closed => Recruiters::Job.find(:status => 5).paginate(:page => 1, :per_page => 2)
    }

  end
  def job_posting
    # Rails.logger.ap current_user
    # Rails.logger.ap current_user.leonidas_resource.company
    # r = current_user.leonidas_resource.company rescue nil
    # Rails.logger.ap r
    # Rails.logger.ap r.present?
    @job = Recruiters::Job.create
    begin
      if current_user.leonidas_resource.company.present?
  	    redirect_to edit_recruiters_jobs_path(:id => @job.uuid, :section => "job-details")
      end
    rescue
      redirect_to new_recruiters_company_profile_path(:redirect_to => edit_recruiters_jobs_path(:id => @job.uuid, :section => "job-details"))
    end
  end
end
