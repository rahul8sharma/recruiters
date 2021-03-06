class Suitability::CompetenciesController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::Competency
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :uid, :name, :company_ids, :factor_names, :modules, :active, :description]
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
    set_params
    @competency = Vger::Resources::Suitability::Competency.create(params[:competency])
    respond_to do |format|
      format.html{ redirect_to self.send("#{resource_name.singularize}_path",@competency) }
      format.js
    end
  end

  def edit
    @competency = api_resource.find(params[:id], :root => :competency,
      :methods => [:company_ids]
    )
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  def show
    @competency = api_resource.find(params[:id], :root => :competency,
      :methods => [:company_ids]
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
    params[:competency][:company_ids] = company_ids
  end


  def get_competencies
    competencies = Vger::Resources::Suitability::Competency.global(:query_options => {:active => true}, :methods => [:factor_names], :order => ["name ASC"]).to_a
    competencies |= Vger::Resources::Suitability::Competency.where(:query_options => { "companies_competencies.company_id" => params[:company_ids], :active => true }, :methods => [:factor_names], :order => ["name ASC"], :joins => "companies").all.to_a
    respond_to do |format|
      format.json{ render :json => { :competencies => competencies } }
    end
  end
end
