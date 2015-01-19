class Retention::ItemsController < MasterDataController

  def api_resource
    Vger::Resources::Retention::Item
  end
  # GET /retention/items
  # GET /retention/items.json
  def index
    @items = Vger::Resources::Retention::Item.where(:page => params[:page], :per => 10, :order => "updated_at DESC")
  end

  def import_with_options_from_google_drive
    errors = Vger::Resources::Retention::Item.import_with_options_from_google_drive(params[:item])
    redirect_to manage_retention_items_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end


  # GET /retention/items/1
  # GET /retention/items/1.json
  def show
    @item= Vger::Resources::Retention::Item.find(params[:id], :include => [ :options ])
    respond_to do |format|
      format.html
    end
  end

  # PUT /retention/items/1
  # PUT /retention/items/1.json
  def update
    @item = Vger::Resources::Retention::Item.find(params[:id])
    respond_to do |format|
      if @item.class.save_existing(params[:id], params[:item])
        format.html { redirect_to retention_item_path(params[:id]), notice: 'Retention Item  was successfully updated.' }
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
