class PagesController < ApplicationController
  before_filter :authenticate_user!
  layout 'admin'
  
  def home
  end
  
  def report_management
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
      assessment = Vger::Resources::Suitability::Assessment.find(assessment_id)
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
