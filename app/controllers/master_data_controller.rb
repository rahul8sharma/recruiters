class MasterDataController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"
  
  helper_method :resource_name
  helper_method :index_columns
  helper_method :form_fields
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
    @resource = api_resource.find(params[:id], :methods => form_fields)
  end
  
  def edit
    @resource = api_resource.find(params[:id], :methods => form_fields)
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
    search_columns_hash = search_columns.is_a?(Hash) ? search_columns : Hash[search_columns.map{|k| [k,{ column: k }] }]
    params[:search] = params[:search].select{|key,val| val.present? }
    search_params = Hash[params[:search].dup.map do |key, value|
      [
        search_columns_hash[key.strip.to_sym][:column],
        value
      ]
    end]
    joins = params[:search].map{|key,val| search_columns_hash[key.strip.to_sym][:joins] }.compact.flatten
    @objects = api_resource.where(
      :query_options => search_params,
      :joins => joins,
      :methods => index_columns,
      :order => params[:order] || "id asc",
      :page => params[:page], 
      :per => params[:per] || 10).all
    respond_to do |format|      
      format.html
      format.json{ render json: @objects.to_a.to_json }
    end
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
    obj = S3Utils.upload(self.s3_key, data)

    api_resource\
      .import_from_s3(:file => {
                        :bucket => obj.bucket.name,
                        :key => obj.key
                      }, :email => params[:import][:email])
    redirect_to request.env['HTTP_REFERER'], notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    if params[:export][:folder][:url].blank?
      flash[:error] = "Please enter a valid google drive folder url!"
      redirect_to request.env['HTTP_REFERER'] and return
    end
    params[:export][:filters] ||= {}
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
  
  def s3_key
    "#{resource_name}/master_data.xls.zip"
  end
  
  def form_fields
    return index_columns
  end
  
  def search_columns
    {}
  end
end
