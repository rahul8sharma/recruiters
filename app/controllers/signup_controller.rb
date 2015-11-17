class SignupController < ApplicationController
  layout "companies"
  def sign_up
    redirect_to after_sign_in_path_for and return if current_user
    @countries = Vger::Resources::Location.where(:query_options => { :location_type => Vger::Resources::Location::LocationType::COUNTRY }).all.to_a
    if request.post?
      company_attributes = params[:company]
      company_attributes[:contact_person] = company_attributes[:user_attributes][:name]
      company_attributes[:contact_person_mobile] = company_attributes[:user_attributes][:mobile]
      company_attributes[:user_attributes][:password_confirmation] = company_attributes[:user_attributes][:password]
      @company = Vger::Resources::Company.create(company_attributes)
      if @company.error_messages.present?
        @company.user = Vger::Resources::Admin.new(company_attributes[:user_attributes])
        flash[:error] = @company.error_messages.uniq.join("<br/>").html_safe
      else
        @company.setup({})
        render :action => :sign_up_success
      end
    else
      @company = Vger::Resources::Company.new(params[:company])
      @company.user = Vger::Resources::Admin.new
    end
  end

  def sign_up_success
  end
end
