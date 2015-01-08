class Exit::ItemGroupsController < MasterDataController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Exit::ItemGroup
  end

  def index
    @item_groups = Vger::Resources::Exit::ItemGroup.where(:page => params[:page], :per => 10, :order => "updated_at DESC")
  end


  def import_with_options_from_google_drive
    errors = Vger::Resources::Exit::ItemGroup.import_with_options_from_google_drive(params[:item_group])
    redirect_to manage_exit_item_groups_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  # GET /item_groups/:id
  # GET /item_groups/:id.json
  def show
    @item_group= Vger::Resources::Exit::ItemGroup.find(params[:id], :include => [ :options ])
    respond_to do |format|
      format.html
    end
  end

  # GET /item_groups/:id
  # GET /item_groups/:id.json
  def edit
    @item_group= Vger::Resources::Exit::ItemGroup.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  # PUT /item_groups/:id
  # PUT /item_groups/:id.json
  def update
    @item_group = Vger::Resources::Exit::ItemGroup.find(params[:id])
    respond_to do |format|
      if @item_group.class.save_existing(params[:id], params[:item_group])
        format.html { redirect_to functional_item_group_path(params[:id]), notice: 'Exit ItemGroup Group was successfully updated.' }
        format.json { render json: @item_group, status: :created, location: @item_group}
      else
        format.html { render action: "edit" }
        format.json { render json: @item_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def import_from
    "import_from_google_drive"
  end
end
