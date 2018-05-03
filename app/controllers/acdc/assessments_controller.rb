class Acdc::AssessmentsController < ApplicationController
  include TemplatesHelper
  before_action :set_acdc_assessment, only: [:show, :edit]
  before_action :authenticate_user!
  before_action { authorize_user!(params[:company_id]) }
  before_action :get_company
  before_action :get_completion_notification_templates, :only => [:select_templates]
  before_action :get_invitation_templates, :only => [:select_templates]
  before_action :get_reminder_templates, :only => [:select_templates]

  layout 'acdc/acdc'

  def api_resource
    Vger::Resources::Acdc::Assessment
  end

  def index
    @assessments = api_resource.where(:query_options => {
                            :company_id => params[:company_id]
                          }, 
                          :page => params[:page], :per => 10,
                          order: ["created_at DESC"]
                        ).all
  end

  def edit
  end

  def show
    render json: @assessment.attributes, status: :ok
  end

  def create
    @assessment = api_resource.create(acdc_assessment_params)

    if @assessment.error_messages && @assessment.error_messages.present?
      render json: @assessment.errors, status: :unprocessable_entity
    else
      render json: @assessment.attributes, status: :created
    end
  end

  def update
    @assessment = api_resource.save_existing(params[:id], acdc_assessment_params)

    if @assessment.error_messages && @assessment.error_messages.present?
      render json: @assessment.errors, status: :unprocessable_entity
    else
      render json: @assessment.attributes, status: :accepted
    end
  end

  def get_meta_data
    @functional_areas = Vger::Resources::FunctionalArea.where(:query_options => {:active=>true},:order => "name ASC")\
                          .all.to_a.collect{|functional_area| {value: functional_area.id, text: functional_area.name}}
    @industries = Vger::Resources::Industry.where(:query_options => {:active=>true},:order => "name ASC")\
                        .all.to_a.collect{|industry| {value: industry.id, text: industry.name}}
    @job_experiences = Vger::Resources::JobExperience.active.all.to_a.collect{|job_experience| {value: job_experience.id, text: job_experience.display_text}}
    render json: { 
                   'functional_areas': @functional_areas, 
                   'industries': @industries,
                   'job_experiences': @job_experiences 
                 }, status: :ok
  end

  def get_languages
    @languages = Vger::Resources::Language.all.map{|language| { value: language.language_code, text: language.name} } 

    render json: { 'languages': @languages }, status: :ok
  end

  def get_products
    @products = Vger::Resources::Product.where(:query_options => {},:order => "name ASC").to_a
    render json: @products.to_json, status: :ok
  end

  def get_defined_forms
    @defined_forms = Vger::Resources::FormBuilder::DefinedForm.where(
      scopes: { for_company_id: params[:company_id] },
      query_options: { active: true },
      methods: [:parent_uid]
    ).all.to_a.collect{|form| {value: form.id, text: form.name}}
    render json: @defined_forms, status: :ok
  end

  def get_defined_field
   @defined_fields = Vger::Resources::FormBuilder::DefinedField.where(
      query_options: {
        defined_form_id: params[:defined_form_id]
      },
      order: "field_order ASC"
    ).all.to_a.collect{|field| field.attributes }
    render json: @defined_fields, status: :ok
  end

  # Get file for ACDC assessment
  def get_google_drive_file_by_url
    file = api_resource.get_google_drive_file_by_url(acdc_assessment_params)
    render json: file, status: :ok
  end

  def competencies
    get_competencies(:for_suitability)
    render json: @local_competencies, status: :ok
  end

  def get_competencies(scope)
    @local_competencies = Vger::Resources::Suitability::Competency.where(
      :query_options => {
        "companies_competencies.company_id" => @company.id,
        :active => true
      },
      :scopes => {
        scope => nil,
        :with_factors => nil
      },
      :methods => [:factors_data, :factor_names],
      :order => ["name ASC"],
      :joins => "companies"
    ).all.to_a.collect do |competency|
       competency.attributes[:factors_data].each do |factor|
        get_default_norm_bucket_ranges(factor[:id])
        factor[:from_norm_bucket_id] = @default_norm_bucket_ranges[0][:from_norm_bucket_id]
        factor[:to_norm_bucket_id] = @default_norm_bucket_ranges[0][:to_norm_bucket_id]
       end
       competency.attributes
      end
  end

  def get_default_norm_bucket_ranges(factor_id)
      query_options = {
        :functional_area_id => params[:functional_areas_id],
        :industry_id => params[:industry_id],
        :job_experience_id => params[:job_experience_id],
        :factor_id => factor_id
      }
      @default_norm_bucket_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.where(:query_options => query_options).all.to_a
      if @default_norm_bucket_ranges.empty?

        query_options = {
          :functional_area_id => nil,
          :industry_id => nil,
          :job_experience_id => nil,
          :factor_id => factor_id
        }
        @default_norm_bucket_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.\
                                    where(:query_options => query_options).all.to_a
      end
      @default_norm_bucket_ranges
  end

  def select_templates
    render json: {
        completion_notification_templates: @completion_notification_templates.collect{|field| template_preview(field) },
        invitation_templates: @invitation_templates.collect{|field| template_preview(field) },
        reminder_templates: @reminder_templates.collect{|field| template_preview(field) }
      }, status: :ok
  end


  def get_completion_notification_templates
    query_options = {
      "template_categories.name" => Vger::Resources::Template::TemplateCategory::SEND_ASSESSMENT_COMPLETION_NOTIFICATION_TO_CANDIDATE
    }
    @completion_notification_templates = get_templates_for_company(query_options, @company.id)
    @completion_notification_templates |= get_global_templates(query_options)
  end

  def get_invitation_templates
    category = ""
    query_options = {
    }
    category = [
      Vger::Resources::Template::TemplateCategory::SEND_TEST_TO_CANDIDATE,
      Vger::Resources::Template::TemplateCategory::SEND_TEST_TO_EMPLOYEE
   ]
    query_options["template_categories.name"] = category
    @invitation_templates = get_templates_for_company(query_options, @company.id)
    @invitation_templates |= get_global_templates(query_options)
  end
  
  def get_reminder_templates
    category = ""
    query_options = {
    }
    category = [
      Vger::Resources::Template::TemplateCategory::SEND_TEST_REMINDER_TO_CANDIDATE,
      Vger::Resources::Template::TemplateCategory::SEND_TEST_REMINDER_TO_EMPLOYEE
    ]
    query_options["template_categories.name"] = category
    @reminder_templates = get_templates_for_company(query_options, @company.id)
    @reminder_templates |= get_global_templates(query_options)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_acdc_assessment
      @assessment = api_resource.find(params[:id])
    end

    #Return current company
    def get_company
      @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def acdc_assessment_params
      params.fetch(:acdc_assessment, {})
    end

    def template_preview(field)
      {
        id: field.preview(:id),
        name: field.preview(:name),
        body: field.preview(:body),
        subject: field.preview(:subject),
        from: field.preview(:from)
      }
    end
end
