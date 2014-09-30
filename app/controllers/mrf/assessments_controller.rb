class Mrf::AssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_assessment, :except => [:index]

  layout 'mrf'

  def home
    order_by = params[:order_by] || "mrf_assessments.created_at"
    order_type = params[:order_type] || "DESC"
    order = "#{order_by} #{order_type}"
    @assessments = Vger::Resources::Mrf::Assessment.where(company_id: params[:company_id], order: order, page: params[:page], per: 10).all
    @stakeholder_counts = Vger::Resources::Stakeholder.group_count(group: "mrf_stakeholder_assessments.assessment_id", joins: :stakeholder_assessments, query_options: { "mrf_stakeholder_assessments.assessment_id" => @assessments.map(&:id) })
    @candidate_counts = Vger::Resources::Candidate.group_count(group: "mrf_stakeholder_assessments.assessment_id", joins: {:feedbacks => :stakeholder_assessment}, select: "distinct(candidates.id)", query_options: { "mrf_stakeholder_assessments.assessment_id" => @assessments.map(&:id) })
    @completed_counts = Vger::Resources::Candidate.group_count(group: "mrf_stakeholder_assessments.assessment_id", joins: {:feedbacks => :stakeholder_assessment}, query_options: { "mrf_stakeholder_assessments.assessment_id" => @assessments.map(&:id), "mrf_feedbacks.status" => Vger::Resources::Mrf::Feedback.completed_statuses })
  end

  def new
    get_custom_assessments
  end

  def create_for_assessment
    name = ""
    custom_assessment = Vger::Resources::Suitability::CustomAssessment.find(params[:assessment_id])
    if params[:candidate_id].present?
      candidate = Vger::Resources::Candidate.find(params[:candidate_id])
      name = "360 Degree Profiling for #{candidate.name} under assessment #{custom_assessment.name}"
    else
      name = "360 Degree Profiling for all Assessment Takers under assessment #{custom_assessment.name}"
    end
    assessment = Vger::Resources::Mrf::Assessment.where(company_id: @company.id, :query_options => {name: name, company_id: @company.id }).all.last
    if assessment
      redirect_to add_stakeholders_company_mrf_assessment_path(@company.id,assessment.id)
    else
      attributes = {
        name: name,
        company_id: @company.id,
        custom_assessment_id: custom_assessment.id,
        configuration: {
          :use_competencies => custom_assessment.assessment_type == Vger::Resources::Assessment::AssessmentType::COMPETENCY
        }
      }
      @assessment = Vger::Resources::Mrf::Assessment.new(attributes)
      if @assessment.save
        flash[:notice] = "360 Degree feedback created successfully!"
        redirect_to add_traits_company_mrf_assessment_path(@company.id,@assessment.id)
      else
        get_custom_assessments
        flash[:error] = @assessment.error_messages.join("<br/>").html_safe
        render action: :new
      end
    end
  end

  def create
    params[:assessment][:company_id] = @company.id
    params[:assessment][:configuration] = {
      :use_competencies => params[:use_competencies].present?,
      :set_ranges => params[:add_traits_range].present?
    }
    if params[:build_from_existing].present? && !params[:assessment][:custom_assessment_id].present?
      flash[:error] = "Please choose the assessment this 360 Degree Profiling Exercise will be run on. If you wish to proceed without an assessment, you can use the Build 360 Degree from Scratch with New Traits option."
      get_custom_assessments
      render action: :new and return
    end
    @assessment = Vger::Resources::Mrf::Assessment.new(params[:assessment])
    if @assessment.save
      flash[:notice] = "360 Degree feedback created successfully!"
      redirect_to add_traits_company_mrf_assessment_path(@company.id,@assessment.id)
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
        configuration = @assessment.configuration || {}
        configuration = HashWithIndifferentAccess.new(configuration)
        redirect_to add_traits_range_company_mrf_assessment_path(@company.id,@assessment.id) and return
      else
        flash[:error] = 'Please select traits to create this Feedback Exercise!'
      end
    end
    get_traits
  end

  def add_traits_range
    @norm_buckets = Vger::Resources::Mrf::NormBucket.where(order: "weight ASC").all
    if request.put?
      params[:assessment][:assessment_traits_attributes] ||= {}
      params[:assessment][:assessment_traits_attributes].each do |id,assessment_trait|
        params[:assessment][:assessment_traits_attributes][id] = assessment_trait.reverse_merge({
          enable_comment: false,
          comment_compulsory: false
        })
      end
      @assessment = Vger::Resources::Mrf::Assessment.save_existing(@assessment.id, params[:assessment].merge(company_id: @company.id))
      redirect_to add_subjective_items_company_mrf_assessment_path(@company.id,@assessment.id) and return
    end
  end

  def add_subjective_items
    if request.put?
      if params[:subjective_items]
        configuration = @assessment.configuration || {}
        configuration[:subjective_items] = {}
        params[:subjective_items].each do |subjective_item_id, subjective_item_options|
          configuration[:subjective_items][subjective_item_id] = { :compulsory => subjective_item_options[:compulsory].present? }
        end
        @assessment = Vger::Resources::Mrf::Assessment.save_existing(@assessment.id, { company_id: @company.id, configuration: configuration });
      end
      if @assessment.custom_assessment_id
        redirect_to select_candidates_company_mrf_assessment_path(@company.id,@assessment.id) and return
      else
        redirect_to add_stakeholders_company_mrf_assessment_path(@company.id,@assessment.id) and return
      end
    else
      @assessment.configuration ||= {}
      @assessment.configuration["subjective_items"] ||= {}
      @subjective_items = Vger::Resources::Mrf::SubjectiveItem.active.all.to_a
      @subjective_items.each do |subjective_item|
        @assessment.configuration["subjective_items"][subjective_item.id.to_s] ||= {}
      end
    end
  end

  def details
    get_custom_assessment
    @stakeholder_assessments = Vger::Resources::Mrf::StakeholderAssessment.where(
      company_id: @company.id,
      assessment_id: @assessment.id
    ).all.to_a
    @stakeholder_assessments = @stakeholder_assessments.group_by(&:id)
    if @stakeholder_assessments.present?
      @feedbacks = Vger::Resources::Mrf::Feedback.where(
        company_id: @company.id,
        assessment_id: @assessment.id,
        query_options: {
          stakeholder_assessment_id: @stakeholder_assessments.keys
        }
      ).all.to_a
      @feedbacks = @feedbacks.group_by{|feedback| feedback.role }
    else
      @feedbacks = {}
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
      @assessment = Vger::Resources::Mrf::Assessment.find(params[:id], company_id: @company.id, :include => {
                    :assessment_traits => { include: [:trait], methods: [:from_norm_bucket_name,:to_norm_bucket_name] },
                    :assessment_competencies => { include: [:competency], methods:[:from_norm_bucket_name,:to_norm_bucket_name] }
                    })
    else
      @assessment = Vger::Resources::Mrf::Assessment.new
    end
  end

  def get_traits
    @traits = Vger::Resources::Suitability::Factor.where(:query_options => {:active => true}, :scopes => { :global => nil }, :methods => [:type, :direct_predictor_ids], :root => :factor).all.to_a
    @traits |= Vger::Resources::Suitability::Factor.where(:query_options => {"companies_factors.company_id" => params[:company_id], :active => true}, :methods => [:type, :direct_predictor_ids], :joins => [:companies], :root => :factor).all.to_a

    @traits = @traits.select{|trait| trait.direct_predictor_ids.blank? }

    @traits |= Vger::Resources::Mrf::Trait.where(:scopes => { :global => nil }).all.to_a
    @traits |= Vger::Resources::Mrf::Trait.where(:query_options => {"companies_traits.company_id" => params[:company_id]}, :joins => [:companies]).all.to_a
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
