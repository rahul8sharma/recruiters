class MasterDataController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"
  
  helper_method :resource_name
  helper_method :index_columns
  helper_method :resource_path
  helper_method :index_path
  
  def new
    @resource = api_resource.new
  end
  
  def create
    @resource = api_resource.create(params[resource_name.singularize])
    if @resource.error_messages && @resource.error_messages.present?
      flash[:error] = @resource.error_messages.join("<br/>").html_safe
      render :action => :new
    else
      redirect_to self.send("#{resource_name.singularize}_path",@resource.id)
    end
  end
  
  def show
    @resource = api_resource.find(params[:id])
  end
  
  def edit
    @resource = api_resource.find(params[:id])
  end
  
  def update
    @resource = api_resource.save_existing(params[:id], params[resource_name.singularize])
    if @resource.error_messages && @resource.error_messages.present?
      flash[:error] = @resource.error_messages.join("<br/>").html_safe
      render :action => :edit
    else
      redirect_to self.send("#{resource_name.singularize}_path",@resource.id)
    end
  end
  
  
  def manage
  end

  def index
    params[:search] ||= {}
    params[:search] = params[:search].select{|key,val| val.present? }
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
    unless params[:import][:file]
      flash[:notice] = "Please select a zip file."
      redirect_to request.env['HTTP_REFERER'] and return
    end
    data = params[:import][:file].read
    S3Utils.upload(self.s3_bucket_name, self.s3_key, data)

    api_resource\
      .import_from_s3(:file => {
                        :bucket => s3_bucket_name,
                        :key => s3_key
                      }, :email => params[:import][:email])
    redirect_to request.env['HTTP_REFERER'], notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    if params[:export][:folder][:url].blank?
      flash[:error] = "Please enter a valid google drive folder url!"
      redirect_to request.env['HTTP_REFERER'] and return
    end
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
  
  def resource_path(resource)
    self.send("#{resource_name.singularize}_path",resource.id)
  end
  
  def manage_path
    self.send("manage_#{resource_name}_path") if self.respond_to?("manage_#{resource_name}_path")
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
  
  def s3_bucket_name
    "master_data"
  end
  
  def s3_key
    "master_data.csv.zip"
  end
  
  def search_columns
    []
  end
end
