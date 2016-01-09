class Oac::ExerciseManagementController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"
  
  def manage
  end
  
  def import_tool_wise_scores
    unless params[:import][:file]
      flash[:notice] = "Please select a zip file."
      redirect_to request.env['HTTP_REFERER'] and return
    end
    data = params[:import][:file].read
    now = Time.now
    s3_key = "oac/toolwise_scores/#{now.strftime('%d_%m_%Y_%H_%I')}"
    obj = S3Utils.upload(s3_key, data)

    Vger::Resources::Oac::Exercise.import_tool_wise_scores(
      args: {
        :file => {
          :bucket => obj.bucket.name,
          :key => obj.key
        }, 
        exercise_id: params[:import][:exercise_id], 
        override_overall_scores: !params[:import][:override_overall_scores].to_i.zero?,
        override_super_competency_scores: !params[:import][:override_super_competency_scores].to_i.zero?,
        user_id: current_user.id
      }
    )
    redirect_to oac_manage_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end
  
  def export_tool_wise_scores
    Vger::Resources::Oac::Exercise.export_tool_wise_scores(
      args: { 
        exercise_id: params[:export][:exercise_id], 
        user_id: current_user.id
      }
    )
    redirect_to oac_manage_path, notice: "Export operation queued. Email notification should arrive as soon as the import is complete."
  end
end

