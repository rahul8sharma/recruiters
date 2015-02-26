class Exit::ItemsController < MasterDataController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Exit::Item
  end

  def index
    @items = Vger::Resources::Exit::Item.where(:page => params[:page], :per => 10, :order => "updated_at DESC")
  end


  def import_with_options_from_google_drive
    if params[:zip]
      now = Time.now
      s3_key = "exit/item_images/items_#{now.strftime('%d_%m_%Y_%H_%I')}.csv.zip"
      data = params[:zip].read
      obj = S3Utils.upload(s3_key, data)
      params[:item][:zip_file] ||= {}
      params[:item][:zip_file][:s3_zip_bucket] = obj.bucket.name
      params[:item][:zip_file][:s3_zip_key] = obj.key
    end
    errors = Vger::Resources::Exit::Item.import_with_options_from_google_drive(params[:item])
    redirect_to manage_exit_items_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end
  
  # GET /items/:id
  # GET /items/:id.json
  def show
    @item= Vger::Resources::Exit::Item.find(params[:id], :include => [ :options ])
    respond_to do |format|
      format.html
    end
  end

  # GET /items/:id
  # GET /items/:id.json
  def edit
    @item= Vger::Resources::Exit::Item.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  # PUT /items/:id
  # PUT /items/:id.json
  def update
    @item = Vger::Resources::Exit::Item.find(params[:id])
    respond_to do |format|
      if @item.class.save_existing(params[:id], params[:item])
        format.html { redirect_to exit_item_path(params[:id]), notice: 'Exit Item Group was successfully updated.' }
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
