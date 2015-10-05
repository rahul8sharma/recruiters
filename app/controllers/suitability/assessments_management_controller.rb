class Suitability::AssessmentsManagementController < ApplicationController
  layout "candidates"
  before_filter :authenticate_user!
  before_filter :check_superadmin

  def manage
    render :layout => "admin"
  end

  def replicate_assessment
    Vger::Resources::Suitability::CustomAssessment\
      .replicate_assessment(
          :company_id => params[:assessment][:company_id],
          :assessment_id => params[:assessment][:assessment_id])
    redirect_to suitability_assessments_management_path, 
      notice: "Replica of the Assessment will be created. Email notification should arrive as soon as the replication is complete."
  end
end
