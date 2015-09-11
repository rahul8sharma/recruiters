class ReportConfigurationsController < MasterDataController
  before_filter :authenticate_user!
  before_filter :set_params, :only => [:create, :update]
  
  def api_resource
    Vger::Resources::ReportConfiguration
  end
  
  def index_columns
    [
      :id,
      :company_id,
      :report_type,
      :assessment_type,
      :view_mode
    ]
  end
  
  def search_columns
    [
      :id,
      :company_id,
      :report_type,
      :assessment_type,
      :view_mode
    ]
  end
  
  def load_configuration
    file = YAML.load(File.read(Rails.root.join("config/report_configurations_#{params[:report_type]}.yml"))).with_indifferent_access
    @config = file[params[:report_type]][params[:assessment_type]][params[:view_mode]] rescue nil
    selected = [];
    error = nil
    if @config
      if(params[:id].present?)
        @resource = api_resource.find(params[:id], :methods => index_columns)
        selected = @resource.configuration[:sections]
      end
      selected_sections = selected.collect{|x| x[:id] }
      sections = @config["sections"].sort_by{|section| selected_sections.index(section[:id]) || 1000 }
    else
      error = "Invalid combination."
    end
    render :json => { config: sections.to_json, selected: selected.to_json, error: error }
  end
  
  def edit
    @resource = api_resource.find(params[:id], :methods => index_columns)
  end
  
  protected
  
  def set_params
    params[:report_configuration][:configuration] = JSON.parse(params[:report_configuration][:configuration])
  end
end
