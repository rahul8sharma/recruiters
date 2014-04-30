class CompaniesController < ApplicationController
  layout "companies"

  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:id]) }
  before_filter :get_company, :except => [ :index, :manage, :import_from_google_drive, :import_to_google_drive]
  before_filter :get_companies, :only => [ :index ]
  before_filter :get_countries, :only => [ :edit, :update ]

  def api_resource
    Vger::Resources::Company
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def reports
    order = params[:order_by] || "completed_at"
    order_type = params[:order_type] || "DESC"
    case order
      when "id"
        order = "candidates.id #{order_type}"
      when "name"
        order = "candidates.name #{order_type}"
      else
        order = "#{order} #{order_type}"
    end
    @candidate_assessments = Vger::Resources::Companies::CandidateAssessment.where(
      :company_id => @company.id, 
      :joins => [:candidate_assessment_reports, :candidate, :assessment],
      :include => [:candidate_assessment_reports, :candidate, :assessment],
      :order => order
    ).where(
      :query_options => { 
        "suitability_candidate_assessment_reports.status" => Vger::Resources::Suitability::CandidateAssessmentReport::Status::UPLOADED 
      }, :page => params[:page], :per => 5
    ).all
  end
  
  def landing
    count = Vger::Resources::Suitability::CustomAssessment.count(:query_options => { company_id: current_user.company_id })
    if count <= 1
      redirect_to home_company_path(current_user.company_id) 
    else
      redirect_to company_custom_assessments_path(current_user.company_id)  
    end
  end

  def home
    standard_assessment_uid = Rails.application.config.signup[:standard_assessment_uid]  
    @standard_assessments = Vger::Resources::Suitability::StandardAssessment.where(:query_options => "uid != '#{standard_assessment_uid}'").all
    @custom_assessment = Vger::Resources::Suitability::CustomAssessment.where(:joins => :standard_assessment, :query_options => { "suitability_standard_assessments.uid" => standard_assessment_uid, company_id: @company.id }).all.to_a.first
    if @custom_assessment
      admin_candidate_email = "#{current_user.email.split("@")[0]}+candidate@#{current_user.email.split("@")[1]}"
      @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(:joins => [:candidate], :assessment_id => @custom_assessment.id, :query_options => { "candidates.email" => admin_candidate_email }, methods: [:url], :include => [:candidate_assessment_reports]).all.to_a.first
    end
  end
  
  
  def add_subscription
    if !@company.admin
      flash[:error] = "Admin account is not created for #{@company.name}. Please create admin acoount before adding a subscription." 
      redirect_to company_path(@company)
    end
    @callback_url = payment_status_subscriptions_url(:auth_token => RequestStore.store[:auth_token])
    # @redirect_url = payment_status_subscriptions_url
    # the post request to this route will come in via :
    # from the add subscription form on the subscription view
    # code to generate URL for the billing app
    # believed route to this action via line 36 of routes.rb
    # actual route to this action via line 199 of routes.rb
  end

  def index
  end

  def edit
    
  end
  
  def update
    @company = Vger::Resources::Company.save_existing(@company.id, params[:company].except(:city, :state, :country))
    if @company.error_messages.blank?
      redirect_to add_subscription_company_path(@company), notice: "Company details updated successfully!"
    else
      render :action => :edit
    end
  end

  def manage
    render :layout => "admin"
  end

	def import_from_google_drive
    Vger::Resources::Company\
      .import_from_google_drive(params[:import])
    redirect_to manage_companies_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::Company\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name","company_code", "website", "hq_address", "enable_recommendation", "enable_lie_detection", "enable_factor_consistency", "enable_response_reliability", "enable_overall_consistency", "enable_feedback"]))
    redirect_to manage_companies_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def show
    if @company.hq_location_id
      @hq_location = Vger::Resources::Location.find(@company.hq_location_id, :methods => [ :address ])
    end
  end

  def candidate
  end

  protected

  def get_company
    methods = []
    if Rails.application.config.statistics[:load_assessment_statistics]
      methods.push :assessment_statistics
    end
    @company = Vger::Resources::Company.find(params[:id], :include => [:subscription, :admin], :methods => methods)
  end

  def get_companies
    methods = []
    order_by = params[:order_by] || "created_at"
    order_type = params[:order_type] || "DESC"
    if Rails.application.config.statistics[:load_assessmentwise_statistics]
      methods.push :assessmentwise_statistics
    end
    @companies = Vger::Resources::Company.where(:page => params[:page], :per => 5, :order => "#{order_by} #{order_type}", :include => [:subscription], :methods => methods)
  end
  
  def get_countries
    @countries =  Vger::Resources::Location.where(:query_options => { :location_type => Vger::Resources::Location::LocationType::COUNTRY }).all.collect{|location| [location.name,location.id] }
  end
end

