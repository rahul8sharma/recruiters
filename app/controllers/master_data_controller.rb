class MasterDataController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"
  
  def manage
  end

  def index
    params[:search] ||= {}
    @objects = api_resource.where(
      :query_options => params[:search], 
      :methods => index_columns,
      :page => params[:page], 
      :per => 10).all
  end
  
  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end
  
  def import_from_google_drive
    api_resource\
      .import_from_google_drive(params[:import])
    redirect_to request.env['HTTP_REFERER'], notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end
  
  def import_via_s3
    s3_bucket_name = 'master_data'
    s3_key = 'default_factor_norm_ranges.csv.zip'
    
    unless params[:import][:file]
      flash[:notice] = "Please select a zip file."
      redirect_to request.env['HTTP_REFERER'] and return
    end
    data = params[:import][:file].read
    S3Utils.upload(s3_bucket_name, s3_key, data)

    api_resource\
      .import_from_s3(:file => {
                        :bucket => s3_bucket_name,
                        :key => s3_key
                      }, :email => params[:import][:email])
    redirect_to request.env['HTTP_REFERER'], notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    params[:export][:filters] ||= {}
    params[:export][:filters][:functional_area_id] ||= nil
    params[:export][:filters][:job_experience_id] ||= nil
    api_resource\
      .export_to_google_drive(params[:export])
    redirect_to request.env['HTTP_REFERER'], notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def index_path
    self.send("#{resource_name}_path")
  end
  
  def manage_path
    self.send("manage_#{resource_name}_path")
  end
  
  def destroy_all_path
    self.send("destroy_all_#{resource_name}_path")
  end
  
  def import_via_s3_path
    self.send("import_via_s3_#{resource_name}_path")
  end
  
  def import_from_google_drive_path
    self.send("import_from_google_drive_#{resource_name}_path")
  end
  
  def export_to_google_drive_path
    self.send("export_to_google_drive_#{resource_name}_path")
  end
  
  def resource_name
    "#{api_resource.to_s.split("Vger::Resources::").last.gsub("::","").underscore.pluralize}"
  end
  
  def import_from
    "import_via_s3"
  end
  
  def search_columns
    []
  end
end
