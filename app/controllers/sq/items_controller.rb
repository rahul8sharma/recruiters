class Sq::ItemsController < MasterDataController
  before_action :authenticate_user!

  def api_resource
    Vger::Resources::Sq::Item
  end

  def import_with_options_from_google_drive
    if params[:zip]
      now = Time.now
      s3_key = "sq/item_images/images_#{now.strftime('%d_%m_%Y_%H_%I')}.zip"
      data = params[:zip].read
      obj = S3Utils.upload(s3_key, data)
      params[:item][:zip_file] ||= {}
      params[:item][:zip_file][:s3_zip_bucket] = obj.bucket.name
      params[:item][:zip_file][:s3_zip_key] = obj.key
    end
    errors = Vger::Resources::Sq::Item.import_with_options_from_google_drive(params[:item])
    redirect_to manage_sq_items_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  # GET /items/:id
  # GET /items/:id.json
  def show
    @item= Vger::Resources::Sq::Item.find(params[:id], :include => [ :options ])
    respond_to do |format|
      format.html
    end
  end

  # GET /items/:id
  # GET /items/:id.json
  def edit
    @item= Vger::Resources::Sq::Item.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  # PUT /items/:id
  # PUT /items/:id.json
  def update
    @item = Vger::Resources::Sq::Item.find(params[:id])
    respond_to do |format|
      if @item.class.save_existing(params[:id], params[:item])
        format.html { redirect_to mrf_item_path(params[:id]), notice: 'Sq Item Group was successfully updated.' }
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
  
  def index_columns
    [:id, :body]
  end
  
  def search_columns
    [:id, :body]
  end
end
