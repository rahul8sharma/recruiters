class CompaniesController < ApplicationController
  layout "companies"

  before_filter :authenticate_user!
  before_filter(:except => [:select]) { authorize_user!(params[:id]) }
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

  def users_search
    params[:search] ||= {}
    order = params[:order_by] || "completed_at"
    order_type = params[:order_type] || "DESC"
    case order
      when "id"
        order = "jombay_users.id #{order_type}"
      when "name"
        order = "jombay_users.name #{order_type}"
      when "assessment_name"
        order = "suitability_custom_assessments.name #{order_type}"
      when "status"
        order = "suitability_user_assessments.status #{order_type}"
      else
        order = "#{order} #{order_type}"
    end
    if params[:search][:user_name_or_email].present?
      @user_assessments = Vger::Resources::Companies::UserAssessment.where(
        company_id: @company.id,
        query_options: {
          "suitability_custom_assessments.company_id" => @company.id
        },
        scopes: { :user_email_or_name_like => params[:search][:user_name_or_email] },
        joins: [ :assessment, :user  ],
        include: [:user, :assessment, :user_assessment_reports],
        methods: [:link_status],
        page: params[:page],
        order: order,
        per: 10
      ).all
    elsif params[:search].present?
      @user_assessments = []
      flash[:error] = "Please enter an Assessment Taker's name or email address to search!"
    else
      @user_assessments = []
    end
  end

  def reports
    order = params[:order_by] || "completed_at"
    order_type = params[:order_type] || "DESC"
    case order
      when "id"
        order = "jombay_users.id #{order_type}"
      when "name"
        order = "jombay_users.name #{order_type}"
      else
        order = "#{order} #{order_type}"
    end
    @user_assessments = Vger::Resources::Companies::UserAssessment.where(
      :company_id => @company.id,
      :joins => [:user_assessment_reports, :user, :assessment],
      :include => [:user_assessment_reports, :user, :assessment],
      :order => order
    ).where(
      :query_options => {
        "suitability_user_assessment_reports.status" => [
          Vger::Resources::Suitability::UserAssessmentReport::Status::UPLOADED,
          Vger::Resources::Suitability::UserAssessmentReport::Status::LOCKED
        ]
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
      user_user_email = "#{current_user.email.split("@")[0]}+selfassessment@#{current_user.email.split("@")[1]}"
      @user_assessment = Vger::Resources::Suitability::UserAssessment.where(:joins => [:user], :assessment_id => @custom_assessment.id, :query_options => { "jombay_users.email" => user_user_email }, methods: [:url], :include => [:user_assessment_reports]).all.to_a.first
    end
  end
  
  def index
    if @companies.present?
      @assessment_counts = Vger::Resources::Suitability::CustomAssessment.group_count(
        :query_options => {
          :company_id => @companies.map(&:id)
        },
        :group => [ :company_id ],
        :select => [ :company_id ]
      )
      
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
  end

  def edit
  end
  
  def comments
    google_form_links = YAML::load(File.open("#{Rails.root.to_s}/config/google_form_links.yml")).with_indifferent_access[Rails.env.to_s]
    @url = google_form_links["google_form_url"]
    options = {
      google_form_links["user_id_field"] => current_user.id,
      google_form_links["user_email_field"] => current_user.email,
      google_form_links["company_id_field"] => @company.id,
      google_form_links["company_name_field"] => @company.name,
    }
    @url = @url + "?#{options.to_param}"
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
      flash[:error] = @company.error_messages.join("<br/>").html_safe
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

  def user
  end
  
  def email_assessment_stats
     options = {
      :assessment_stats => {
        :job_klass => "Suitability::Assessment::CompanyAssessmentStatusExporter",
        :args => {
          :user_id => current_user.id,
          :company_id => params[:id]
        }
      }
    }
    @company.export_assessment_stats(options)
    redirect_to request.env['HTTP_REFERER'], notice: "Assessment Status Summary will be generated and emailed to #{current_user.email}."
  end
  
  def email_reports_summary
    options = {
      :assessment_stats => {
        :job_klass => "Suitability::Assessment::AccountReportsSummaryExporter",
        :args => {
          :user_id => current_user.id,
          :company_ids => [params[:id]]
        }
      }
    }
    Vger::Resources::Company.find(params[:id])\
      .export_assessment_stats(options)
    redirect_to request.env['HTTP_REFERER'], notice: "Reports Summary will be generated and emailed to #{current_user.email}."
  end

  protected

  def get_company
    methods = [
      :is_logo_present, :small_logo_url, :large_logo_url, :original_logo_url,
      :assessment_statistics,
      :admin
    ]
    @company = Vger::Resources::Company.find(
      params[:id],
      :include => [:subscription, :user],
      :methods => methods
    )
  end

  def get_companies
    methods = [
      :assessmentwise_statistics, :assessment_statistics, :subscription_valid_to
    ]
    params[:search] ||= {}
    params[:search] = params[:search].select{|key,val| val.present? }
    order_by = params[:order_by] || "created_at"
    order_type = params[:order_type] || "DESC"
    params[:search].delete :account_type if params[:search][:account_type] == "All"
    search_params = params[:search].dup
    name = search_params.delete :name
    conditions = {
      :query_options => search_params,
      :page => params[:page],
      :per => 15,
      :order => "#{order_by} #{order_type}",
      :include => [:subscription],
      :methods => methods,
      :select => ['id','name','created_at']
    }
    conditions[:scopes] = { :name_like => name } if name

    @companies = Vger::Resources::Company.where(conditions)
  end

  def get_countries
    @countries =  Vger::Resources::Location.where(:query_options => { :location_type => Vger::Resources::Location::LocationType::COUNTRY }).all.collect{|location| [location.name,location.id] }
  end
end

