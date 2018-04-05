class Suitability::AssessmentsManagementController < ApplicationController
  layout "users"
  before_action :authenticate_user!
  before_action :check_superuser

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
  
  protected
  
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
