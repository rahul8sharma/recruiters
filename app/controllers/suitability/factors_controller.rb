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
      :methods => [:type]
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
end
