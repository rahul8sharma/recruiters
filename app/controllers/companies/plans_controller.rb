class Companies::PlansController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_plan
  before_filter :get_company
  before_filter :get_countries
  

  layout "companies"
  
  def review
  end

  def payment_status
  	@success = true
  end

  def contact
    if !@company.admin
      flash[:error] = "Admin account is not created for #{@company.name}. Please create admin acoount before adding a subscription." 
      redirect_to company_path(@company)
    end
    @callback_url = payment_status_subscriptions_url(:auth_token => RequestStore.store[:auth_token])
  end

  protected
    
    def get_company
      @company =  Vger::Resources::Company.find(params[:id], :include => [:admin])
    end

    def get_plan
      @plan = Vger::Resources::Plan.find(params[:plan_id])
    end

    def get_countries
      @countries =  Vger::Resources::Location.where(:query_options => { :location_type => "country" }).all.collect{|location| [location.name,location.id] }
    end

end
