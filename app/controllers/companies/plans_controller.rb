require "net/http"  
require "uri"

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
  end

  def upgrade_subscription
    company = Vger::Resources::Company.save_existing(@company.id, params[:company].except(:country, :state, :city))
    if company.error_messages.blank? 
      get_company
      process_payment
    else
      flash[:alert] = company.error_messages.join("<br/>").html_safe
      render :action => :contact
    end
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

    def process_payment
      payment_params = {
        :billing_name => @company.name,
        :billing_address => @company.address,
        :billing_city => @company.city,
        :billing_state => @company.state,
        :billing_zip => @company.pincode,
        :billing_country => @company.country,
        :billing_tel => @company.contact_person_mobile,
        :billing_email => @company.admin[:email],
        
        :merchant_param1 => @plan.no_of_assessments,
        :merchant_param2 => (Date.today + @plan.validity_in_months.months),
        :merchant_param3 => @company.id,
        :merchant_param4 => payment_status_subscriptions_url(:auth_token => RequestStore.store[:auth_token]),
        :merchant_param5 => payment_status_company_url(:auth_token => RequestStore.store[:auth_token],:id=>@company.id, :plan_id=> @plan.id),
        
        :customer_id => @company.id,
        :order_id => Time.now.strftime("%Y%m%d%H%M%S"),
        :amount => @plan.price,
        
        :delivery_name => @company.name,
        :delivery_address => @company.address,
        :delivery_city => @company.city,
        :delivery_state => @company.state,
        :delivery_zip => @company.pincode,
        :delivery_country => @company.country,
        :delivery_tel => @company.contact_person_mobile
      }      
      Rails.logger.debug(payment_params)
      
      uri = URI.parse(Rails.application.config.vger["billing"]["url"])
      http = Net::HTTP.new(uri.host, uri.port)
        
      http.use_ssl = true
      
      unless Rails.env.production?
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      post_request = Net::HTTP::Post.new(uri.request_uri)
      post_request.set_form_data(payment_params)
      post_response = http.request(post_request)
      
      Rails.logger.debug(post_response.code)

      case (post_response.code.to_i)
        when 302
          redirect_to post_response["location"]
        else
          redirect_to request.env['HTTP_REFERER']
      end
    end
  end  
end
