class SignupController < ApplicationController
  layout "companies"
  def sign_up
    @countries = Vger::Resources::Location.where(:query_options => { :location_type => Vger::Resources::Location::LocationType::COUNTRY }).all.to_a
    if request.post?
      company_attributes = params[:company]
      company_attributes[:contact_person] = company_attributes[:admin_attributes][:name]
      company_attributes[:contact_person_mobile] = company_attributes[:admin_attributes][:mobile]
      company_attributes[:company_code] = Vger::Resources::Company.count + 1
      company_attributes[:admin_attributes][:password_confirmation] = company_attributes[:admin_attributes][:password]
      @company = Vger::Resources::Company.create(company_attributes)
      if @company.error_messages.present?
        @company.admin = Vger::Resources::Admin.new(company_attributes[:admin_attributes])
        flash[:notice] = @company.error_messages.join("<br/>").html_safe
      else
        render :action => :sign_up_success
      end
    else
      @company = Vger::Resources::Company.new(params[:company])
      @company.admin = Vger::Resources::Admin.new
    end
  end
  
  def sign_up_success
  end
end
