class Acdc::AssessmentsController < ApplicationController
  before_action :set_acdc_assessment, only: [:show, :edit]
  before_action :authenticate_user!
  before_action { authorize_user!(params[:company_id]) }
  before_action :get_company

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
                          .all.to_a.collect{|x| {value: x.id, text: x.name}}
    @industries = Vger::Resources::Industry.where(:query_options => {:active=>true},:order => "name ASC")\
                        .all.to_a.collect{|x| {value: x.id, text: x.name}}
    @job_experiences = Vger::Resources::JobExperience.active.all.to_a.collect{|x| {value: x.id, text: x.display_text}}
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
end
