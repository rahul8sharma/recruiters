class Recruiters::DashboardController < ApplicationController
  layout "recruiters/dashboard"
  def dashboard
  	# Rails.logger.ap current_user
  	# r = (current_user.leonidas_resource rescue nil)
  	# Rails.logger.ap r
  	# r = current_user.leonidas_resource.company = {
   #     :name => "ABC Corp",
   #     :description => "This is a company for testing",
   #     :address => "Sandbox, Disk - 00xFE345",
   #     :url => "www.testme.com",
   #     :location => {
   #       :geography_id => 43705
   #     }
   #  }
  end
  def job_posting
  	@job = Recruiters::Job.create(:status => 1, :uuid => SecureRandom.hex(3))
  	redirect_to edit_recruiters_jobs_path(:id => @job.uuid, :section => "job_details")
  end
end
