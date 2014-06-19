class Suitability::FactorsController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::Factor
  end

  def index
    params[:type] ||= "Suitability::Factor"
    @factors = "Vger::Resources::#{params[:type]}".constantize.where(
      :page => params[:page], 
      :per => 50, 
      :include => [:parent], 
      :methods => [:type],
      :order => [:factor_order],
      :root => :factor
    ).all
  end
  
  def import_from
    "import_from_google_drive"
  end

  # GET /factors/new
  # GET /factors/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /factors/:id
  # GET /factors/:id.json
  def show
    @factor = api_resource.find(params[:id], :root => :factor)
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  def edit
    @factor = api_resource.find(params[:id], :root => :factor)
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  def update
    @factor = api_resource.save_existing(params[:id], params[:factor])
    respond_to do |format|
      if @factor.error_messages.present?
        flash[:error] = @factor.error_messages.join("<br/>").html_safe
        format.html{ render :action => :edit }
      else
        format.html{ redirect_to suitability_factor_path(params[:id]) }
      end
    end
  end
end
