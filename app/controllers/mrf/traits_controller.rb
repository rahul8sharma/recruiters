class Mrf::TraitsController < MasterDataController
  def api_resource
    Vger::Resources::Mrf::Trait
  end

  def index
    params[:type] ||= "Mrf::Trait"
    @traits = Vger::Resources::Mrf::Trait.where(
      :methods => [:company_ids],
      :page => params[:page],
      :per => 50,
      :root => :trait
    ).all
  end

  def import_from
    "import_from_google_drive"
  end

  # GET /traits/:id
  # GET /traits/:id.json
  def show
    @trait = api_resource.find(params[:id], :root => :trait)
    @items = Vger::Resources::Mrf::Item.where(query_options: {
      trait_type: "Mrf::Trait",
      trait_id: @trait.id
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
        format.html{ redirect_to mrf_trait_path(params[:id]) }
      end
    end
  end

  def get_traits
    company_ids = params[:company_ids].split(",")

    local_factor_ids = []
    local_factors = {}
    factor_cache = []
    company_ids.each do |id|
      Rails.logger.ap id
      local_factor = Vger::Resources::Mrf::Trait.where(:query_options => {"companies_traits.company_id" => id}, :methods=>[:company_names], :joins => [:companies]).all.to_a
      Rails.logger.ap local_factor
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


    global_factors = Vger::Resources::Mrf::Trait.where(:query_options => {}, :scopes => { :global => nil }).all.to_a
    # factors |= Vger::Resources::Suitability::Factor.where(:query_options => {"companies_factors.company_id" => params[:company_ids], :active => true}, :methods => [:type, :direct_predictor_ids], :joins => [:companies]).all.to_a
    factors = {
      :global_factors => global_factors,
      :and_factors => and_factors,
      :difference_factors => difference_factors,
      :trait_class_type =>"mrf"
    }
    respond_to do |format|
      format.json{ render :json => { :factors => factors } }
    end
  end

end
