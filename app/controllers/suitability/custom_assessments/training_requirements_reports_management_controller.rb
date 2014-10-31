class Suitability::CustomAssessments::TrainingRequirementsReportsManagementController < ApplicationController
  layout "tests"
  before_filter :authenticate_user!
  before_filter :check_superadmin

  def manage
    render :layout => "admin"
  end

  def export_assessment_trr_candidates
    Vger::Resources::Suitability::CustomAssessment.find(params[:assessment][:id]).export_assessment_trr_candidates(params[:assessment])
    redirect_to trr_manage_path, notice: "Export Operation Queued. Email notification should arrive as soon as the export is complete."

  end

  def export_group_trr_candidates
    # method on TRRGroup model
    Vger::Resources::Suitability::TrainingRequirementGroup.find(params[:assessment][:id]).export_group_trr_candidates(params[:assessment])
    redirect_to trr_manage_path, notice: "Export Operation Queued. Email notification should arrive as soon as the export is complete."
  end

  def import_assessment_trr_candidates
    unless params[:assessment][:url]
      flash[:notice] = "Please provide a Spreadsheet URL"
      redirect_to request.env['HTTP_REFERER'] and return
    end
    Vger::Resources::Suitability::CustomAssessment.find(params[:assessment][:id])\
      .import_assessment_trr_candidates(params[:assessment])
    redirect_to trr_manage_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def import_group_trr_candidates
    redirect_to trr_manage_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def regenerate_ttr
    redirect_to trr_manage_path, notice: "Regeneration Triggered. Email notification should arrive as soon as regeneration is complete."
  end

  def regenerate_group_trr
    redirect_to trr_manage_path, notice: "Regeneration Triggered. Email notification should arrive as soon as regeneration is complete."
  end


end
