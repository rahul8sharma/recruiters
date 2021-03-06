class Suitability::CustomAssessmentsController < AssessmentsController
  include TemplatesHelper
  before_filter :get_company
  before_filter :get_defined_forms, :only => [:new, :edit, :create]
  before_filter :get_completion_notification_templates, :only => [:edit, :select_templates]
  before_filter :get_invitation_templates, :only => [:edit, :select_templates]
  before_filter :get_reminder_templates, :only => [:edit, :select_templates]
  before_filter :get_custom_form, :only => [:edit]
  after_filter :set_cache_buster

  layout "tests"

  def api_resource
    Vger::Resources::Suitability::CustomAssessment
  end

  def norms
    get_norms
    if request.get?
      #if params[:assessment]
      #  @assessment = api_resource.save_existing(@assessment.id, params[:assessment])
      #end
    elsif request.put?
      params[:assessment][:job_assessment_factor_norms_attributes] ||= {}
      traits_range = Rails.application.config.validators["traits_range"][current_user.role.underscore]
      selected_traits_size = params[:assessment][:job_assessment_factor_norms_attributes].select{|index,data| data[:_destroy] != "true" }.keys.size

      if selected_traits_size >= traits_range["min"] && selected_traits_size <= traits_range["max"]
        store_assessment_factor_norms
      else
        if selected_traits_size < traits_range["min"] || selected_traits_size > traits_range["max"]
          flash[:error] = "Please select at least #{traits_range["min"]} traits to create the assessment.Maximum traits allowed in an assessment is #{traits_range["max"]}"
        # elsif selected_traits_size > traits_range_max
        #   flash[:error] = "Maximum traits allowed in an assessment is 18 to ensure optimum assessment experience. Please deselect a few traits to Proceed."
        end
        render :action => :norms
      end

    end
  end

  def set_weightage
    if request.put?
      if !store_weights
        get_factors
        get_weights
      end
    else
      get_factors
      get_weights
    end  
  end
  
  def get_functional_assessment_traits
    added_assessment_traits = Hash[@assessment.functional_assessment_traits.collect{|assessment_trait| ["#{assessment_trait.trait_id}",assessment_trait] }]

    @functional_assessment_traits = []
    @functional_traits.each do |trait|
      @functional_assessment_trait = added_assessment_traits["#{trait.id}"]
      @functional_assessment_trait ||= Vger::Resources::Functional::AssessmentTrait.new({ trait_id: trait.id, assessment_id: @assessment.id,
             assessment_type: "Suitability::CustomAssessment" })
      @functional_assessment_trait.selected = @functional_assessment_trait.id.present?
      @functional_assessment_trait.from_norm_bucket_id = @functional_norm_buckets.first.id
      @functional_assessment_trait.to_norm_bucket_id = @functional_norm_buckets.last.id
      @functional_assessment_traits.push @functional_assessment_trait
    end
  end

  def functional_traits
    get_functional_traits
    get_functional_assessment_traits
    get_sections
    if request.put?
      params[:assessment] ||= {}
      params[:assessment][:functional_assessment_traits_attributes] ||= {}
      params[:assessment][:functional_assessment_traits_attributes].each do |index, factor_norms_attributes|
        norm_buckets_by_id = Hash[@functional_norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
        if factor_norms_attributes[:from_norm_bucket_id]
          from_weight = norm_buckets_by_id[factor_norms_attributes[:from_norm_bucket_id].to_i].weight
          to_weight = norm_buckets_by_id[factor_norms_attributes[:to_norm_bucket_id].to_i].weight
          if from_weight >= to_weight
            flash[:error] = "Upper Limit in the Expected Score Range must be of a greater value than the selected Lower Limit."
            return
          end
        end
      end
      @assessment.other_subjective_items = params[:assessment][:other_subjective_items].keys if params[:assessment][:other_subjective_items].present?
      @assessment.other_objective_items = params[:assessment][:other_objective_items].keys if params[:assessment][:other_objective_items].present?
      @assessment = api_resource.save_existing(@assessment.id, params[:assessment])

      # This is a bad workaround to allow superuser to proceed even if items are not available
      # Need a better way to manage this
      if @assessment.error_messages.blank?
        redirect_to self.send("report_configuration_company_#{@assessment.assessment_type}_assessment_path", params[:company_id], @assessment.id)
      else
        flash[:error] = @assessment.error_messages.join("<br/>")
        redirect_to functional_traits_company_custom_assessment_path(:company_id => params[:company_id],:id => @assessment.id)
      end
    end
  end

  def competencies
    get_competencies(:for_suitability)
    if request.put?
      check_competencies_and_proceed
    end
  end
  
  def report_configuration
    if request.put?
      params[:assessment] ||= {}
      params[:assessment][:report_configuration] ||= {}.to_json
      params[:assessment][:report_configuration] = JSON.parse(params[:assessment][:report_configuration])
      @assessment = api_resource.save_existing(@assessment.id, params[:assessment])
      if @assessment.error_messages.blank?
        redirect_to self.send("select_templates_company_#{@assessment.assessment_type}_assessment_path", params[:company_id], @assessment.id)
      else
        flash[:error] = @assessment.error_messages.join("<br/>")
        redirect_to report_configuration_company_custom_assessment_path(:company_id => params[:company_id],:id => @assessment.id)
      end
    else
    end
  end

  def competencies_url
    competency_norms_company_custom_assessment_path(:company_id => params[:company_id], :id => @assessment.id)
  end

  # fetches styles data
  # GET : renders styles
  # PUT : updates assessment and redirects to add_users
  def styles
    get_styles
    if request.put?
      params[:assessment] ||= {}
      @assessment = api_resource.save_existing(@assessment.id, params[:assessment])
      if @assessment.error_messages.blank?
        redirect_to add_users_company_custom_assessment_path(:company_id => params[:company_id], :id => @assessment.id) and return
      else
        @assessment.error_messages << @assessment.errors.full_messages.dup
        @assessment.error_messages.flatten!
        flash[:error] = @assessment.error_messages.join("<br/>")
      end
    end
  end

  # GET /assessments
  def index
    order_by = params[:order_by] || "created_at"
    params[:order_by] ||= order_by
    order_type = params[:order_type] || "DESC"
    @languages = Hash[Vger::Resources::Language.all.map{|language| [language.language_code,language.name] }]

    @assessments = api_resource.where(
      :query_options => { 
        :company_id => params[:company_id], 
        :assessment_type => ["fit","competency"] 
      }, 
      :select => [:id, :created_at, :name, :languages, :candidate_stage],
      :order => "#{order_by} #{order_type}", 
      :page => params[:page], 
      :per => 15
    )
  end


  # POST /assessments
  # POST /assessments.json
  # POST creates assessment and redirects to norms page
  def create
    respond_to do |format|
      if @assessment.valid? and @assessment.save
        if params[:defined_form_id].present?
          factual_information_form = Vger::Resources::FormBuilder::FactualInformationForm.create({
            :defined_form_id => params[:defined_form_id],
            :company_id => @company.id,
            :assessment_type => "Suitability::CustomAssessment",
            :assessment_id => @assessment.id
          })
        end
        redirect_path = if @assessment.assessment_type == api_resource::AssessmentType::COMPETENCY
          competencies_company_custom_assessment_path(:company_id => params[:company_id], :id => @assessment.id)
        else
          self.send("norms_company_#{@assessment.assessment_type}_assessment_path", params[:company_id], @assessment.id)
        end
        format.html { redirect_to redirect_path }
      else
        get_meta_data
        add_set
        flash[:error] = @assessment.error_messages.join("<br/>") rescue ""
        format.html { render action: "new" }
      end
    end
  end
  
  def download_pdf_reports
    url = S3Utils.get_url(params[:bucket], params[:key])
    redirect_to url
  end
  
  def select_templates
    if request.put?
      @assessment = api_resource.save_existing(@assessment.id, params[:assessment])
      if @assessment.error_messages.blank?
        redirect_to self.send("add_users_company_#{@assessment.assessment_type}_assessment_path", params[:company_id], @assessment.id)
      else
        flash[:error] = @assessment.error_messages.join("<br/>")
        redirect_to select_templates_company_custom_assessment_path(:company_id => params[:company_id],:id => @assessment.id)
      end
    else
    end
  end

  protected

  # fetches assessment if id is present in params
  # creates new assessment otherwise
  def get_assessment
    if params[:id].present?
      @assessment = api_resource.find(params[:id], 
        :include => [:functional_area, :industry, :job_experience], 
        :methods => [:competency_ids]
      )
      if(@assessment.company_id.to_i == params[:company_id].to_i)
      else
        redirect_to root_path, error: "Page you are looking for doesn't exist."
      end
    else
      @assessment = api_resource.new(params[:assessment])
      @custom_form = nil
      @assessment.report_types ||= []
      if params[:enable_training_requirements_report].present?
        @assessment.report_types << api_resource::ReportType::TRAINING_REQUIREMENT
      end
      @assessment.report_types.uniq!
      @assessment.company_id = params[:company_id]
    end
  end
  
  def get_custom_form
    @custom_form = Vger::Resources::FormBuilder::FactualInformationForm.where(
      query_options: {
        assessment_type: @assessment.class.name.gsub("Vger::Resources::",""),
        assessment_id: @assessment.id
      }
    ).all.first
  end

  def get_company
    methods = []
    if ["show","index", "training_requirements","home"].include? params[:action]
      methods << :assessmentwise_statistics
    end
    if ["show"].include? params[:action]
      methods << :factors_map
    end
    @company = Vger::Resources::Company.find(
      params[:company_id], 
      :methods => methods,
      :select  => [:id, :name, :configuration, :parent_id] 
    )
  end

  def store_assessment_factor_norms
    params[:assessment][:job_assessment_factor_norms_attributes] ||= {}
    params[:assessment][:job_assessment_factor_norms_attributes].each do |index, factor_norms_attributes|
      norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
      if factor_norms_attributes[:from_norm_bucket_id]
        from_weight = norm_buckets_by_id[factor_norms_attributes[:from_norm_bucket_id].to_i].weight
        to_weight = norm_buckets_by_id[factor_norms_attributes[:to_norm_bucket_id].to_i].weight
        if from_weight > to_weight
          flash[:error] = "Upper Limit in the Expected Score Range must be of a greater value than the selected Lower Limit."
          return
        end
      end
    end
    @assessment = api_resource.save_existing(@assessment.id, params[:assessment])
    if @assessment.error_messages.blank?
      #if @assessment.assessment_type == api_resource::AssessmentType::BENCHMARK
      flash[:error] = @assessment.error_messages.uniq.join("<br/>")
      redirect_to self.send("set_weightage_company_#{@assessment.assessment_type}_assessment_path", params[:company_id], @assessment.id)
    else
      flash[:error] = @assessment.error_messages.uniq.join("<br/>")
    end
  end

  def get_defined_forms
    @defined_forms = Vger::Resources::FormBuilder::DefinedForm.where(
      scopes: { for_company_id: @company.id }, 
      query_options: { active: true },
      methods: [:parent_uid]
    ).all.to_a
  end
  
  def get_sections
    @sections = Vger::Resources::Section.where(query_options: {active: true, company_id: @company.id}, include: [:subjective_items, :objective_items]).all.to_a
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
      :methods => [:factor_names], 
      :order => ["name ASC"], 
      :joins => "companies"
    ).all.to_a    
  end

  def check_competencies_and_proceed
    params[:assessment] ||= {}
    params[:assessment][:competencies] ||= []
    if params[:assessment][:competencies].blank?
      flash[:error] = "Competencies to be measured must be selected before proceeding!"
      return
    else
      selected_competency_ids = params[:assessment][:competencies].map(&:to_i)
      selected_competencies = Hash[params[:assessment][:competency_order].select{|competency_id,order| selected_competency_ids.include?(competency_id.to_i) }]
      competency_order = Hash[selected_competencies.map{|competency_id,order| [competency_id.to_i,order.to_i] }]
      competency_order = Hash[competency_order.sort_by{|competency_id, order| order }]
      if competency_order.values.size != competency_order.values.uniq.size
        flash[:error] = "Competencies should have unique order!"
        return
      end
      ordered_competencies = competency_order.keys.select{|competency_id| selected_competency_ids.include?(competency_id) }
      @assessment = api_resource.save_existing(@assessment.id, { competency_order: ordered_competencies })
      if @assessment.error_messages.blank?
        redirect_to competencies_url
      else
        flash[:error] = @assessment.error_messages.uniq.join("<br/>")
      end
    end
  end
end
