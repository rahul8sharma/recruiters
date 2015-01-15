class Retention::TraitsController < MasterDataController
  def api_resource
    Vger::Resources::Retention::Trait
  end

  def index
    params[:type] ||= "Retention::Trait"
    @objects = Vger::Resources::Retention::Trait.where(
      :page => params[:page],
      :per => 50,
      :root => :trait
    ).all
  end

  # GET /traits/:id
  # GET /traits/:id.json
  def show
    @resource = api_resource.find(params[:id], :root => :trait)
    @items = Vger::Resources::Retention::Item.where(query_options: {
      trait_id: @resource.id
    }).all.to_a
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @trait = api_resource.find(params[:id], :root => :trait)
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
        format.html{ redirect_to retention_trait_path(params[:id]) }
      end
    end
  end

  def index_columns
    [:id, :name, :active, :definition]
  end

  def import_from
    "import_from_google_drive"
  end

end
