class Mrf::TraitsController < MasterDataController
  before_filter :set_params, only: [:edit, :update, :create]
  def api_resource
    Vger::Resources::Mrf::Trait
  end

  def import_from
    "import_from_google_drive"
  end

  # GET /traits/:id
  # GET /traits/:id.json
  def show
    @trait = api_resource.find(params[:id], 
      :root => :trait
    )
    @items = Vger::Resources::Mrf::Item.where(query_options: {
      trait_type: "Mrf::Trait",
      trait_id: @trait.id
    }).all.to_a
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @trait = api_resource.find(params[:id], 
      :root => :trait
    )
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def update
    @trait = api_resource.save_existing(params[:id], params[:trait])
    respond_to do |format|
      if @trait.error_messages.present?
        flash[:error] = @trait.error_messages.join("<br/>").html_safe
        format.html{ render :action => :edit }
      else
        format.html{ redirect_to mrf_trait_path(params[:id]) }
      end
    end
  end
  
  def index_columns
    [:id, :name, :company_id]
  end
  
  def search_columns
    [:id, :name, :company_id]
  end

  protected
  
  def set_params
    params[:trait] ||= {}
  end
end
