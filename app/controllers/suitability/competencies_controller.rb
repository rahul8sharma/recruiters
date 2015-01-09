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
    params[:forms] ||= 1
    @forms = params[:forms].to_i
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
    @competency = Vger::Resources::Suitability::Competency.create(params[:competency])
    respond_to do |format|
      format.html{ redirect_to self.send("#{resource_name.singularize}_path",@competency) }
      format.js
    end
  end

  def edit
    @competency = api_resource.find(params[:id], :root => :competency, 
      :methods => [:factor_ids, :company_ids, :functional_trait_ids, :mrf_trait_ids]
    )
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  def show
    @competency = api_resource.find(params[:id], :root => :competency, 
      :methods => [:factor_ids, :company_ids, :functional_trait_ids, :mrf_trait_ids]
    )
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  def update
    set_params
    @competency = api_resource.save_existing(params[:id], params[:competency])
    respond_to do |format|
      if @competency.error_messages.present?
        flash[:error] = @competency.error_messages.join("<br/>").html_safe
        format.html{ render :action => :edit }
        format.js
      else
        format.html{ redirect_to suitability_competency_path(params[:id]) }
        format.js
      end
    end
  end
  
  def set_params
    company_ids = params[:company_ids].to_s.split(",").map(&:to_i)
    params[:factor_ids] ||= {}
    params[:mrf_trait_ids] ||= {}
    params[:functional_trait_ids] ||= {}

    factor_ids = params[:factor_ids]\
      .collect { |index,factor_hash| factor_hash.keys}\
      .flatten.map(&:to_i)
    mrf_trait_ids = params[:mrf_trait_ids]\
      .collect { |index, factor_hash| factor_hash.keys}\
      .flatten.map(&:to_i)
    functional_trait_ids = params[:functional_trait_ids]\
      .collect { |index, factor_hash| factor_hash.keys}\
      .flatten.map(&:to_i)
    params[:competency][:factor_ids] = factor_ids
    params[:competency][:mrf_trait_ids] = mrf_trait_ids
    params[:competency][:functional_trait_ids] = functional_trait_ids
    params[:competency][:company_ids] = company_ids
  end
end
