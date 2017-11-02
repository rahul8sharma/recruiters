class Mrf::AssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_assessment, :except => [:index]
  
  def api_resource
    Vger::Resources::Mrf::Assessment
  end

  layout 'mrf/mrf'

  def home
    order_by = params[:order_by] || "mrf_assessments.created_at"
    order_type = params[:order_type] || "DESC"
    order = "#{order_by} #{order_type}"
    @assessments = Vger::Resources::Mrf::Assessment.where(
      company_id: params[:company_id], 
      order: order, 
      select: [:id, :created_at, :name],
      page: params[:page], per: 10
    ).all
    @stakeholder_counts = Vger::Resources::Stakeholder.group_count(
      group: "mrf_stakeholder_assessments.assessment_id", 
      joins: { :stakeholder_assessments => :feedbacks }, 
      select: "distinct(stakeholders.id)",
      query_options: { 
        "mrf_stakeholder_assessments.assessment_id" => @assessments.map(&:id),
        "mrf_feedbacks.trial" => false
      }
    )
    @user_counts = Vger::Resources::User.group_count(
      group: "mrf_stakeholder_assessments.assessment_id", 
      joins: {:feedbacks => :stakeholder_assessment}, 
      select: "distinct(jombay_users.id)", 
      query_options: { 
        "mrf_stakeholder_assessments.assessment_id" => @assessments.map(&:id),
        "mrf_feedbacks.trial" => false
      }
    )
    @completed_counts = Vger::Resources::User.group_count(
      group: "mrf_stakeholder_assessments.assessment_id", 
      joins: {:feedbacks => :stakeholder_assessment}, 
      query_options: { 
        "mrf_stakeholder_assessments.assessment_id" => @assessments.map(&:id), 
        "mrf_feedbacks.status" => Vger::Resources::Mrf::Feedback.completed_statuses,
        "mrf_feedbacks.trial" => false 
      }
    )
  end
  
  def download_pdf_reports
    url = S3Utils.get_url(params[:bucket], params[:key])
    redirect_to url
  end
  
  def trigger_report_downloader
    date_range = params[:date_range].present? ? JSON.parse(params[:date_range]) : nil
    options = {
      :assessment => {
        :job_klass => "Mrf::ReportsDownloader",
        :args => {
          :date_range => date_range,
          :user_id => current_user.id,
          :assessment_id => params[:id]
        }
      }
    }
    Vger::Resources::Mrf::Assessment.find(params[:id], company_id: params[:company_id])\
      .download_pdf_reports(options)
    redirect_to users_company_mrf_assessment_path(@company.id,@assessment.id), notice: "Reports will be downloaded and link to download the zip file will be emailed to #{current_user.email}."
  end

  def new
    get_custom_assessments
  end

  def order_enable_items
    added_other_items = @assessment.items_other.present? ? Hash[@assessment.items_other.collect.with_index{|item_data, index| [item_data['id'].to_s,{ type: item_data['type'], order: index, allow_skip: !item_data['compulsory'] }] }] : {}
    added_self_items = @assessment.items_self.present? ? Hash[@assessment.items_self.collect.with_index{|item_data, index| [item_data['id'].to_s,{ type: item_data['type'], order: index, allow_skip: !item_data['compulsory'] }] }] : {}
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
          comment_compulsory: item_data[:comment_compulsory].present?,
          compulsory: !item_data[:allow_skip].present?
        }
      }
      items_other = @selected_items_other.collect{ |item_id,item_data|
        {
          id: item_id,
          type: item_data[:type].split("Vger::Resources::").last,
          enable_comment: item_data[:enable_comment].present?,
          comment_compulsory: item_data[:comment_compulsory].present?,
          compulsory: !item_data[:allow_skip].present?
        }
      }
      @assessment = Vger::Resources::Mrf::Assessment.save_existing(@assessment.id, params[:assessment].merge({ 
        company_id: @company.id,
        items_self: items_self,
        items_other: items_other,
        
      }));
      redirect_to add_subjective_items_company_mrf_assessment_path(@company.id,@assessment.id) and return
    end
    get_trait_wise_items
  end
  
  def edit
  end

  def update
    params[:assessment][:report_configuration] = JSON.parse(params[:assessment][:report_configuration])
    params[:assessment][:company_id] = @company.id
    @assessment = Vger::Resources::Mrf::Assessment.save_existing(@assessment.id,params[:assessment]);
    flash[:notice] = "360 Degree Exercise successfully updated"
    redirect_to edit_company_mrf_assessment_path(@company.id,@assessment.id)
  end

  def create_for_assessment
    name = ""
    custom_assessment = Vger::Resources::Suitability::CustomAssessment.find(params[:assessment_id])
    if params[:user_id].present?
      user = Vger::Resources::User.find(params[:user_id])
      name = "360 Degree Profiling for #{user.name} under assessment #{custom_assessment.name}"
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
        redirect_to add_traits_company_mrf_assessment_path(@company.id,@assessment.id)
      else
        get_custom_assessments
        flash[:error] = @assessment.error_messages.join("<br/>").html_safe
        render action: :new
      end
    end
  end

  def create
    params[:assessment][:report_configuration] = JSON.parse(params[:assessment][:report_configuration])
    params[:assessment][:company_id] = @company.id
    @assessment = Vger::Resources::Mrf::Assessment.new(params[:assessment])
    if @assessment.save
      if params[:proceed_with_competencies].present?
        redirect_to competencies_company_mrf_assessment_path(@company.id,@assessment.id)
      else
        if params[:assessment][:use_competencies] == "1"
          redirect_to competencies_company_mrf_assessment_path(@company.id,@assessment.id)
        else
          redirect_to add_traits_company_mrf_assessment_path(@company.id,@assessment.id)
        end
      end
    else
      get_custom_assessments
      flash[:error] = @assessment.error_messages.join("<br/>").html_safe
      render action: :new
    end
  end
  
  def competencies
    if request.get?
      get_competencies
    else
      added_assessment_competencies = Hash[@assessment.assessment_competencies.map do |assessment_competency|
        [assessment_competency.competency_id, assessment_competency.id]
      end]
      params[:assessment] ||= {}
      params[:assessment][:competencies] ||= []
      if params[:assessment][:competencies].blank?
        get_competencies
        flash[:error] = "Competencies to be measured must be selected before proceeding!"
        return
      else
        selected_competency_ids = params[:assessment][:competencies].map(&:to_i)
        selected_competencies = Hash[params[:assessment][:competency_order].select{|competency_id,order| selected_competency_ids.include?(competency_id.to_i) }]
        competency_order = Hash[selected_competencies.map{|competency_id,order| [competency_id.to_i,order.to_i] }]
        competency_order = Hash[competency_order.sort_by{|competency_id, order| order }]
        if competency_order.values.size != competency_order.values.uniq.size
          get_competencies
          flash[:error] = "Competencies should have unique order!"
          return
        end
        ordered_competencies = competency_order.keys.select{|competency_id| selected_competency_ids.include?(competency_id) }
        @assessment = api_resource.save_existing(@assessment.id,  {
          company_id: @company.id,
          assessment_competencies_attributes: Hash[ordered_competencies.collect.with_index do |competency_id, index|
            [index, {
              id: added_assessment_competencies[competency_id],
              competency_id: competency_id,
              assessment_id: @assessment.id,
              competency_order: index
            }]
          end]
        })
        if @assessment.error_messages.blank?
          redirect_to add_traits_range_company_mrf_assessment_path(@company.id,@assessment.id) and return
        else
          get_competencies
          flash[:error] = @assessment.error_messages.join("<br/>")
        end
      end
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
      if @assessment.error_messages.present?
        flash[:error] = @assessment.error_messages.join("<br/>").html_safe 
        redirect_to add_traits_range_company_mrf_assessment_path(@company.id,@assessment.id) and return
      else
        redirect_to order_enable_items_company_mrf_assessment_path(@company.id,@assessment.id) and return
      end
      
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
        redirect_to select_users_company_mrf_assessment_path(@company.id,@assessment.id) and return
      else
        redirect_to add_stakeholders_company_mrf_assessment_path(@company.id,@assessment.id) and return
      end
    else
      @subjective_items_other = Vger::Resources::Mrf::SubjectiveItem\
                                  .active({
                                    company_id: @company.id,  
                                    role: Vger::Resources::Mrf::Feedback.other_roles
                                  }).all.to_a
      @subjective_items_other.each do |subjective_item|
        @assessment.subjective_items_other[subjective_item.id.to_s] ||= {}
      end
      @subjective_items_self = Vger::Resources::Mrf::SubjectiveItem\
                                  .active({
                                    company_id: @company.id,  
                                    role: Vger::Resources::Mrf::Feedback::Role::SELF
                                  }).all.to_a
      @subjective_items_self.each do |subjective_item|
        @assessment.subjective_items_self[subjective_item.id.to_s] ||= {}
      end
    end
  end

  def set_cap
    if request.put?
      redirect_to add_stakeholders_company_mrf_assessment_path(@company.id,@assessment.id) and return
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
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id,
        "mrf_feedbacks.trial" => false
      }
    )
    @completed_feedbacks = Vger::Resources::Mrf::Feedback.group_count(
      company_id: @company.id,
      assessment_id: @assessment.id,
      group: ["role"],
      joins: [:stakeholder_assessment],
      query_options: {
        "mrf_feedbacks.status" => Vger::Resources::Mrf::Feedback.completed_statuses,
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id,
        "mrf_feedbacks.trial" => false
      }
    )

    @self_feedbacks = Vger::Resources::Mrf::Feedback.count(
      company_id: @company.id,
      assessment_id: @assessment.id,
      joins: [:stakeholder_assessment],
      query_options: {
        role: Vger::Resources::Mrf::Feedback::Role::SELF,
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id,
        "mrf_feedbacks.trial" => false
      }
    )
    
    @total_users = Vger::Resources::Mrf::Feedback.count(
      company_id: @company.id,
      assessment_id: @assessment.id,
      select: ["distinct(user_id)"],
      joins: [:stakeholder_assessment],
      query_options: {
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id,
        "mrf_feedbacks.trial" => false
      }
    )
  end

  def traits
    get_custom_assessment
    get_norm_buckets
    @norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
  end
  
  def measured_competencies
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
    @custom_assessments = []#Vger::Resources::Suitability::CustomAssessment.where(company_id: params[:company_id], query_options: { company_id: params[:company_id] }, order: "created_at DESC").all.to_a
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
      @assessment = Vger::Resources::Mrf::Assessment.find(
        params[:id], 
        company_id: @company.id, 
        :include => {
          :assessment_traits => { 
            include: [:trait], 
            methods: [:from_norm_bucket_name,:to_norm_bucket_name] 
          },
          :assessment_competencies => { 
            include: { 
              :competency => { 
                methods: [:factor_names, :mrf_trait_names] 
              } 
            }, 
            methods: [:from_norm_bucket_name,:to_norm_bucket_name] 
          }
        }
      )
    else
      @assessment = Vger::Resources::Mrf::Assessment.new
    end
  end

  def get_traits
    @traits = Vger::Resources::Suitability::Factor.where(:query_options => {:active => true}, :scopes => { :global => nil }, :methods => [:type, :direct_predictor_ids], :root => :factor).all.to_a
    @traits |= Vger::Resources::Suitability::Factor.where(:query_options => {"companies_factors.company_id" => params[:company_id], :active => true}, :methods => [:type, :direct_predictor_ids], :joins => [:companies], :root => :factor).all.to_a
    @traits = @traits.select{|trait| trait.direct_predictor_ids.blank? }
    @traits = Vger::Resources::Mrf::Trait.where(:query_options => {"company_id" => params[:company_id]}).all.to_a
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
        company_id: @company.id,
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
      @assessment_trait ||= Vger::Resources::Mrf::AssessmentTrait.new({ trait_type: trait_type, trait_id: trait.id, assessment_id: @assessment.id, from_norm_bucket_id: @norm_buckets.sort_by(&:weight).map(&:id).first, to_norm_bucket_id: @norm_buckets.sort_by(&:weight).map(&:id).last })
      @assessment_trait.trait = trait
      @assessment_trait.from_norm_bucket_id ||= @norm_buckets.map(&:id).min
      @assessment_trait.to_norm_bucket_id ||= @norm_buckets.map(&:id).max
      @assessment_trait.assessment_trait = custom_assessment_factors.include?(trait.id) && !trait.is_a?(Vger::Resources::Mrf::Trait)
      @assessment_traits.push @assessment_trait
    end
  end
  
  def get_competencies
    #@global_competencies = Vger::Resources::Suitability::Competency.global(:query_options => {:active => true}, :methods => [:factor_names], :order => ["name ASC"]).to_a
    @local_competencies = Vger::Resources::Suitability::Competency.where(:query_options => { "companies_competencies.company_id" => @company.id, :active => true }, :methods => [:factor_names, :mrf_trait_names], :order => ["name ASC"], :joins => "companies").all.to_a
  end
end
