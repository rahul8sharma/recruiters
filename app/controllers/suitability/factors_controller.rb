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

  def manage

  end

  def export_display_names
    if request.post?
      if params[:commit] == "Export Display Names"
        @company_ids = params[:factor][:company_ids]
        @factors  = Vger::Resources::Suitability::Factor.where(:query_options => {:active => true,:type=>"Suitability::Factor",:is_global => true}, :scopes => { :global => nil }, :methods => [:type, :direct_predictor_ids]).all.to_a
        @factors |= Vger::Resources::Suitability::Factor.where(:query_options => {"companies_factors.company_id" => @company_ids , :active => true,:is_global => false}, :methods => [:type, :direct_predictor_ids,:company_names], :joins => [:companies]).all.to_a
      else
        Vger::Resources::Suitability::Factor.export_display_names(params)
        redirect_to request.env['HTTP_REFERER'], notice: "Export operation queued.
        Email notification should arrive as soon as the export is complete."
      end
    end
  end

  def import_display_names
    if request.post?
        Vger::Resources::Suitability::Factor.import_display_names(params)
        redirect_to request.env['HTTP_REFERER'], notice: "Import operation queued.
          Email notification should arrive as soon as the import is complete."
    end
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
    company_ids = params[:company_ids].split(",")

    local_factor_ids = []
    local_factors = {}
    factor_cache = []
    company_ids.each do |id|
      local_factor = Vger::Resources::Suitability::Factor.where(:query_options => {"companies_factors.company_id" => id, :active => true,:is_global => false}, :methods => [:type, :direct_predictor_ids,:company_names], :joins => [:companies]).all.to_a
      local_factors.merge!(id =>local_factor)
      factor_cache << local_factor
      local_factor_ids << local_factor.map(&:id)
    end


    intersection_factor_ids = local_factor_ids.reduce(:&)

    factor_cache = factor_cache.flatten.uniq
    and_factors = factor_cache.select{ |factor| intersection_factor_ids.include? factor.id }

    union_factor_ids = local_factor_ids.reduce(:|)
    difference_factors  = factor_cache.reject{ |factor| intersection_factor_ids.include? factor.id}
    diff_factor_ids = difference_factors.map(&:id)


    global_factors = Vger::Resources::Suitability::Factor.where(:query_options => {:active => true,:type=>"Suitability::Factor",:is_global => true}, :scopes => { :global => nil }, :methods => [:type, :direct_predictor_ids]).all.to_a
    # factors |= Vger::Resources::Suitability::Factor.where(:query_options => {"companies_factors.company_id" => params[:company_ids], :active => true}, :methods => [:type, :direct_predictor_ids], :joins => [:companies]).all.to_a
    factors = {
      :global_factors => global_factors,
      :and_factors => and_factors,
      :difference_factors => difference_factors,
      :trait_class_type =>"suitability"
    }

    respond_to do |format|
      format.json{ render :json => { :factors => factors } }
    end
  end
end
