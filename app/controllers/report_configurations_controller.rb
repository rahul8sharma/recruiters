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

  def report_preview_mrf
    report_type = 'mrf'
    get_mrf_norm_buckets
    @norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]

    report_conf = YAML::load(File.open("#{Rails.root.to_s}/config/report_dumps/#{report_type}_#{params[:assessment_type]}.yml")).with_indifferent_access
    @report = Vger::Resources::Mrf::Report.new(report_conf)
 
    if params[:assessment_type] == 'competency'
      @assessment = Vger::Resources::Mrf::Assessment.new
      @assessment.report_data = {:competency_scores => {}, :trait_scores => {}}
      @report.report_data[:competency_scores].each do |competency, competency_scores|
          @assessment.report_data[:competency_scores][competency] = {
            :min_score => { :score => 0 },
            :max_score => { :score => 0 }
          }
          competency_scores[:trait_scores].each do |trait_scores|
             @assessment.report_data[:trait_scores][trait_scores[:trait][:name]] = {
              :min_score => { :score => 0 },
              :max_score => { :score => 0 }
            } 
          end
      end
    end
    @report.report_hash = @report.report_data
    @report.report_configuration = HashWithIndifferentAccess.new JSON.parse(params[:config])
    layout = "layouts/mrf/reports.#{params[:view_mode]}.haml"
    template = "mrf/assessments/reports/#{params[:assessment_type]}_report.#{params[:view_mode]}.haml"
    render json:{ 
      content: render_to_string(
        :template => template,
        :layout => layout)
    }
  end

  def report_preview_suitability
    report_type = 'suitability'
    
    get_suitability_norm_bucket
    @view_mode = params[:view_mode]

    report_conf = YAML::load(File.open("#{Rails.root.to_s}/config/report_dumps/#{report_type}_#{params[:assessment_type]}.yml")).with_indifferent_access
    @report = Vger::Resources::Mrf::Report.new(report_conf)

    @report.report_hash = @report.report_data
    @report.report_configuration = HashWithIndifferentAccess.new JSON.parse(params[:config])

    if params[:view_mode]
      @view_mode = params[:view_mode]
    else
      if request.format == "application/pdf"
        @view_mode = "pdf"
      else  
        @view_mode = "html"
      end
    end
    template = if @report.configuration[:is_functional_assessment]
      "functional_report"
    elsif @report.report_hash[:assessment][:assessment_type] == "competency"
      "competency_report"
    else
      "assessment_report"
    end
    template = @view_mode == "html" ? "#{template}.html.haml" : "#{template}.pdf.haml"
    case @view_mode
      when "html" 
        layout = "candidate_reports.html.haml"
      when "pdf"
        layout  = "candidate_reports.pdf.haml"
      when "feedback"  
        layout  = "feedback_reports.html.haml"
        template = "assessment_report_feedback.html.haml"
    end    
    @page = 1
    
    render json:{ 
      content: render_to_string(
        :template => "assessment_reports/#{template}",
        :layout => "layouts/#{layout}")
    }
  end


  def edit
    @resource = api_resource.find(params[:id], :methods => index_columns)
  end
  
  protected
  
  def get_suitability_norm_bucket
    @norm_buckets = Vger::Resources::Suitability::NormBucket\
                        .where(order: "weight ASC").all                    
                        
    @company_norm_buckets = Vger::Resources::Suitability::CompanyNormBucket\
                        .where(query_options: {
                          company_id: params[:company_id]
                        })\
                        .where(order: "weight ASC").all
    
    if @company_norm_buckets.empty?
      @company_norm_buckets = Vger::Resources::Suitability::CompanyNormBucket\
                        .where(query_options: {
                          company_id: nil
                        })\
                        .where(order: "weight ASC").all                    
    end                    
  end

  def get_mrf_norm_buckets
    @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                      order: "weight ASC", query_options: {
                        company_id: params[:company_id]
                      }).all
    
    if @norm_buckets.empty?
      @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                      order: "weight ASC", query_options: {
                        company_id: nil
                      }).all
    end
    @trait_graph_buckets = Vger::Resources::Mrf::TraitGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: params[:company_id]
                      }).all
    
    if @trait_graph_buckets.empty?
      @trait_graph_buckets = Vger::Resources::Mrf::TraitGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: nil
                      }).all
    end
    @competency_graph_buckets = Vger::Resources::Mrf::CompetencyGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: params[:company_id]
                      }).all
    
    if @competency_graph_buckets.empty?
      @competency_graph_buckets = Vger::Resources::Mrf::CompetencyGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: nil
                      }).all
    end
  end

  def set_params
    params[:report_configuration][:configuration] = JSON.parse(params[:report_configuration][:configuration])
  end
end