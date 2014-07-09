class AssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_superadmin, :only => [:edit,:update]
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_assessment, :except => [:index]
  before_filter :get_meta_data, :only => [:new, :edit, :norms, :competency_norms]
  before_filter :get_factors, :only => [:norms, :competency_norms]
  before_filter :add_set, :only => [:new]
  
  layout "tests"
  
  def api_resource
    Vger::Resources::Suitability::Assessment
  end
  
  def show
    @assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:include  => [:functional_area, :industry, :job_experience, :from_norm_bucket, :to_norm_bucket], :include => { :factor => { :methods => [:type, :direct_predictor_ids] } }).all.to_a
    
    direct_predictor_parent_ids = @assessment_factor_norms.collect{ |factor_norm| factor_norm.factor.direct_predictor_ids.present? ? factor_norm.factor_id : nil }.compact.uniq
    direct_predictor_norms = @assessment_factor_norms.select{ |factor_norm| direct_predictor_parent_ids.include? factor_norm.factor_id }.uniq
    lie_detector_norms = @assessment_factor_norms.select{ |factor_norm| factor_norm.factor.type == "Suitability::LieDetector" }.uniq
    alarm_factor_norms = @assessment_factor_norms.select{ |factor_norm| factor_norm.factor.type == "Suitability::AlarmFactor" }.uniq
    @assessment_factor_norms = @assessment_factor_norms - direct_predictor_norms - lie_detector_norms
    @other_norms = direct_predictor_norms
    @norm_buckets = Hash[Vger::Resources::Suitability::NormBucket.all.to_a.map{|norm_bucket| [norm_bucket.id,norm_bucket] }]
  end

  def competency_norms
    competencies = Vger::Resources::Suitability::Competency.where(:query_options => { :id => @assessment.competency_order }).all.to_a
    @competencies = @assessment.competency_order.map{|competency_id| competencies.detect{|competency| competency.id == competency_id }}
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
      #if params[:assessment]
      #  @assessment = api_resource.save_existing(@assessment.id, params[:assessment])
      #end
    elsif request.put?
      store_assessment_factor_norms
    end
  end
  
  
  # GET /assessments/new
  # GET /assessments/new.json
  def new
  end
  
  def edit
  end
  
  def update
    @assessment = api_resource.save_existing(@assessment.id, params[:assessment])
    if @assessment.error_messages.present?
      flash[:error] = @assessment.error_messages.join("<br/>").html_safe
      redirect_to edit_company_custom_assessment_path(@company,@assessment)
    else
      flash[:notice] = "Assessment updated successfully!"
      redirect_to company_custom_assessment_path(@company,@assessment)
    end
  end

  protected
  # fetches meta data for new assessment and adding norms to existing assessment 
  def get_meta_data
    @functional_areas = Hash[Vger::Resources::FunctionalArea.active.all.to_a.collect{|x| [x.id,x]}]
    @industries = Hash[Vger::Resources::Industry.active.all.to_a.collect{|x| [x.id,x]}]
    @job_experiences = Hash[Vger::Resources::JobExperience.active.all.to_a.collect{|x| [x.id,x]}]
  end
  
  def get_factors
    factors = Vger::Resources::Suitability::Factor.where(:query_options => {:active => true}, :scopes => { :global => nil }, :methods => [:type, :direct_predictor_ids]).all.to_a
    factors |= Vger::Resources::Suitability::Factor.where(:query_options => {"companies_factors.company_id" => params[:company_id], :active => true}, :methods => [:type, :direct_predictor_ids], :joins => [:companies]).all.to_a
    factors |= Vger::Resources::Suitability::AlarmFactor.active.where(:methods => [:type, :direct_predictor_ids]).all.to_a
    @factors = Hash[factors.sort_by{|factor| factor.name.to_s }.collect{|x| [x.id,x]}]
  end
  
  # fetches default factor norms
  # fetches norm buckets for dropdowns
  # fetches default_norm_bucket_ranges for the assessment's FA, Industry and Exp
  # creates job_assessment_factor_norm for each factor with default values   
  def get_norms
    params[:assessment] ||= {}
    params[:assessment][:job_assessment_factor_norms_attributes] ||= {}
    
    selected_factors = Hash[params[:assessment][:job_assessment_factor_norms_attributes].values.map{|factor_norm_attributes| [factor_norm_attributes[:factor_id].to_i,factor_norm_attributes] }]
    
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(:order => "weight ASC").all
    
    default_norm_bucket_ranges = get_default_norm_bucket_ranges
    
    added_factor_norms = @assessment.job_assessment_factor_norms.where(:include => { :factor => { :methods => [:type] } }).all.to_a
    added_factor_norms_ids = added_factor_norms.map(&:factor_id)
    
    direct_predictor_parent_ids = @factors.collect{ |factor_id,factor| factor.direct_predictor_ids.present? ? factor_id : nil }.compact.uniq

    @factor_norms = []
    @alarm_factor_norms = []
    @factors.each do |factor_id, factor|
      default_norm_bucket_range = default_norm_bucket_ranges.find{|x| x.factor_id == factor_id}
      
      if added_factor_norms_ids.include?(factor_id)
        assessment_factor_norm = added_factor_norms.find{|factor_norm| factor_norm.factor_id == factor_id }
      else
        assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
          :factor_id => factor.id,
          :functional_area_id => @assessment.functional_area_id,
          :industry_id => @assessment.industry_id,
          :job_experience_id => @assessment.job_experience_id,
          :selected => selected_factors.keys.include?(factor_id)
        )
      end
      if assessment_factor_norm.id.present?
      elsif selected_factors.keys.include?(factor_id)
        assessment_factor_norm.from_norm_bucket_id = selected_factors[factor_id][:from_norm_bucket_id].to_i
        assessment_factor_norm.to_norm_bucket_id = selected_factors[factor_id][:to_norm_bucket_id].to_i
      elsif default_norm_bucket_range
        assessment_factor_norm.from_norm_bucket_id = default_norm_bucket_range.from_norm_bucket_id
        assessment_factor_norm.to_norm_bucket_id = default_norm_bucket_range.to_norm_bucket_id
      else
        assessment_factor_norm.from_norm_bucket_id = @norm_buckets.first.id
        assessment_factor_norm.to_norm_bucket_id = @norm_buckets.last.id
      end
      
      # to avoid calls to API, set fa, industry and exp from already fetched data
      assessment_factor_norm.functional_area = @functional_areas[@assessment.functional_area_id]
      assessment_factor_norm.industry = @industries[@assessment.industry_id]
      assessment_factor_norm.job_experience = @job_experiences[@assessment.job_experience_id]
      assessment_factor_norm.factor = factor
      
      if factor.type == 'Suitability::AlarmFactor'
        @alarm_factor_norms << assessment_factor_norm  
      elsif factor.type == 'Suitability::Factor' && !direct_predictor_parent_ids.include?(factor_id)
        @factor_norms << assessment_factor_norm  
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
    factor_ids = []
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

        assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
          :factor_id => factor.id,
          :functional_area_id => @assessment.functional_area_id,
          :industry_id => @assessment.industry_id,
          :job_experience_id => @assessment.job_experience_id
        )
        
        # to avoid calls to API, set fa, industry and exp from already fetched data
        assessment_factor_norm.functional_area = @functional_areas[@assessment.functional_area_id]
        assessment_factor_norm.industry = @industries[@assessment.industry_id]
        assessment_factor_norm.job_experience = @job_experiences[@assessment.job_experience_id]
        assessment_factor_norm.factor = @factors[factor.id]
        
        if default_norm_bucket_range
          assessment_factor_norm.from_norm_bucket_id = default_norm_bucket_range.from_norm_bucket_id
          assessment_factor_norm.to_norm_bucket_id = default_norm_bucket_range.to_norm_bucket_id
        else
          assessment_factor_norm.from_norm_bucket_id = @norm_buckets.first.id
          assessment_factor_norm.to_norm_bucket_id = @norm_buckets.last.id
        end
        
        unless added_factor_ids.include? factor.id
          if assessment_factor_norm.factor.type == 'Suitability::AlarmFactor'
            @factor_norms_by_competency[competency][:alarm_factors] << assessment_factor_norm  
          else
            @factor_norms_by_competency[competency][:factors] << assessment_factor_norm  
          end
        end
      end  
      factor_ids << competency.factor_ids
    end
    @factor_norms = @factor_norms.flatten.compact.uniq.map
    @factor_norms = factor_ids.flatten.uniq.map{|factor_id| @factor_norms.detect{|factor_norm| factor_norm.factor_id == factor_id } }
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
    
    @assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:include => { :factor => { :methods => [:type] } }).all
    
    @job_assessment_factor_norms = @assessment_factor_norms.select{|x| all_direct_predictor_parent_ids.include? x.factor_id}
    
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
    if default_norm_bucket_ranges.empty?  
      if current_user.type == "SuperAdmin" && ["norms","competency_norms"].include?(params[:action])
        flash[:alert] = "Custom norms not present for this combination. Global norms have been picked." 
      end
      query_options = {
        :functional_area_id => nil,
        :industry_id => nil,
        :job_experience_id => nil
      }
      default_norm_bucket_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.\
                                    where(:query_options => query_options).all.to_a
    end
    default_norm_bucket_ranges       
  end
  
  def add_set
    @assessment.sets = []
    @assessment.sets.push Vger::Resources::Suitability::Set.new
  end
end
