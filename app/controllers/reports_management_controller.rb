class ReportsManagementController < ApplicationController
  before_filter :authenticate_user!
  layout 'admin'

  def regenerate_reports
    if params[:args][:assessment_id].present? && params[:args][:email].present?
      assessment = Vger::Resources::Suitability::CustomAssessment.regenerate_reports(params)
      render :json => { :status => "Job Started", :job_id => assessment.job_id }
    else
      redirect_to report_management_path, alert: "Please specify email and assessment_id."
    end
  end
  
  def regenerate_exit_individual_reports
    if params[:args][:survey_id].present? && params[:args][:email].present?
      survey = Vger::Resources::Exit::Survey.regenerate_individual_reports(params)
      render :json => { :status => "Job Started", :job_id => survey.job_id }
    else
      redirect_to report_management_path, alert: "Please specify email and survey_id."
    end
  end
  
  def regenerate_exit_group_reports
    if (params[:args][:survey_id].present? || params[:args][:group_report_id].present? ) && params[:args][:email].present?
      survey = Vger::Resources::Exit::Survey.regenerate_group_reports(params)
      render :json => { :status => "Job Started", :job_id => survey.job_id }
    else
      redirect_to report_management_path, alert: "Please specify email and survey_id or group report id."
    end
  end

  def regenerate_mrf_reports
    if params[:args][:assessment_id].present? && params[:args][:email].present?
      assessment = Vger::Resources::Mrf::Assessment.regenerate_reports(company_id: params[:args][:company_id], :args => params[:args])
      render :json => { :status => "Job Started", :job_id => assessment.job_id }
    else
      redirect_to report_management_path, alert: "Please specify email and assessment_id."
    end
  end

  def report_management
  end

  def report_generator
    @functional_areas = Hash[Vger::Resources::FunctionalArea.where(:query_options => {:active=>true},:order => "name ASC")\
                          .all.to_a.collect{|x| [x.id,x]}]
    @industries = Hash[Vger::Resources::Industry.where(:query_options => {:active=>true},:order => "name ASC")\
                        .all.to_a.collect{|x| [x.id,x]}]
    @job_experiences = Hash[Vger::Resources::JobExperience.active.all.to_a.collect{|x| [x.id,x]}]
    @objective_items = Vger::Resources::ObjectiveItem.where(:query_options => { :active => true}, :include => [ :options ]).all.to_a
    @subjective_items = Vger::Resources::SubjectiveItem.active.all.to_a

  end


  def report_generator_scores
    params[:assessment][:factors] ||= {}
    params[:assessment][:competency] ||= {}
    params[:assessment][:functional_traits] ||= {}
    params[:objective_items] ||= {}
    params[:subjective_items] ||= {}

    factors = Vger::Resources::Suitability::Factor.where(:query_options => {:active => true,:type=>"Suitability::Factor"}, :scopes => { :global => nil }, :methods => [:type, :direct_predictor_ids]).all.to_a
    factors |= Vger::Resources::Suitability::Factor.where(:query_options => {"companies_factors.company_id" => params[:assessment][:company_id], :active => true}, :methods => [:type, :direct_predictor_ids], :joins => [:companies]).all.to_a
    factors = Hash[factors.sort_by{|factor| factor.name.to_s }.collect{|x| [x.id,x]}]
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(:order => "weight ASC").all
    @functional_norm_buckets = Vger::Resources::Functional::NormBucket.where(:order => "weight ASC").all
    @assessment_factor_norms = []

    if request.post?
      # Figure out from which flow has the user submitted the page
      # Via Existing Assessment flow OR
      # Via New Assessment flow

      if params[:assessment][:assessment_id].present? #user has come via existing assessment flow
        @assessment = Vger::Resources::Suitability::CustomAssessment.find(params[:assessment][:assessment_id], :include => [:functional_area, :industry, :job_experience], :methods => [:competency_ids])
        @assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:include => { :factor => { :methods => [:type] } }).all.to_a

        @functional_assessment_traits = @assessment.functional_assessment_traits
        Rails.logger.ap @functional_assessment_traits.size
        if @assessment.assessment_type == Vger::Resources::Suitability::CustomAssessment::AssessmentType::COMPETENCY
          competency_ids = @assessment.competency_ids
          competencies = Vger::Resources::Suitability::Competency.find(competency_ids)
          @competencies = @assessment.competency_order.map{|competency_id| competencies.detect{|competency| competency.id == competency_id }}
        end
        # Ensure backward compatibility with older assessments where
        # the item_ids are an array of hashes
        # so in short older assessments wont have
        # a) other_objective_items
        # b) other_subjective_items
        # c) functional_assessment traits as well, but that is handled gracefully above
        # Newer assessments' item_ids are hash of array of hashes

        unless @assessment.item_ids.is_a?(Array)
          objective_item_ids  = @assessment.item_ids["other_objective_items"] || []
          objective_ids = objective_item_ids.collect { |item_hash| item_hash[:id] }


          @objective_items = Vger::Resources::ObjectiveItem.where(:query_options => { :id => objective_ids}, :include => [ :options ]).all.to_a if objective_ids.present?
          subjective_item_ids = @assessment.item_ids["other_subjective_items"] || []
          subjective_ids = subjective_item_ids.collect { |item_hash| item_hash[:id]}

          @subjective_items = Vger::Resources::SubjectiveItem.where(:query_options => { :id => subjective_ids}).all.to_a if subjective_ids.present?
        end

        # handle assessment not found scenario
      else # user has landed on the page via new assessment flow
        assessment_params = params[:assessment].except(:assessment_id)
        assessment_params = assessment_params.except(:factors)
        assessment_params = assessment_params.except(:competencies)
        assessment_params = assessment_params.except(:functional_traits)
        assessment_params = assessment_params.except(:competency_order)
        @assessment = Vger::Resources::Suitability::CustomAssessment.create(assessment_params)
        query_options = {
          :functional_area_id => @assessment.functional_area_id,
          :industry_id => @assessment.industry_id,
          :job_experience_id => @assessment.job_experience_id
        }
        default_norm_bucket_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.\
                                      where(:query_options => query_options).all.to_a
        if default_norm_bucket_ranges.empty?
          query_options = {
          :functional_area_id => nil,
          :industry_id => nil,
          :job_experience_id => nil
          }
          default_norm_bucket_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.\
                                      where(:query_options => query_options).all.to_a
        end
        if @assessment.assessment_type == Vger::Resources::Suitability::CustomAssessment::AssessmentType::FIT
          factor_ids = params[:assessment][:factors]\
            .collect { |index,factor_hash| factor_hash.keys}\
            .flatten.map { |i| i.to_i }
          selected_factors = factors.select{ |key,value| factor_ids.include? key }
          selected_factors.each_with_index do |factor,index|

            assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
            :factor_id => factor[0],
            :functional_area_id => @assessment.functional_area_id,
            :industry_id => @assessment.industry_id,
            :job_experience_id => @assessment.job_experience_id,
            :selected => true
            )

            default_norm_bucket_range = default_norm_bucket_ranges.find{|x| x.factor_id == factor[0]}
            if default_norm_bucket_range
              assessment_factor_norm.from_norm_bucket_id = default_norm_bucket_range.from_norm_bucket_id
              assessment_factor_norm.to_norm_bucket_id = default_norm_bucket_range.to_norm_bucket_id
            else
              assessment_factor_norm.from_norm_bucket_id = @norm_buckets.first.id
              assessment_factor_norm.to_norm_bucket_id = @norm_buckets.last.id
            end
            assessment_factor_norm.functional_area_id = params[:assessment][:functional_area_id]
            assessment_factor_norm.industry_id = params[:assessment][:industry_id]
            assessment_factor_norm.job_experience_id = params[:assessment][:job_experience_id]
            @assessment_factor_norms << assessment_factor_norm
          end
          @functional_traits = Vger::Resources::Functional::Trait.where(:scopes => { :global => nil }).all.to_a
          @functional_traits |= Vger::Resources::Functional::Trait.where(:query_options =>
                     {"companies_functional_traits.company_id" => @assessment.company_id},
                    :joins => [:companies]).all.to_a
          Rails.logger.ap @functional_traits

        end

        if @assessment.assessment_type == Vger::Resources::Suitability::CustomAssessment::AssessmentType::COMPETENCY
          @competency_ids = params[:assessment][:competencies].map(&:to_i)

          selected_competencies = Hash[params[:assessment][:competency_order].select{|competency_id,order| @competency_ids.include?(competency_id.to_i) }]
          competency_order = Hash[selected_competencies.map{|competency_id,order| [competency_id.to_i,order.to_i] }]
          competency_order = Hash[competency_order.sort_by{|competency_id, order| order }]
          ordered_competencies = competency_order.keys.select{|competency_id| @competency_ids.include?(competency_id) }

          Vger::Resources::Suitability::CustomAssessment.save_existing(@assessment.id, { competency_order: ordered_competencies })
          @competencies = Vger::Resources::Suitability::Competency.find(@competency_ids)
          selected_factor_ids = @competencies.collect { |competency| competency.factor_ids }.flatten.uniq
          selected_factors = factors.select{ |key,value| selected_factor_ids.include? key}
          selected_factors.each_with_index do |factor,index|
            assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
              :factor_id => factor[0],
              :functional_area_id => @assessment.functional_area_id,
              :industry_id => @assessment.industry_id,
              :job_experience_id => @assessment.job_experience_id,
              :selected => true
              )
              default_norm_bucket_range = default_norm_bucket_ranges.find{|x| x.factor_id == factor[0]}
              if default_norm_bucket_range
                assessment_factor_norm.from_norm_bucket_id = default_norm_bucket_range.from_norm_bucket_id
                assessment_factor_norm.to_norm_bucket_id = default_norm_bucket_range.to_norm_bucket_id
              else
                assessment_factor_norm.from_norm_bucket_id = @norm_buckets.first.id
                assessment_factor_norm.to_norm_bucket_id = @norm_buckets.last.id
              end
            assessment_factor_norm.functional_area_id = params[:assessment][:functional_area_id]
            assessment_factor_norm.industry_id = params[:assessment][:industry_id]
            assessment_factor_norm.job_experience_id = params[:assessment][:job_experience_id]
            @assessment_factor_norms << assessment_factor_norm
          end
          @functional_traits = Vger::Resources::Functional::Trait.where(:query_options => {"functional_traits_suitability_competencies.competency_id" => @competency_ids},
                          :joins => [:competencies]).all.to_a
          #for every functional trait - setup an functional_assessment_trait object
          Rails.logger.ap @functional_traits
        end
        @functional_assessment_traits = []
        @functional_traits.each do |trait|
          Rails.logger.ap trait
          @functional_assessment_trait = Vger::Resources::Functional::AssessmentTrait.new({ trait_id: trait.id, assessment_id: @assessment.id,
               assessment_type: "Suitability::CustomAssessment" })
          @functional_assessment_trait.selected = @functional_assessment_trait.id.present?
          @functional_assessment_trait.from_norm_bucket_id = @functional_norm_buckets.first.id
          @functional_assessment_trait.to_norm_bucket_id = @functional_norm_buckets.last.id
          @functional_assessment_traits.push @functional_assessment_trait
        end

        objective_ids = params[:objective_items]\
          .collect { |index,factor_hash| factor_hash.keys}\
          .flatten.map { |i| i.to_i }

        @objective_items = Vger::Resources::ObjectiveItem.where(:query_options => { :id => objective_ids}, :include => [ :options ]).all.to_a if objective_ids.present?

        subjective_ids = params[:subjective_items]\
            .collect { |index,factor_hash| factor_hash.keys}\
            .flatten.map { |i| i.to_i }

        @subjective_items = Vger::Resources::SubjectiveItem.where(:query_options => { :id => subjective_ids}).all.to_a if subjective_ids.present?
      end
      @candidate_details = params[:report]
    end
  end

  def generate_report
    Vger::Resources::Suitability::CustomAssessment.generate_report(params[:report])
    render :json => { :status => "Job Started"}
  end

  def manage_report
    redirect_to manage_company_assessment_candidate_candidate_assessment_report_url(
      :id => params[:assessment][:report_id],
      :company_id => params[:assessment][:company_id],
      :candidate_id => params[:assessment][:candidate_id],
      :assessment_id => params[:assessment][:assessment_id]
    )
  end

  def modify_norms
    if params[:assessment][:assessment_id].present? && params[:assessment][:company_id].present?
	    assessment_id = params[:assessment][:assessment_id]
      company_id = params[:assessment][:company_id]
      assessment = Vger::Resources::Suitability::CustomAssessment.find(assessment_id)
      if assessment.assessment_type == "fit"
        redirect_to norms_company_assessment_path(:id => assessment_id, :company_id => company_id)
      else
        redirect_to competency_norms_company_assessment_path(:id => assessment_id, :company_id => company_id)
      end
    else
      redirect_to report_management_path, alert: "Please specify correct company id and assessment_id"
    end
  end
end
