class Recruiters::CompanyProfilesController < ApplicationController
  layout "recruiters/company_profiles"

  def new
  end

  def create_new
  	current_user.leonidas_resource.company = params[:company]
    current_user.leonidas_resource.recruiter_type = Vger::Spartan::Vanguard::RecruiterType.find_by_name(params[:type])
  end

  def show
  	@company = current_user.leonidas_resource.company
    @company_type = current_user.leonidas_resource.recruiter_type.name
  end

  def edit
    @company = current_user.leonidas_resource.company
    @company_type = current_user.leonidas_resource.recruiter_type.name
  end

  def update
  end
end
