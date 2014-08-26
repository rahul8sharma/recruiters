class Mrf::AssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_assessment, :except => [:index]
  
  layout 'mrf'
  
  def home
    @assessments = Vger::Resources::Mrf::Assessment.where(company_id: params[:company_id], order: "created_at DESC", page: params[:page], per: 10).all.to_a
  end 

  def new
    get_custom_assessments
  end
  
  def create
    params[:assessment][:company_id] = @company.id
    @assessment = Vger::Resources::Mrf::Assessment.new(params[:assessment])
    if @assessment.save
      flash[:notice] = "360 Degree feedback created successfully!"
      if params[:include_additional_traits].present? || @assessment.custom_assessment_id.nil?
        redirect_to add_traits_company_mrf_assessment_path(@company.id,@assessment.id)
      elsif @assessment.custom_assessment_id.present?
        redirect_to select_candidates_company_mrf_assessment_path(@company.id,@assessment.id) and return
      else  
        redirect_to add_stakeholders_company_mrf_assessment_path(@company.id,@assessment.id) and return
      end
    else
      get_custom_assessments
      flash[:error] = @assessment.error_messages.join("<br/>").html_safe
      render action: :new
    end
  end

  def add_traits
    if request.put?
      if params[:assessment][:assessment_traits_attributes]
        @assessment = Vger::Resources::Mrf::Assessment.save_existing(@assessment.id, params[:assessment])
        if @assessment.custom_assessment_id.present?
          redirect_to select_candidates_company_mrf_assessment_path(@company.id,@assessment.id) and return
        else  
          redirect_to add_stakeholders_company_mrf_assessment_path(@company.id,@assessment.id) and return
        end
      else
      end
    end
    get_traits
  end
  
  def details
    get_custom_assessment
    @stakeholder_assessments = Vger::Resources::Mrf::StakeholderAssessment.where(
      company_id: @company.id,
      assessment_id: @assessment.id
    ).all.to_a
    @stakeholder_assessments = @stakeholder_assessments.group_by(&:id)
    @feedbacks = Vger::Resources::Mrf::Feedback.where(
      company_id: @company.id,
      assessment_id: @assessment.id,
      query_options: {
        stakeholder_assessment_id: @stakeholder_assessments.keys
      }
    ).all.to_a
    @feedbacks = @feedbacks.group_by{|feedback| feedback.role }
    if @feedbacks.present?
      @candidates = Hash[Vger::Resources::Candidate.where(query_options: { id: @feedbacks.keys }).to_a.collect{|candidate| [candidate.id,candidate] }]
    else
      @candidates = {}
    end
  end

  def traits
    get_custom_assessment
  end
  
  protected
  
  def get_custom_assessments
    @custom_assessments = Vger::Resources::Suitability::CustomAssessment.where(company_id: params[:company_id], query_options: { company_id: params[:company_id] }, order_by: "created_at DESC").all.to_a
  end
  
  def get_custom_assessment
    if @assessment.custom_assessment_id.present?
      @custom_assessment = Vger::Resources::Suitability::CustomAssessment.find(@assessment.custom_assessment_id)
    end
  end
  
  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end
  
  def get_assessment
    if params[:id].present?
      @assessment = Vger::Resources::Mrf::Assessment.find(params[:id], company_id: @company.id, :include => {:assessment_traits => { methods: [:trait] } })
    else
      @assessment = Vger::Resources::Mrf::Assessment.new
    end
  end
  
  def get_traits
    @traits = Vger::Resources::Suitability::Factor.where(query_options: { type: "Suitability::Factor", active: true }, methods: [:direct_predictor_ids]).all.to_a
    @traits = @traits.select{|trait| trait.direct_predictor_ids.blank? }
    @traits |= Vger::Resources::Mrf::Trait.where(query_options: { company_id: @company.id }).all.to_a
    get_assessment_traits
  end
  
  def get_assessment_traits
    added_assessment_traits = Hash[@assessment.assessment_traits.collect{|assessment_trait| ["#{assessment_trait.trait_type}-#{assessment_trait.trait_id}",assessment_trait] }]
    @assessment_traits = []
    custom_assessment_factors = []
    get_custom_assessment
    custom_assessment_factors = Vger::Resources::Suitability::Job::AssessmentFactorNorm.where(:custom_assessment_id => @assessment.custom_assessment_id, select: :factor_id).all.to_a.map(&:factor_id) if @custom_assessment
    @traits.each do |trait|
      trait_type = trait.class.name.gsub('Vger::Resources::','')
      @assessment_trait = added_assessment_traits["#{trait_type}-#{trait.id}"]
      @assessment_trait ||= Vger::Resources::Mrf::AssessmentTrait.new({ trait_type: trait_type, trait_id: trait.id, assessment_id: @assessment.id })
      @assessment_trait.trait = trait
      @assessment_trait.assessment_trait = custom_assessment_factors.include?(trait.id) && !trait.is_a?(Vger::Resources::Mrf::Trait)
      @assessment_traits.push @assessment_trait
    end
  end
end
