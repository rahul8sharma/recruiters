class CompaniesController < ApplicationController
  layout "companies"

  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:id]) }
  before_filter :get_company, :except => [ :index, :manage, :import_from_google_drive, :import_to_google_drive, :select]
  before_filter :get_companies, :only => [ :index ]
  before_filter :get_countries, :only => [ :edit, :update ]

  def api_resource
    Vger::Resources::Company
  end
  
  def select
    params[:search] ||= {}
    if current_user.company_ids && current_user.company_ids.size > 0
      params[:search] = params[:search].merge({ "companies.id" => current_user.company_ids })
      params[:search] = params[:search].select{|key,val| val.present? }
      order_by = params[:order_by] || "created_at"
      order_type = params[:order_type] || "DESC"
      @companies = Vger::Resources::Company.where(query_options: params[:search], order: "#{order_by} #{order_type}", page: params[:page], per: 10).all
    else
      @companies = []
    end
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def candidates_search
    params[:search] ||= {}
    order = params[:order_by] || "completed_at"
    order_type = params[:order_type] || "DESC"
    case order
      when "id"
        order = "candidates.id #{order_type}"
      when "name"
        order = "candidates.name #{order_type}"
      when "assessment_name"
        order = "suitability_custom_assessments.name #{order_type}"
      when "status"
        order = "suitability_candidate_assessments.status #{order_type}"
      else
        order = "#{order} #{order_type}"
    end
    if params[:search][:candidate_name_or_email].present?
      @candidate_assessments = Vger::Resources::Companies::CandidateAssessment.where(
        company_id: @company.id,
        query_options: {
          "suitability_custom_assessments.company_id" => @company.id
        },
        scopes: { :candidate_email_or_name_like => params[:search][:candidate_name_or_email] },
        joins: [ :assessment, :candidate  ],
        include: [:candidate, :assessment, :candidate_assessment_reports],
        page: params[:page],
        order: order,
        per: 10
      ).all
    elsif params[:search].present?
      @candidate_assessments = []
      flash[:error] = "Please enter an Assessment Taker's name or email address to search!"
    else
      @candidate_assessments = []
    end
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
    count = Vger::Resources::Suitability::CustomAssessment.count(:query_options => { company_id: params[:id] })
    if count <= 1
      redirect_to home_company_path(params[:id]), notice: flash[:notice]
    else
      redirect_to company_custom_assessments_path(params[:id]), notice: flash[:notice]
    end
  end

  def home
    standard_assessment_uid = Rails.application.config.signup[:standard_assessment_uid]
    if params[:show_more_standard_tests]
      @standard_assessments = Vger::Resources::Suitability::StandardAssessment.where(:query_options => "uid != '#{standard_assessment_uid}'").all
    else
      @standard_assessments = Vger::Resources::Suitability::StandardAssessment.where(:query_options => "uid != '#{standard_assessment_uid}'", :page => 1, :per => 6).all
    end
    @custom_assessment = Vger::Resources::Suitability::CustomAssessment.where(:joins => :standard_assessment, :query_options => { "suitability_standard_assessments.uid" => standard_assessment_uid, company_id: @company.id }).all.to_a.first
    if @custom_assessment
      admin_candidate_email = "#{current_user.email.split("@")[0]}+selfassessment@#{current_user.email.split("@")[1]}"
      @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(:joins => [:candidate], :assessment_id => @custom_assessment.id, :query_options => { "candidates.email" => admin_candidate_email }, methods: [:url], :include => [:candidate_assessment_reports]).all.to_a.first
    end
  end


  def add_subscription
    #if !@company.admin
    #  flash[:error] = "Admin account is not created for #{@company.name}. Please create admin acoount before adding a subscription."
    #  redirect_to company_path(@company)
    #end
    #@callback_url = payment_status_subscriptions_url(:auth_token => RequestStore.store[:auth_token])
    # @redirect_url = payment_status_subscriptions_url
    # the post request to this route will come in via :
    # from the add subscription form on the subscription view
    # code to generate URL for the billing app
    # believed route to this action via line 36 of routes.rb
    # actual route to this action via line 199 of routes.rb
    if request.put?
      subscription_data = {
        company_id: @company.id,
        assessments_purchased: params[:merchant_param1],
        price: params[:amount],
        valid_from: Time.now.strftime("%d/%m/%Y"),
        valid_to: params[:merchant_param2],
        added_by_superadmin: true
      }
      job_id = Vger::Resources::Subscription.create(subscription_data)
      flash[:notice] = "Subscription is being added. You should receive an email when the subscription gets added to the system."
      redirect_to company_path(@company)
    end
  end

  def index
    @remaining_invitations = Vger::Resources::Invitation.group_count(
      :query_options => {
        :company_id => @companies.map(&:id),
        :status => Vger::Resources::Invitation::Status::UNLOCKED
      },
      :group => [ :company_id ],
      :select => [ :company_id ]
    )

    @invitations = Vger::Resources::Invitation.group_count(
      :query_options => {
        :company_id => @companies.map(&:id)
      },
      :group => [ :company_id ],
      :select => [ :company_id ]
    )

    @subscriptions = Vger::Resources::Subscription.group_count(
      :query_options => {
        :company_id => @companies.map(&:id)
      },
      :group => [ :company_id ],
      :select => [ :company_id ]
    )
    @active_subscriptions = Vger::Resources::Subscription.group_count(
      :query_options => {
        :company_id => @companies.map(&:id)
      },
      :scopes => { :active => nil },
      :group => [ :company_id ],
      :select => [ :company_id ]
    )
  end

  def edit

  end

  def update  
    file = params[:company][:logo]
    if file
      key = "companies/logos/#{@company.id}-#{file.original_filename}"
      content_type = file.content_type
      obj = S3Utils.upload(key, file.read, content_type: content_type, acl: "public-read")
      url = obj.public_url({secure: false}).to_s
      params[:company][:logo] = url
    end
    @company = Vger::Resources::Company.save_existing(@company.id, params[:company].except(:city, :state, :country))
    if @company.error_messages.blank?
      obj.delete if file
      redirect_to company_path(@company), notice: "Company details updated successfully!"
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
      .export_to_google_drive(params[:export].merge(:columns => ["id","name", "website", "hq_address"]))
    redirect_to manage_companies_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def export_companies
    Vger::Resources::Company\
      .export_companies(params[:company])
    redirect_to manage_companies_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def export_monthly_report
    Vger::Resources::Company\
      .export_monthly_report(params[:company])
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
    methods = [:small_logo_url, :large_logo_url, :original_logo_url]
    if Rails.application.config.statistics[:load_assessment_statistics]
      methods.push :assessment_statistics
    end
    @company = Vger::Resources::Company.find(
      params[:id],
      :include => [:subscription, :admin],
      :methods => methods
    )
  end

  def get_companies
    methods = []
    params[:search] ||= {}
    params[:search] = params[:search].select{|key,val| val.present? }
    order_by = params[:order_by] || "created_at"
    order_type = params[:order_type] || "DESC"
    if Rails.application.config.statistics[:load_assessmentwise_statistics]
      methods |= [:assessmentwise_statistics, :assessment_statistics]
    end
    @companies = Vger::Resources::Company.where(
      :query_options => params[:search],
      :page => params[:page],
      :per => 15,
      :order => "#{order_by} #{order_type}",
      :include => [:subscription],
      :methods => methods
    )
    @active_subscription
  end

  def get_countries
    @countries =  Vger::Resources::Location.where(:query_options => { :location_type => Vger::Resources::Location::LocationType::COUNTRY }).all.collect{|location| [location.name,location.id] }
  end
end

