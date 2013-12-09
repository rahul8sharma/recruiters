class AssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_assessment, :except => [:index]
  before_filter :get_meta_data, :only => [:new, :norms, :competency_norms]
  before_filter :get_company
  
  
  layout "tests"
  
  def show
    @assessment = Vger::Resources::Suitability::Assessment.find(params[:id])
    @assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:include  => [:functional_area, :industry, :job_experience, :from_norm_bucket, :to_norm_bucket], :include => { :factor => { :methods => [:type, :direct_predictor_ids] } }).all.to_a
    
    direct_predictor_parent_ids = @assessment_factor_norms.collect{ |x| x.factor.direct_predictor_ids.present? ? x.factor_id : nil }.compact.uniq
    direct_predictor_norms = @assessment_factor_norms.select{ |x| direct_predictor_parent_ids.include? x.factor_id }.uniq
    alarm_factor_norms = @assessment_factor_norms.select{ |x| x.factor.type == "Suitability::AlarmFactor" }.uniq
    @assessment_factor_norms = @assessment_factor_norms - direct_predictor_norms
    @other_norms = direct_predictor_norms
  end

  def competencies
    @global_competencies = Vger::Resources::Suitability::Competency.where(:query_options => { :company_id => nil, :active => true }).all.to_a
    @local_competencies = Vger::Resources::Suitability::Competency.where(:query_options => { :company_id => @company.id, :active => true }).all.to_a
    if request.get?
    else
      params[:assessment] ||= {}
      params[:assessment][:competencies] ||= []
      if params[:assessment][:competencies].blank?
        flash[:error] = "Please select at least one competency to proceed."
        return
      else
        params[:assessment][:competencies].map!(&:to_i)
        @assessment = Vger::Resources::Suitability::Assessment.save_existing(@assessment.id, { competency_ids: params[:assessment][:competencies] })
        if @assessment.error_messages.blank?
          redirect_to competency_norms_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id)          
        else
          flash[:error] = @assessment.error_messages.join("<br/>")
        end
      end  
    end
  end

  def competency_norms
    @competencies = Vger::Resources::Suitability::Competency.where(:query_options => { :id => @assessment.competency_ids }).all.to_a
    get_competency_norms
    if request.get?
    else
      store_assessment_factor_norms
    end
  end


  # fetches norms data
  # GET : renders norms when request method is get
  # PUT : updates assessment and renders styles
  def norms
    get_norms
    if request.get?
      if params[:assessment]
        @assessment = Vger::Resources::Suitability::Assessment.save_existing(@assessment.id, params[:assessment])
      end
    elsif request.put?  
      store_assessment_factor_norms
      create_or_update_set
    end
  end
  
  # fetches styles data
  # GET : renders styles
  # PUT : updates assessment and redirects to add_candidates
  def styles
    get_styles
    if request.put?  
      params[:assessment] ||= {}
      @assessment = Vger::Resources::Suitability::Assessment.save_existing(@assessment.id, params[:assessment])
      if @assessment.error_messages.blank?
        create_or_update_set
        redirect_to add_candidates_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id) and return
      else
        @assessment.error_messages << @assessment.errors.full_messages.dup
        @assessment.error_messages.flatten!
        flash[:error] = @assessment.error_messages.join("<br/>")
      end
    end  
  end
  
  # GET /assessments
  def index
    @assessments = Vger::Resources::Suitability::Assessment.where(:query_options => { :assessable_id => params[:company_id], :assessable_type => "Company" }, :order => "created_at DESC", :page => params[:page], :per => 15)
  end
  
  # GET /assessments/new
  # GET /assessments/new.json
  def new
  end

  # POST /assessments
  # POST /assessments.json
  # POST creates assessment and redirects to norms page
  def create
    default_norm_bucket_ranges = get_default_norm_bucket_ranges
    if default_norm_bucket_ranges.empty? && current_user.type == "SuperAdmin"
      flash[:alert] = "Custom norms not present for this combination. Global norms have been picked." 
    end
    respond_to do |format|
      if @assessment.valid? and @assessment.save
        redirect_path = if @assessment.assessment_type == "fit"
          norms_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id)
        else
          competencies_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id)
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
      @assessment = Vger::Resources::Suitability::Assessment.find(params[:id], :include => [:functional_area, :industry, :job_experience], :methods => [:competency_ids])
      if(@assessment.company_id.to_i == params[:company_id].to_i)
      else
        redirect_to root_path, alert: "Page you are looking for doesn't exist."
      end
    else
      @assessment = Vger::Resources::Suitability::Assessment.new(params[:assessment])
      @assessment.assessment_type = params[:fit].present? ? "fit" : "competency"
      @assessment.assessable_type = "Company"
      @assessment.assessable_id = params[:company_id]
      @assessment.company_id = params[:company_id]
    end
  end
  
  # fetches meta data for new assessment and adding norms to existing assessment 
  def get_meta_data
    factors = Vger::Resources::Suitability::Factor.active.where(:methods => [:type]).all.to_a
    factors |= Vger::Resources::Suitability::AlarmFactor.active.where(:methods => [:type]).all.to_a
    @factors = Hash[factors.collect{|x| [x.id,x]}]
    @functional_areas = Hash[Vger::Resources::FunctionalArea.active.all.to_a.collect{|x| [x.id,x]}]
    @industries = Hash[Vger::Resources::Industry.active.all.to_a.collect{|x| [x.id,x]}]
    @job_experiences = Hash[Vger::Resources::JobExperience.active.all.to_a.collect{|x| [x.id,x]}]
  end
  
  # fetches default factor norms
  # fetches norm buckets for dropdowns
  # fetches default_norm_bucket_ranges for the assessment's FA, Industry and Exp
  # creates job_assessment_factor_norm for each factor with default values   
  def get_norms
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(:order => "weight ASC").all
    @fits = Vger::Resources::Suitability::Fit.all
    
    default_norm_bucket_ranges = get_default_norm_bucket_ranges
    
    added_factors = @assessment.job_assessment_factor_norms.where(:include => { :factor => { :methods => [:type] } }).all.to_a
    added_factor_ids = added_factors.map(&:factor_id)
    @factor_norms_by_fit = {}
    @fits.each do |fit|
      norms_by_fit = default_norm_bucket_ranges.select{|default_norm| fit.factor_ids.include? (default_norm.factor_id)}  
      
      assessment_factor_norms = added_factors.select{|assessment_norm| fit.factor_ids.include? (assessment_norm.factor_id)}

      factors_by_fit = @factors.select{|id,factor| fit.factor_ids.include? id }.values      
      
      @factor_norms_by_fit[fit] = {
        :factors => assessment_factor_norms.select{|x| x.factor.type == 'Suitability::Factor'},
        :alarm_factors => assessment_factor_norms.select{|x| x.factor.type == 'Suitability::AlarmFactor'}
      }
      
      factors_by_fit.each do |factor|
        default_norm_bucket_range = default_norm_bucket_ranges.find{|x| x.factor_id == factor.id}
        #next if @factors[default_norm_bucket_range.factor_id].nil?
        if default_norm_bucket_range
          assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
            default_norm_bucket_range.attributes.except("created_at","updated_at","id").\
               merge(:from_norm_bucket_id => default_norm_bucket_range.from_norm_bucket_id, 
                     :to_norm_bucket_id => default_norm_bucket_range.to_norm_bucket_id)
          )
        else
          assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
            :from_norm_bucket_id => @norm_buckets.first.id, 
            :to_norm_bucket_id => @norm_buckets.last.id,
            :factor_id => factor.id,
            :functional_area_id => @assessment.functional_area_id,
            :industry_id => @assessment.industry_id,
            :job_experience_id => @assessment.job_experience_id
          )
          
        end
        
        # to avoid calls to API, set fa, industry and exp from already fetched data
        assessment_factor_norm.functional_area = @functional_areas[@assessment.functional_area_id]
        assessment_factor_norm.industry = @industries[@assessment.industry_id]
        assessment_factor_norm.job_experience = @job_experiences[@assessment.job_experience_id]
        assessment_factor_norm.factor = @factors[factor.id]
        
        unless added_factor_ids.include? factor.id
          if assessment_factor_norm.factor.type == 'Suitability::AlarmFactor'
            @factor_norms_by_fit[fit][:alarm_factors] << assessment_factor_norm  
          else
            @factor_norms_by_fit[fit][:factors] << assessment_factor_norm  
          end
        end
      end  
    end
  end
  
  # fetches default factor norms
  # fetches norm buckets for dropdowns
  # fetches default_norm_bucket_ranges for the assessment's FA, Industry and Exp
  # creates job_assessment_factor_norm for each factor with default values   
  def get_competency_norms
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(:order => "weight ASC").all
    default_norm_bucket_ranges = get_default_norm_bucket_ranges
                                    
    added_factors = @assessment.job_assessment_factor_norms.where(:include => { :factor => { :methods => [:type] } }).all.to_a
    added_factor_ids = added_factors.map(&:factor_id)
    @factor_norms_by_competency = {}
    @factor_norms = []
    @alarm_factor_norms = []                

    @competencies.each do |competency|
      norms_by_competency = default_norm_bucket_ranges.select{|default_norm| competency.factor_ids.include? (default_norm.factor_id)}  
      
      assessment_factor_norms = added_factors.select{|assessment_norm| competency.factor_ids.include? (assessment_norm.factor_id)}
      factors_by_competency = @factors.select{|id,factor| competency.factor_ids.include? id }.values      
      
      factors = assessment_factor_norms.select{|x| x.factor.type == 'Suitability::Factor'}  
      alarm_factors = assessment_factor_norms.select{|x| x.factor.type == 'Suitability::AlarmFactor'}
      
      @factor_norms << factors
      @alarm_factor_norms << alarm_factors

      @factor_norms_by_competency[competency] = {
        :factors => factors, 
        :alarm_factors => alarm_factors
      }
      
      factors_by_competency.each do |factor|
        default_norm_bucket_range = default_norm_bucket_ranges.find{|x| x.factor_id == factor.id}
        #next if @factors[default_norm_bucket_range.factor_id].nil?
        if default_norm_bucket_range
          assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
            default_norm_bucket_range.attributes.except("created_at","updated_at","id").\
               merge(:from_norm_bucket_id => default_norm_bucket_range.from_norm_bucket_id, 
                     :to_norm_bucket_id => default_norm_bucket_range.to_norm_bucket_id)
          )
        else
          assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
            :from_norm_bucket_id => @norm_buckets.first.id, 
            :to_norm_bucket_id => @norm_buckets.last.id,
            :factor_id => factor.id,
            :functional_area_id => @assessment.functional_area_id,
            :industry_id => @assessment.industry_id,
            :job_experience_id => @assessment.job_experience_id
          )
          
        end
        
        # to avoid calls to API, set fa, industry and exp from already fetched data
        assessment_factor_norm.functional_area = @functional_areas[@assessment.functional_area_id]
        assessment_factor_norm.industry = @industries[@assessment.industry_id]
        assessment_factor_norm.job_experience = @job_experiences[@assessment.job_experience_id]
        assessment_factor_norm.factor = @factors[factor.id]
        
        unless added_factor_ids.include? factor.id
          if assessment_factor_norm.factor.type == 'Suitability::AlarmFactor'
            @factor_norms_by_competency[competency][:alarm_factors] << assessment_factor_norm  
          else
            @factor_norms_by_competency[competency][:factors] << assessment_factor_norm  
          end
        end
      end  
    end
    @factor_norms = @factor_norms.flatten.compact.uniq
    @alarm_factor_norms = @alarm_factor_norms.flatten.compact.uniq
  end
  
  
  # fetch styles data
  # fetch all direct predictors
  # fetch parents of all direct predictors
  # fetch all alarm factors
  # create new job_assessment_factor_norm for each factor
  def get_styles
    @norm_buckets = Vger::Resources::Suitability::NormBucket.all
    all_direct_predictor_parent_ids = Vger::Resources::Suitability::DirectPredictor.active({ :type => "Suitability::DirectPredictor" }).where(:include => [ :parent ]).to_a.map(&:parent_id).uniq
    
    all_direct_predictors = Vger::Resources::Suitability::Factor.active({ :id => all_direct_predictor_parent_ids }).to_a
    
    @job_assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:include => { :factor => { :methods => [:type] } }).all.select{|x| all_direct_predictor_parent_ids.include? x.factor_id}
    
    selected_parents = @job_assessment_factor_norms.map(&:factor_id)
    
    all_direct_predictors.each do |factor|
      assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(:functional_area_id => @assessment.functional_area_id, :industry_id => @assessment.industry_id, :job_experience_id => @assessment.job_experience_id, :factor_id => factor.id)
      assessment_factor_norm.factor = factor
      @job_assessment_factor_norms.push assessment_factor_norm unless selected_parents.include? factor.id
    end  
  end
  
  def get_default_norm_bucket_ranges
    query_options = { 
      :functional_area_id => @assessment.functional_area_id,
      :industry_id => @assessment.industry_id,
      :job_experience_id => @assessment.job_experience_id
    }
    default_norm_bucket_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.\
                                    where(:query_options => query_options).all.to_a
  end
  
  def get_company
    methods = []
    if params[:action] == "index"
      if Rails.application.config.statistics[:load_assessmentwise_statistics]
        methods << :assessmentwise_statistics
      end
    end
    @company = Vger::Resources::Company.find(params[:company_id], :methods => methods)
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
      @assessment = Vger::Resources::Suitability::Assessment.save_existing(@assessment.id, params[:assessment])
      if @assessment.error_messages.blank?
        redirect_to styles_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id)          
      else
        flash[:error] = @assessment.error_messages.join("<br/>")
      end
    end 
  end
  
  def create_or_update_set
    set_params = Rails.application.config.default_set.merge(:assessment_id => @assessment.id)
    sets = Vger::Resources::Suitability::Set.where(:assessment_id => @assessment.id, :query_options => { :name => Rails.application.config.default_set["name"] }).all.to_a
    if !sets.present?
      set_params.merge!(:end_index => @assessment.item_ids.count)
      set_params.merge!(:page_size => params[:page_size]) if params[:page_size].present?
      Vger::Resources::Suitability::Set.create(set_params)
    else
      set = sets.first
      page_size = (params[:page_size].present? ? params[:page_size] : set_params["page_size"])
      Vger::Resources::Suitability::Set.save_existing(set.id, assessment_id: @assessment.id, :end_index => @assessment.item_ids.count, :page_size => page_size)
    end
  end
end
