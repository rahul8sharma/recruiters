class Suitability::CustomAssessments::TrainingRequirementsReportsManagementController < ApplicationController
  layout "tests"
  before_filter :authenticate_user!
  before_filter :check_superuser

  def manage
    render :layout => "admin"
  end

  def export_assessment_trr_users
    Vger::Resources::Suitability::CustomAssessment\
      .find(params[:assessment][:id])\
      .export_assessment_trr_users(params[:assessment])
    redirect_to trr_manage_path, notice: "Export Operation Queued. Email notification should arrive as soon as the export is complete."
  end

  def export_group_trr_users
    Vger::Resources::Suitability::TrainingRequirementGroup\
      .find(params[:assessment][:assessment_group_id])\
      .export_group_trr_users(params[:assessment])

    redirect_to trr_manage_path, notice: "Export Operation Queued. Email notification should arrive as soon as the export is complete."
  end

  def import_assessment_trr_users
    file = params[:import][:file]
    unless file
      flash[:notice] = "Please select an xls file."
      redirect_to request.env['HTTP_REFERER'] and return
    end
    data = params[:import][:file].read
    obj = S3Utils.upload("trr_candidates//#{file.original_filename}", data)
    params.delete :import
    Vger::Resources::Suitability::CustomAssessment\
      .find(params[:assessment_id])\
      .import_assessment_trr_users(params.merge({
        user_id: current_user.id,
        file: {
          bucket: obj.bucket.name,
          key: obj.key
        }
      }))
    redirect_to trr_manage_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def import_group_trr_users
    file = params[:import][:file]
    unless file
      flash[:notice] = "Please select an xls file."
      redirect_to request.env['HTTP_REFERER'] and return
    end
    data = file.read
    obj = S3Utils.upload("trr_candidates/#{file.original_filename}", data)
    params.delete :import
    
    Vger::Resources::Suitability::TrainingRequirementGroup\
      .find(params[:assessment_group_id])\
      .import_group_trr_users(params.merge({
        user_id: current_user.id,
        file: {
          bucket: obj.bucket.name,
          key: obj.key
        }
      }))
    redirect_to trr_manage_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def regenerate_ttr
    redirect_to trr_manage_path, notice: "Regeneration Triggered. Email notification should arrive as soon as regeneration is complete."
  end

  def regenerate_group_trr
    redirect_to trr_manage_path, notice: "Regeneration Triggered. Email notification should arrive as soon as regeneration is complete."
  end
end
