class Suitability::AssessmentsManagementController < ApplicationController
  layout "users"
  before_filter :authenticate_user!
  before_filter :check_superuser

  def manage
  end

  def replicate_assessment
    if request.post?
      Vger::Resources::Suitability::CustomAssessment\
        .replicate_assessment(
            :company_id => params[:to_company_id],
            :assessment_id => params[:assessment_id],
            :defined_form_id => params[:defined_form_id],
            :replicate => params[:replicate].present?,
            :assessment => params[:assessment]
          )
      redirect_to suitability_assessments_management_path, 
        notice: "Replica of the Assessment will be created. Email notification should arrive as soon as the replication is complete."
    else
      if params[:assessment].values.any?(&:blank?)
        flash[:error] = "Please enter all the fields"
        render :manage
      else
        get_assessment_master_data
      end
    end        
  end
  
  def projection_report
    if request.get?
      if params[:assessment]
        get_assessment_details
      end
    else
      Vger::Resources::User\
        .post(
          "/sidekiq/post-job?job_klass=Suitability::ProjectionReportGenerator",
          params[:projection].merge({
            user_id: current_user.id
          })
        )
    end
  end
  
  protected
  
  def get_assessment_details
    @assessment = Vger::Resources::Suitability::CustomAssessment.find(
      params[:assessment][:assessment_id],
      methods: [:competency_score_ratings]
    )
    @competencies = Hash[Vger::Resources::Suitability::Competency.where(
      query_options: {
        id: @assessment.competency_order
      }
    ).all.to_a.map do |competency|
      [competency.id, competency]
    end]
    @factors = Hash[Vger::Resources::Suitability::Factor.where(
      query_options: {
        id: @competencies.values.map(&:factor_ids).flatten
      }
    ).all.to_a.map do |factor|
      [factor.id, factor]
    end]
    @assessment_competency_weights = Vger::Resources::Suitability::AssessmentCompetencyWeight.where(
      query_options: {
        assessment_id: @assessment.id
      }
    )
    @assessment_factor_weights = Vger::Resources::Suitability::AssessmentFactorWeight.where(
      query_options: {
        assessment_id: @assessment.id
      }
    )
    @factor_norms = Hash[Vger::Resources::Suitability::Job::AssessmentFactorNorm.where(
      custom_assessment_id: @assessment.id,
      query_options: {
        assessment_id: @assessment.id
      }
    ).all.to_a.map do |factor_norm|
      [factor_norm.factor_id, factor_norm]
    end]
    @norm_buckets = Vger::Resources::Suitability::NormBucket.all.to_a.sort_by(&:weight)
  end
  
  def get_assessment_master_data
    @to_company = Vger::Resources::Company.find(params[:assessment][:to_company_id])
    @assessment = Vger::Resources::Suitability::CustomAssessment.find(
      params[:assessment][:assessment_id],
      company_id: params[:assessment][:from_company_id],
    )
    @factual_information_form = Vger::Resources::FormBuilder::FactualInformationForm.where(
      query_options: { 
        assessment_type: "Suitability::CustomAssessment",
        assessment_id: @assessment.id
      }
    ).all.first
    @functional_areas = Hash[Vger::Resources::FunctionalArea.where(
      :query_options => {
        :active=>true
      },
      :order => "name ASC"
    ).all.to_a.collect{|x| [x.id,x]}]
    
    @industries = Hash[Vger::Resources::Industry.where(
      :query_options => {
        :active=>true
      },
      :order => "name ASC"
    ).all.to_a.collect{|x| [x.id,x]}]
    
    @job_experiences = Hash[Vger::Resources::JobExperience\
      .active\
      .all.to_a.collect{|x| [x.id,x]}
    ]
    
    @defined_forms = Vger::Resources::FormBuilder::DefinedForm.where(
      scopes: { 
        for_company_id: params[:assessment][:to_company_id] 
      }, 
      query_options: { 
        active: true 
      }
    ).all.to_a
    @defined_forms |= Vger::Resources::FormBuilder::DefinedForm.where(
      query_options: { 
        id: @factual_information_form.defined_form_id 
      }
    ).all.to_a if @factual_information_form
  end
end
