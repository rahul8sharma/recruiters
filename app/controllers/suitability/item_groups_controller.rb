class Suitability::ItemGroupsController < MasterDataController
  before_action :authenticate_user!

  def api_resource
    Vger::Resources::Suitability::ItemGroup
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def import_from
    "import_from_google_drive"
  end

  def import_with_options_from_google_drive
    #unless params[:item_group][:file]
    #  flash[:notice] = "Please select a zip file."
    #  redirect_to request.env['HTTP_REFERER'] and return
    #end
    if params[:zip]
      now = Time.now
      s3_key = "suitability/item_images/images_#{now.strftime('%d_%m_%Y_%H_%I')}.zip"
      data = params[:zip].read
      obj = S3Utils.upload(s3_key, data)
      params[:item_group][:zip_file] ||= {}
      params[:item_group][:zip_file][:s3_zip_bucket] = obj.bucket.name
      params[:item_group][:zip_file][:s3_zip_key] = obj.key
    end
    errors = Vger::Resources::Suitability::ItemGroup.import_with_options_from_google_drive(params[:item_group])
    redirect_to manage_suitability_item_groups_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def manage
  end

  def search_columns
    [:id, :body, :behaviour]
  end
  
  def index_columns
    [:id, :body, :behaviour]
  end
  
  
  # GET /item_groups/new
  # GET /item_groups/new.json
  def new
    @item_group= Vger::Resources::Suitability::ItemGroup.new(:active => true)
    respond_to do |format|
      format.html
    end
  end
  
  # GET /item_groups/:id
  # GET /item_groups/:id.json
  def show
    @item_group= Vger::Resources::Suitability::ItemGroup.find(params[:id], :include => [ :items ])
    respond_to do |format|
      format.html
    end
  end
  
  # GET /item_groups/:id
  # GET /item_groups/:id.json
  def edit
    @item_group= Vger::Resources::Suitability::ItemGroup.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  # POST /item_groups
  # POST /item_groups.json
  def create
    @item_group= Vger::Resources::Suitability::ItemGroup.new(params[:item_group])
    respond_to do |format|
      if @item_group.save
        format.html { redirect_to suitability_item_group_path(@item_group), notice: 'Suitability Item Group was successfully created.' }
        format.json { render json: @item_group, status: :created, location: @item_group}
      else
        format.html { render action: "new" }
        format.json { render json: @item_group.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PUT /item_groups/:id
  # PUT /item_groups/:id.json
  def update
    @item_group = Vger::Resources::Suitability::ItemGroup.find(params[:id])
    respond_to do |format|
      if @item_group.class.save_existing(params[:id], params[:item_group])
        format.html { redirect_to suitability_item_group_path(params[:id]), notice: 'Suitability Item Group was successfully updated.' }
        format.json { render json: @item_group, status: :created, location: @item_group}
      else
        format.html { render action: "edit" }
        format.json { render json: @item_group.errors, status: :unprocessable_entity }
      end
    end
  end
end
