class Recruiters::CompanyProfilesController < ApplicationController
  before_filter :redirect_if_not_logged_in!
  
  layout "recruiters/company_profiles"

  def new
    @redirect = params[:redirect_to] || ""
    if current_user.leonidas_resource.company.present?
      @company = current_user.leonidas_resource.company
      redirect_to recruiters_company_profile_path(:id => @company.id)
    end
  end

  def create_new
    @redirect = params[:redirect]
    current_user.leonidas_resource.company = params[:company]
    current_user.leonidas_resource.recruiter_type = Vger::Spartan::Vanguard::RecruiterType.find(params[:type])
    redirect_to @redirect
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
    current_user.leonidas_resource.company = params[:company]
    redirect_to recruiters_company_profile_path(:id => current_user.leonidas_resource.company.id)
  end
end
