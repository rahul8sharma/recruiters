class Mrf::AssessmentsManagementController < ApplicationController
  layout "candidates"
  before_filter :authenticate_user!
  before_filter :check_superadmin

  def manage
    render :layout => "admin"
  end

  def export_mrf_scores
    Vger::Resources::Mrf::Assessment\
      .export_mrf_scores(
          :company_id => params[:assessment][:company_id],
          :id => params[:assessment][:assessment_id],
          :options => params[:assessment])
    redirect_to mrf_assessments_management_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
end
