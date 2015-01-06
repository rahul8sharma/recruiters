class Suitability::CompetenciesController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::Competency
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :uid, :name, :company_ids, :factor_names, :active]
  end

  def search_columns
    [
      :id,
      :name
    ]
  end

  def new
    params[:competency] ||= {}
    @competency = Vger::Resources::Suitability::Competency.new
    respond_to do |format|
      format.html
    end
  end

  # POST /suitability/competencies
  # POST /suitabilty/competencies.json
  # POST creates competency
  def create
    Rails.logger.debug("Create Competency params are #{params}")
    factor_ids = params[:competency][:factor]\
    .collect { |index,factor_hash| factor_hash.keys} unless params[:competency][:factor].blank?
    mrf_trait_ids = params[:competency][:mrf_trait]\
    .collect { |index, factor_hash| factor_hash.keys} unless params[:competency][:mrf_trait].blank?
    functional_trait_ids = params[:competency][:functional_trait]\
      .collect { |index, factor_hash| factor_hash.keys} unless params[:competency][:functional_trait].blank?
    params[:competency][:factor] = factor_ids
    params[:competency][:mrf_trait] = mrf_trait_ids
    params[:competency][:functional_trait] = functional_trait_ids
    Vger::Resources::Suitability::Competency.create_competency(params[:competency])
    render :action => :index
  end

  def edit
    @competency = api_resource.find(params[:id], :root => :competency)
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def show
    @competency = api_resource.find(params[:id], :root => :competency)
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def update
    @competency = api_resource.save_existing(params[:id], params[:competency])
    respond_to do |format|
      if @competency.error_messages.present?
        flash[:error] = @competency.error_messages.join("<br/>").html_safe
        format.html{ render :action => :edit }
      else
        format.html{ redirect_to suitability_competency_path(params[:id]) }
      end
    end
  end
end
