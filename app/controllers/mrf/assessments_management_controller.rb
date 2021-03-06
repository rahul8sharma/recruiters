class Mrf::AssessmentsManagementController < ApplicationController
  layout "users"
  before_filter :authenticate_user!
  before_filter :check_superuser

  def manage
    render :layout => "admin"
  end

  def export_mrf_scores
    Vger::Resources::Mrf::Assessment\
      .export_mrf_scores(
          :company_id => params[:assessment][:company_id],
          :id => params[:assessment][:assessment_id],
          :args => params[:assessment].merge({
            user_id: current_user.id
          }))
    redirect_to mrf_assessments_management_path, 
      notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def export_mrf_raw_scores
    Vger::Resources::Mrf::Assessment\
      .export_mrf_raw_scores(
          :company_id => params[:assessment][:company_id],
          :id => params[:assessment][:assessment_id],
          :args => params[:assessment].merge({
            user_id: current_user.id
          }))
    redirect_to mrf_assessments_management_path, 
      notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def export_mrf_responses
    Vger::Resources::Mrf::Assessment\
      .export_mrf_responses(
          :company_id => params[:assessment][:company_id],
          :id => params[:assessment][:assessment_id],
          :args => params[:assessment].merge({
            user_id: current_user.id
          }))
    redirect_to mrf_assessments_management_path, 
      notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def replicate_assessment
    Vger::Resources::Mrf::Assessment\
      .replicate_assessment(
          :company_id => params[:assessment][:company_id],
          :assessment_id => params[:assessment][:assessment_id])
    redirect_to mrf_assessments_management_path, 
      notice: "Replica of the Assessment will be created. Email notification should arrive as soon as the replication is complete."
  end
end
