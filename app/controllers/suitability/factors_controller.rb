class Suitability::FactorsController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::Factor
  end

  def index
    @factors = Vger::Resources::Suitability::Factor.where(
      :page => params[:page],
      :per => 50,
      :include => [:parent],
      :methods => [:type, :company_names],
      :order => [:factor_order],
      :root => :factor,
      :query_options => {
        type: params[:type] || "Suitability::Factor"
      }
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
    @suitability_items = Vger::Resources::Suitability::Item.where(:query_options => {
      :factor_id => @factor.id
    }).all.to_a
    @mrf_items = Vger::Resources::Mrf::Item.where(query_options: {
      trait_type: @factor.class.name.gsub("Vger::Resources::",""),
      trait_id: @factor.id
    }).all.to_a
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

  def get_factors
    Rails.logger.debug("Company IDs are #{params[:company_ids]}")
    factors = Vger::Resources::Suitability::Factor.where(:query_options => {:active => true}, :scopes => { :global => nil }, :methods => [:type, :direct_predictor_ids]).all.to_a
    factors |= Vger::Resources::Suitability::Factor.where(:query_options => {"companies_factors.company_id" => params[:company_ids], :active => true}, :methods => [:type, :direct_predictor_ids], :joins => [:companies]).all.to_a
    factors |= Vger::Resources::Suitability::AlarmFactor.active.where(:methods => [:type, :direct_predictor_ids]).all.to_a
    respond_to do |format|
      format.json{ render :json => { :factors => factors } }
    end
  end
end
