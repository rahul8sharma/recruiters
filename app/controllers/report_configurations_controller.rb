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
      :assessment_type
    ]
  end
  
  def search_columns
    [
      :id,
      :company_id,
      :report_type,
      :assessment_type
    ]
  end
  
  def load_configuration
    file = YAML.load(File.read(Rails.root.join("config/report_configurations_#{params[:report_type]}.yml"))).with_indifferent_access
    @config = file[params[:report_type]][params[:assessment_type]] rescue nil
    selected = { html: { sections: [] }, pdf: { sections: [] } };
    error = nil
    if @config
      if(params[:id].present?)
        @resource = api_resource.find(params[:id], :methods => index_columns)
        selected = @resource.configuration
        selected[:html][:sections] ||= []
        selected[:pdf][:sections] ||= []
      else
        @resource = api_resource.where({
          query_options: {
            report_type: params[:report_type],
            assessment_type: params[:assessment_type],
            company_id: params[:company_id]
          } 
        }).first
        
        if !@resource
          @resource = api_resource.where({
            query_options: {
              report_type: params[:report_type],
              assessment_type: params[:assessment_type],
              company_id: nil
            } 
          }).first
        end
        
        if @resource
          selected = @resource.configuration
          selected[:html][:sections] ||= []
          selected[:pdf][:sections] ||= []
        end
      end
      selected_html_sections = selected[:html][:sections].collect{|x| x[:id] }
      selected_pdf_sections = selected[:pdf][:sections].collect{|x| x[:id] }
      html_sections = @config["html"]["sections"].sort_by{|section| selected_html_sections.index(section[:id]) || 1000 }
      pdf_sections = @config["pdf"]["sections"].sort_by{|section| selected_pdf_sections.index(section[:id]) || 1000 }
    else
      error = "Invalid combination."
    end
    render :json => { config: { html: { sections: html_sections }, pdf: { sections: pdf_sections } }.to_json, selected: selected.to_json, error: error }
  end
  
  def edit
    @resource = api_resource.find(params[:id], :methods => index_columns)
  end
  
  protected
  
  def set_params
    params[:report_configuration][:configuration] = JSON.parse(params[:report_configuration][:configuration])
  end
end
