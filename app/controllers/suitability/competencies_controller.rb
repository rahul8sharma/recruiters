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
