class AssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_assessment, :except => [:index]
  before_filter :get_meta_data, :only => [:new, :norms, :competency_norms]
  
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
      if params[:assessment]
        @assessment = api_resource.save_existing(@assessment.id, params[:assessment])
      end
    elsif request.put?
      store_assessment_factor_norms
      create_or_update_set    
    end
  end
  
  
  # GET /assessments/new
  # GET /assessments/new.json
  def new
  end

  protected
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
      
      factor_norms = 
      
      @factor_norms_by_fit[fit] = {
        :factors => assessment_factor_norms.select{|x| x.factor.type == 'Suitability::Factor'},
        :alarm_factors => assessment_factor_norms.select{|x| x.factor.type == 'Suitability::AlarmFactor'}
      }
      
      factors_by_fit.each do |factor|
        default_norm_bucket_range = default_norm_bucket_ranges.find{|x| x.factor_id == factor.id}
        
        assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
          :factor_id => factor.id,
          :functional_area_id => @assessment.functional_area_id,
          :industry_id => @assessment.industry_id,
          :job_experience_id => @assessment.job_experience_id
        )
        
        if default_norm_bucket_range
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
        assessment_factor_norm.factor = @factors[factor.id]
        
        unless added_factor_ids.include? factor.id
          if assessment_factor_norm.factor.type == 'Suitability::AlarmFactor'
            @factor_norms_by_fit[fit][:alarm_factors] << assessment_factor_norm  
          else
            @factor_norms_by_fit[fit][:factors] << assessment_factor_norm  
          end
        end
      end
      factor_norms = @factor_norms_by_fit[fit][:factors]
      @factor_norms_by_fit[fit][:factors] = fit.factor_ids.map{|factor_id| factor_norms.detect{|factor_norm| factor_norm.factor_id == factor_id }}.compact  
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
  
  def create_or_update_set
    set_params = Rails.application.config.default_set.merge(:assessment_id => @assessment.id)
    sets = Vger::Resources::Suitability::Set.where(:assessment_id => @assessment.id, :query_options => { :name => Rails.application.config.default_set["name"] }).all.to_a
    @assessment.item_ids ||= []
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
