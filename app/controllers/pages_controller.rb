class PagesController < ApplicationController
  before_filter :authenticate_user!
  layout 'admin'

  def home
  end

  def report_management
  end

  def report_generator
    @functional_areas = Hash[Vger::Resources::FunctionalArea.where(:query_options => {:active=>true},:order => "name ASC")\
                          .all.to_a.collect{|x| [x.id,x]}]
    @industries = Hash[Vger::Resources::Industry.where(:query_options => {:active=>true},:order => "name ASC")\
                        .all.to_a.collect{|x| [x.id,x]}]
    @job_experiences = Hash[Vger::Resources::JobExperience.active.all.to_a.collect{|x| [x.id,x]}]

  end


  def report_generator_scores
    factors = Vger::Resources::Suitability::Factor.where(:query_options => {:active => true,:type=>"Suitability::Factor"}, :scopes => { :global => nil }, :methods => [:type, :direct_predictor_ids]).all.to_a
    factors |= Vger::Resources::Suitability::Factor.where(:query_options => {"companies_factors.company_id" => params[:assessment][:company_id], :active => true}, :methods => [:type, :direct_predictor_ids], :joins => [:companies]).all.to_a
    factors = Hash[factors.sort_by{|factor| factor.name.to_s }.collect{|x| [x.id,x]}]
    if request.post?
      # Figure out from which flow has the user submitted the page
      # Via Existing Assessment flow OR
      # Via New Assessment flow
      if params[:assessment][:assessment_id].present? #user has come via existing assessment flow
        @assessment = Vger::Resources::Suitability::CustomAssessment.find(params[:assessment][:assessment_id], :include => [:functional_area, :industry, :job_experience], :methods => [:competency_ids])
        @assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:include => { :factor => { :methods => [:type] } }).all.to_a
        if @assessment.assessment_type == Vger::Resources::Suitability::CustomAssessment::AssessmentType::COMPETENCY
          competency_ids = @assessment.competency_ids
          @competencies = Vger::Resources::Suitability::Competency.find(competency_ids)
          @competencies = @assessment.competency_order.map{|competency_id| competencies.detect{|competency| competency.id == competency_id }}
        end
        # handle assessment not found scenario
      else # user has landed on the page via new assessment flow
        params[:assessment][:is_jombay_pearson_test] = params[:assessment][:is_jombay_pearson_test] == "Yes"
        @assessment = Vger::Resources::Suitability::CustomAssessment.create(params[:assessment].except!(:assessment_id))
      end
      #load assessment_factor_norms
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

      @assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:include => { :factor => { :methods => [:type] } }).all.to_a

      @norm_buckets = Vger::Resources::Suitability::NormBucket.where(:order => "weight ASC").all
      @objective_items = Vger::Resources::ObjectiveItem.where(:query_options => { :active => true}, :include => [ :options ]).all.to_a
      objective_ids = @objective_items.map(&:id)

      @subjective_items = Vger::Resources::SubjectiveItem.active.all.to_a
      @candidate_details = params[:report]
      #create candidate_assessment
      @candidate = Vger::Resources::Candidate.where(:query_options => { :email => params[:report][:candidate_email] }).all[0]
      if @candidate.present?
        candidate_assessment = @assessment.candidate_assessments.where(:query_options => {
            :assessment_id => @assessment.id,
            :candidate_id => @candidate.id
          }).all[0]
      else
        candidate_data = {:name => params[:report][:candidate_name], :email => params[:report][:candidate_email]}
        @candidate = candidate = Vger::Resources::Candidate.create(candidate_data)
      end
      options = {
          :assessment_taker_type => params[:report][:candidate_type],
          :report_link_receiver_name => params[:report][:candidate_name],
          :report_link_receiver_email => current_user.email,
          :assessment_link_receiver_name => params[:report][:candidate_name],
          :assessment_link_receiver_email => current_user.email,
          :send_report_links_to_manager => true,
          :send_assessment_links_to_manager => true
        }
      # options.merge!(template_id: params[:template_id].to_i) if params[:template_id].present?
      # create candidate_assessment if not present
      # add it to list of candidate_assessments to send email
      unless candidate_assessment
        candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.create(
          :assessment_id => @assessment.id,
          :candidate_id => @candidate.id,
          :candidate_stage => params[:candidate_stage],
          :responses_count => 0,
          :report_email_recipients => current_user.email,
          :options => options,
          :language => @assessment.language
        )
      end
    end
  end

  def generate_report
    Vger::Resources::Suitability::CustomAssessment.generate_report(params[:report])
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
