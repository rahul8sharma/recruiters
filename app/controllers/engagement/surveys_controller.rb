class Engagement::SurveysController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_survey, :except => [:index,:home]
  before_filter :get_defined_forms, :only => [:new, :edit, :create]
  
  layout 'engagement'

  def api_resource
    Vger::Resources::Engagement::Survey
  end
  
  def home
    order_by = params[:order_by] || "engagement_surveys.created_at"
    order_type = params[:order_type] || "DESC"
    order = "#{order_by} #{order_type}"
    @surveys = Vger::Resources::Engagement::Survey.where(query_options: {company_id: params[:company_id]}, order: order, page: params[:page], per: 10).all
    @candidate_counts = Vger::Resources::Candidate.group_count(group: "engagement_candidate_surveys.survey_id", joins: :engagement_candidate_surveys, query_options: { 
      "engagement_candidate_surveys.survey_id" => @surveys.map(&:id) 
    })
    @completed_counts = Vger::Resources::Candidate.group_count(group: "engagement_candidate_surveys.survey_id", joins: :engagement_candidate_surveys, query_options: { 
      "engagement_candidate_surveys.survey_id" => @surveys.map(&:id),
      "engagement_candidate_surveys.status" => Vger::Resources::Engagement::CandidateSurvey.completed_statuses
    })
  end
  
  def new
  end
  
  def create
    params[:survey][:company_id] = @company.id
    @survey = Vger::Resources::Engagement::Survey.new(params[:survey])
    if @survey.save
      if params[:defined_form_id].present?
        factual_information_form = Vger::Resources::FormBuilder::FactualInformationForm.create({
          :defined_form_id => params[:defined_form_id],
          :company_id => @company.id,
          :assessment_type => "Engagement::Survey",
          :assessment_id => @survey.id
        })
      end
      flash[:notice] = "Engagement Survey created successfully!"
      redirect_to add_elements_company_engagement_survey_path(@company.id,@survey.id)
    else
      flash[:error] = @survey.error_messages.join("<br/>").html_safe
      render action: :new
    end
  end
  
  def add_elements
    if request.get?
      get_elements
    else
      @survey = Vger::Resources::Engagement::Survey.save_existing(@survey.id, params[:survey])
      if !@survey.error_messages.present?
        flash[:notice] = "Engagement Survey created successfully!"
        redirect_to add_candidates_company_engagement_survey_path(@company.id,@survey.id)
      else
        flash[:error] = @survey.error_messages.join("<br/>").html_safe
        render action: :new
      end
    end  
  end
  
  def details
    @total_candidates = Vger::Resources::Engagement::CandidateSurvey.count({
      survey_id: @survey.id
    })
  end
  
  def elements
  end
  
  protected
  
  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

  def get_survey
    if params[:id].present?
      @survey = Vger::Resources::Engagement::Survey.find(params[:id], company_id: @company.id)
    else
      @survey = Vger::Resources::Engagement::Survey.new
    end
  end
  
  def get_elements
    @facets = Vger::Resources::Engagement::Facet.where({
      query_options: {
        :active => true
      }
    }).all.to_a
    @factors = Vger::Resources::Engagement::Factor.where({
      query_options: {
        :active => true
      },
      page: 1,
      per: 1000
    }).all.to_a.group_by(&:facet_id)
    @elements = Vger::Resources::Engagement::Element.where({
      query_options: {
        :active => true
      },
      page: 1,
      per: 1000
    }).all.to_a.group_by(&:id)
    @survey_elements = @survey.survey_elements.all.to_a
    @survey_elements.each do |survey_element|
      survey_element.is_selected = true
      survey_element.element = @elements[survey_element.element_id][0]
    end
    added_element_ids = @survey_elements.map(&:element_id)
    @elements.each do |element_id,elements|
      if !added_element_ids.include?(element_id)
        survey_element = Vger::Resources::Engagement::SurveyElement.new({
          survey_id: @survey.id,
          element_id: element_id
        })
        survey_element.is_selected = false
        survey_element.element = elements[0]
        @survey_elements.push(survey_element)
      end
    end
    @survey_elements = @survey_elements.group_by{|x| x.element.factor_id }
  end
  
  def get_defined_forms
    @defined_forms = Vger::Resources::FormBuilder::DefinedForm.where(scopes: { for_company: @company.id }, query_options: { active: true }).all.to_a
  end
end
