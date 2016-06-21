class Idp::IdpsController < MasterDataController
  def api_resource
    Vger::Resources::Idp::Idp
  end
  
  def index_columns
    [:user_id, :coach_id, :mentor_id, :company_id, :status]
  end
  
  def import_via_s3
    unless params[:import][:file]
      flash[:notice] = "Please select a zip file."
      redirect_to request.env['HTTP_REFERER'] and return
    end
    data = params[:import][:file].read
    obj = S3Utils.upload(self.s3_key, data)

    api_resource\
      .import_from_s3_files(
                      :file => {
                        :bucket => obj.bucket.name,
                        :key => obj.key
                      }, 
                      :activation_host => params[:import][:activation_host],
                      :activation_protocol => params[:import][:activation_protocol],
                      :company_id => params[:import][:company_id],
                      :user_id => current_user.id
                    )
    redirect_to request.env['HTTP_REFERER'], notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end
  
  def s3_key
    "#{resource_name}/users"
  end
end
