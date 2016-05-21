class RolesController < MasterDataController
  def api_resource
    Vger::Resources::Role
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :name
    ]
  end
  
  def search_columns
    [
      :id,
      :name
    ]
  end

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
    @resource = api_resource.find(params[:id], 
      :methods => form_fields, 
      root: :role,
      include: [:permissions]
    )
  end
  
  def edit
    @resource = api_resource.find(params[:id], 
      :methods => form_fields+[:permission_ids], 
      root: :role
    )
    @permissions = Vger::Resources::Permission.all.to_a
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
      :per => params[:per] || 10, 
      :root => :role).all
    respond_to do |format|      
      format.html
      format.json{ render json: @objects.to_a.to_json }
    end
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
