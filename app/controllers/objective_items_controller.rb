class ObjectiveItemsController < MasterDataController

  before_filter :authenticate_user!


  def api_resource
    Vger::Resources::ObjectiveItem
  end

  def index
    @items = Vger::Resources::ObjectiveItem.where(:page => params[:page], :per => 10, :order => "updated_at DESC")
  end

  def import_with_options_from_google_drive
    errors = Vger::Resources::ObjectiveItem.import_with_options_from_google_drive(params[:item])
    redirect_to manage_mrf_items_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

    # GET /items/:id
    # GET /items/:id.json
    def show
      @item= Vger::Resources::ObjectiveItem.find(params[:id], :include => [ :options ])
      respond_to do |format|
        format.html
      end
    end

    # GET /items/:id
    # GET /items/:id.json
    def edit
      @item= Vger::Resources::ObjectiveItem.find(params[:id])
      respond_to do |format|
        format.html
      end
    end

    # PUT /items/:id
    # PUT /items/:id.json
    def update
      @item = Vger::Resources::ObjectiveItem.find(params[:id])
      respond_to do |format|
        if @item.class.save_existing(params[:id], params[:item])
          format.html { redirect_to objective_item_path(params[:id]), notice: 'Objective Item was successfully updated.' }
          format.json { render json: @item, status: :created, location: @item}
        else
          format.html { render action: "edit" }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    end

  def import_from
    "import_from_google_drive"
  end
end
