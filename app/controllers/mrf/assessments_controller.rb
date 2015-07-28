class Mrf::AssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_assessment, :except => [:index]

  layout 'mrf/mrf'

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

  def order_enable_items
    added_other_items = @assessment.items_other.present? ? Hash[@assessment.items_other.collect.with_index{|item_data, index| [item_data['id'].to_s,{ type: item_data['type'], order: index }] }] : {}
    added_self_items = @assessment.items_self.present? ? Hash[@assessment.items_self.collect.with_index{|item_data, index| [item_data['id'].to_s,{ type: item_data['type'], order: index }] }] : {}
    params[:selected_items_other] ||= added_other_items
    params[:selected_items_self] ||= added_self_items
    @selected_items_other = params[:selected_items_other]
    @selected_items_self = params[:selected_items_self]
    @error_items = []
    if request.put?
      @selected_items_other = @selected_items_other.select{|item_id, item_data| item_data[:type].present? }
      @selected_items_other = Hash[@selected_items_other.sort_by{|item_id, item_data| item_data[:order].to_i }]
      @selected_items_self = @selected_items_self.select{|item_id, item_data| item_data[:type].present? }
      @selected_items_self = Hash[@selected_items_self.sort_by{|item_id, item_data| item_data[:order].to_i }]
      
      @error_items = @selected_items_other\
                              .group_by{|item_id, item_data| item_data[:order] }\
                              .select{|key,values| values.size > 1 }\
                              .values.collect{|v| v[0][0] }
      @error_items |= @selected_items_self\
                              .group_by{|item_id, item_data| item_data[:order] }\
                              .select{|key,values| values.size > 1 }\
                              .values.collect{|v| v[0][0] }
      
      
      other_item_orders = @selected_items_other.values.flatten.collect{|item_data| item_data[:order] } 
      if other_item_orders.size != other_item_orders.uniq.size
        flash[:error] = "Orders for other items is not unique. Please make sure that you have unique order for all the other items."
        get_trait_wise_items
        return
      end
      self_item_orders = @selected_items_self.values.flatten.collect{|item_data| item_data[:order] } 
      if self_item_orders.size != self_item_orders.uniq.size
        flash[:error] = "Orders for self items is not unique. Please make sure that you have unique order for all the self items."
        get_trait_wise_items  
        return
      end
      #configuration = @assessment.configuration || {}
      items_self = @selected_items_self.collect{ |item_id,item_data|
        {
          id: item_id,
          type: item_data[:type].split("Vger::Resources::").last,
          enable_comment: item_data[:enable_comment].present?,
          comment_compulsory: item_data[:comment_compulsory].present?
        }
      }
      items_other = @selected_items_other.collect{ |item_id,item_data|
        {
          id: item_id,
          type: item_data[:type].split("Vger::Resources::").last,
          enable_comment: item_data[:enable_comment].present?,
          comment_compulsory: item_data[:comment_compulsory].present?
        }
      }
      @assessment = Vger::Resources::Mrf::Assessment.save_existing(@assessment.id, { 
        company_id: @company.id,
        items_self: items_self,
        items_other: items_other
      });
      redirect_to add_subjective_items_company_mrf_assessment_path(@company.id,@assessment.id) and return
    end
    get_trait_wise_items
  end
  
  def edit
  end

  def update
    params[:assessment][:company_id] = @company.id
    @assessment = Vger::Resources::Mrf::Assessment.save_existing(@assessment.id,params[:assessment]);
    redirect_to details_company_mrf_assessment_path(@company.id,@assessment.id)
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
        :use_competencies => (custom_assessment.assessment_type == Vger::Resources::Assessment::AssessmentType::COMPETENCY)
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
        redirect_to add_traits_range_company_mrf_assessment_path(@company.id,@assessment.id) and return
      else
        flash[:error] = 'Please select traits to create this Feedback Exercise!'
      end
    end
    get_norm_buckets
    get_traits
  end

  def add_traits_range
    get_norm_buckets
    if request.put?
      params[:assessment][:assessment_traits_attributes] ||= {}
      params[:assessment][:assessment_traits_attributes].each do |id,assessment_trait|
        params[:assessment][:assessment_traits_attributes][id] = assessment_trait.reverse_merge({
          enable_comment: false,
          comment_compulsory: false
        })
      end
      @assessment = Vger::Resources::Mrf::Assessment.save_existing(@assessment.id, params[:assessment].merge(company_id: @company.id))
      redirect_to order_enable_items_company_mrf_assessment_path(@company.id,@assessment.id) and return
    end
  end

  def add_subjective_items
    if request.put?
      if params[:subjective_items_self] || params[:subjective_items_other]
        params[:subjective_items_self] ||= {}
        params[:subjective_items_other] ||= {}
        subjective_items_other = Hash[params[:subjective_items_other].map do |subjective_item_id, subjective_item_options|
          [subjective_item_id, { :compulsory => subjective_item_options[:compulsory].present? }]
        end]
        subjective_items_self = Hash[params[:subjective_items_self].map do |subjective_item_id, subjective_item_options|
          [subjective_item_id, { :compulsory => subjective_item_options[:compulsory].present? }]
        end]
        @assessment = Vger::Resources::Mrf::Assessment.save_existing(@assessment.id, { 
          company_id: @company.id, 
          subjective_items_other: subjective_items_other,
          subjective_items_self: subjective_items_self
        });
      end
      if @assessment.custom_assessment_id
        redirect_to select_candidates_company_mrf_assessment_path(@company.id,@assessment.id) and return
      else
        redirect_to add_stakeholders_company_mrf_assessment_path(@company.id,@assessment.id) and return
      end
    else
      @subjective_items_other = Vger::Resources::Mrf::SubjectiveItem\
                                  .active({
                                    role: Vger::Resources::Mrf::Feedback.other_roles
                                  }).all.to_a
      @subjective_items_other.each do |subjective_item|
        @assessment.subjective_items_other[subjective_item.id.to_s] ||= {}
      end
      @subjective_items_self = Vger::Resources::Mrf::SubjectiveItem\
                                  .active({
                                    role: Vger::Resources::Mrf::Feedback::Role::SELF
                                  }).all.to_a
      @subjective_items_self.each do |subjective_item|
        @assessment.subjective_items_self[subjective_item.id.to_s] ||= {}
      end
    end
  end

  def details
    get_custom_assessment
    @feedbacks = Vger::Resources::Mrf::Feedback.group_count(
      company_id: @company.id,
      assessment_id: @assessment.id,
      group: ["role"],
      joins: [:stakeholder_assessment],
      query_options: {
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id
      }
    )
    @completed_feedbacks = Vger::Resources::Mrf::Feedback.group_count(
      company_id: @company.id,
      assessment_id: @assessment.id,
      group: ["role"],
      joins: [:stakeholder_assessment],
      query_options: {
        "mrf_feedbacks.status" => Vger::Resources::Mrf::Feedback.completed_statuses,
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id
      }
    )

    @self_feedbacks = Vger::Resources::Mrf::Feedback.count(
      company_id: @company.id,
      assessment_id: @assessment.id,
      joins: [:stakeholder_assessment],
      query_options: {
        role: Vger::Resources::Mrf::Feedback::Role::SELF,
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id
      }
    )
    
    @total_candidates = Vger::Resources::Mrf::Feedback.count(
      company_id: @company.id,
      assessment_id: @assessment.id,
      select: ["distinct(candidate_id)"],
      joins: [:stakeholder_assessment],
      query_options: {
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id
      }
    )
  end

  def traits
    get_custom_assessment
    get_norm_buckets
    @norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
  end
  
  protected
  
  def get_norm_buckets
    @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                      order: "weight ASC", query_options: {
                        company_id: @company.id
                      }).all
    
    if @norm_buckets.empty?
      @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                      order: "weight ASC", query_options: {
                        company_id: nil
                      }).all
    end
  end

  def get_custom_assessments
    @custom_assessments = Vger::Resources::Suitability::CustomAssessment.where(company_id: params[:company_id], query_options: { company_id: params[:company_id] }, order: "created_at DESC").all.to_a
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
  
  def get_trait_wise_items
    @assessment_traits = Hash[@assessment.assessment_traits\
                                .collect{|assessment_trait| 
                                  [assessment_trait.trait, assessment_trait] 
                                }]
    @trait_wise_items = {}
    @assessment.assessment_traits.each do |assessment_trait|
      @trait_wise_items[assessment_trait.trait] = Vger::Resources::Mrf::Item.where(query_options: {
        active: true,
        trait_type: assessment_trait.trait_type,
        trait_id: assessment_trait.trait_id
      }, include: [:options])
    end
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
      @assessment_trait.from_norm_bucket_id ||= @norm_buckets.map(&:id).min
      @assessment_trait.to_norm_bucket_id ||= @norm_buckets.map(&:id).max
      @assessment_trait.assessment_trait = custom_assessment_factors.include?(trait.id) && !trait.is_a?(Vger::Resources::Mrf::Trait)
      @assessment_traits.push @assessment_trait
    end
  end

end
