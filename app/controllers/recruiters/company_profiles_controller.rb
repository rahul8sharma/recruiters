class Recruiters::CompanyProfilesController < ApplicationController
  layout "recruiters/company_profiles"

  def new
  end

  def create_new
  	current_user.leonidas_resource.company = {
       :name => params[:company][:name],
       :description => params[:company][:description],
       :address => params[:company][:address],
       :url => params[:company][:url],
       :location => {
         :geography_id => params[:company][:location][:geography_id]
       }
    }
     # current_user.leonidas_resource.recruiter_type = params[:company][:type].to_i
  end

  def show
  	@company = current_user.leonidas_resource.company
  end

  def edit
  end

  def update
  end
end
