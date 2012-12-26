class Recruiters::DashboardController < ApplicationController
  layout "recruiters/dashboard"
  def dashboard
  	@jobs = {
      :incomplete => Recruiters::Job.find(:status => Recruiters::Job::STATUSES::INCOMPLETE, :posted_by => current_user.sid).paginate(:page => 1, :per_page => 2),
      :pending => Recruiters::Job.find(:status => Recruiters::Job::STATUSES::PENDING, :posted_by => current_user.sid).paginate(:page => 1, :per_page => 2),
      :open => Recruiters::Job.open(current_user.leonidas_resource.id, {:pagination => {:page => 1, :per_page => 2}}),
      :closed => Recruiters::Job.closed(current_user.leonidas_resource.id, {:pagination => {:page => 1, :per_page => 2}})
    }

    Rails.logger.ap @jobs
  end

  # def get_leo_jobs(status)
  #   jobs = Vger::Spartan::Opus::Recommendation.traverse({
  #                         :source_nodes => [{
  #                           "id" => current_user.leonidas_resource.id,
  #                           "relationship" => "posts_out"
  #                         }],
  #                         :options => {
  #                           "bucket_type" => "Opus::Job",
  #                           "active" => status
  #                         },
  #                         :pagination => {
  #                           :page => 1,
  #                           :per_page => 2
  #                         },
  #                         :visible => true,
  #                         :order => "updated_at DESC",
  #                         :without_cache => true,
  #                         :plain_fetch => true
  #           }.merge(options[:pagination] || {}))
  # end
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
