class Suitability::StandardAssessmentsController < AssessmentsController
  before_filter :get_assessment, :except => [:index]
  before_filter :get_meta_data, :only => [:new, :norms, :competency_norms]
  
  layout "tests"
  
  def api_resource
    Vger::Resources::Suitability::StandardAssessment
  end
  
  def competencies
    @global_competencies = Vger::Resources::Suitability::Competency.global(:query_options => {:active => true}, :methods => [:factor_names], :order => ["name ASC"]).to_a
    @local_competencies = []
    if request.get?
    else
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
          redirect_to competency_norms_standard_assessment_path(:id => @assessment.id)          
        else
          flash[:error] = @assessment.error_messages.join("<br/>")
        end
      end  
    end
  end

  # fetches styles data
  # GET : renders styles
  # PUT : updates assessment and redirects to add_candidates
  def styles
    get_styles
    if request.put?  
      params[:assessment] ||= {}
      @assessment = api_resource.save_existing(@assessment.id, params[:assessment])
      if @assessment.error_messages.blank?
        create_or_update_set
        redirect_to standard_assessment_path(:id => @assessment.id) and return
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
    order_type = params[:order_type] || "DESC"
    @assessments = api_resource.where(:query_options => { :assessment_type => ["fit","competency"] }, :order => "#{order_by} #{order_type}", :page => params[:page], :per => 5)
  end
  
  # POST /assessments
  # POST /assessments.json
  # POST creates assessment and redirects to norms page
  def create
    #default_norm_bucket_ranges = get_default_norm_bucket_ranges
    respond_to do |format|
      if @assessment.valid? and @assessment.save
        redirect_path = if @assessment.assessment_type == api_resource::AssessmentType::FIT
          norms_standard_assessment_path(:id => @assessment.id)
        elsif @assessment.assessment_type == api_resource::AssessmentType::COMPETENCY
          competencies_standard_assessment_path(:id => @assessment.id)
        elsif  @assessment.assessment_type == api_resource::AssessmentType::BENCHMARK
          norms_standard_benchmark_path(:id => @assessment.id)
        end
        format.html { redirect_to redirect_path }
      else
        get_meta_data
        flash[:error] ||= @assessment.errors.values.flatten.join(",") rescue ""
        format.html { render action: "new" }
      end
    end
  end
 
  protected
  
  # fetches assessment if id is present in params
  # creates new assessment otherwise
  def get_assessment
    if params[:id].present?
      @assessment = api_resource.find(params[:id], :include => [:functional_area, :industry, :job_experience], :methods => [:competency_ids])
    else
      @assessment = api_resource.new(params[:assessment])
      @assessment.report_types ||= []
      assessment_type = if params[:fit].present?
         api_resource::AssessmentType::FIT
      elsif params[:competency].present?  
        api_resource::AssessmentType::COMPETENCY
      else
        @assessment.report_types << api_resource::ReportType::BENCHMARK
        api_resource::AssessmentType::BENCHMARK
      end
      if params[:enable_training_requirements_report].present?
        @assessment.report_types << api_resource::ReportType::TRAINING_REQUIREMENT
      end
      @assessment.report_types.uniq!
      @assessment.assessment_type = assessment_type
    end
  end
  
  def store_assessment_factor_norms
    params[:assessment][:job_assessment_factor_norms_attributes] ||= {}
    if !params[:assessment][:job_assessment_factor_norms_attributes].select{|index,data| data[:_destroy] != "true" }.present?
      flash[:error] = "Please select at least one factor to proceed."
      return
    else
      params[:assessment][:job_assessment_factor_norms_attributes].each do |index, factor_norms_attributes|
        norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
        if factor_norms_attributes[:from_norm_bucket_id]
          from_weight = norm_buckets_by_id[factor_norms_attributes[:from_norm_bucket_id].to_i].weight
          to_weight = norm_buckets_by_id[factor_norms_attributes[:to_norm_bucket_id].to_i].weight
          if from_weight > to_weight
            flash[:error] = "Upper Limit in the Desired/Acceptable Score Range must be of a greater value than the selected Lower Limit."
            return
          end
        end
      end
      @assessment = api_resource.save_existing(@assessment.id, params[:assessment])
      if @assessment.error_messages.blank?
        if params[:save_and_close].present?
          redirect_to standard_assessment_path(:id => @assessment.id)
        else
          redirect_to add_candidates_standard_assessment_path(:id => @assessment.id)          
        end
      else
        flash[:error] = @assessment.error_messages.join("<br/>")
      end
    end 
  end
end
