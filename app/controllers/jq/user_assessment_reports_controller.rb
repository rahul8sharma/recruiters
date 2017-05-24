class Jq::UserAssessmentReportsController < MasterDataController
  def api_resource
    Vger::Resources::Jq::UserAssessmentReport
  end
  
  def manage
  end
  
  
  def show
    report = api_resource.find(params[:id], params)
    if request.format.to_s == "application/pdf"
      view_mode = "pdf"
    else
      view_mode = params[:view_mode] || "html"
    end
    if report.s3_keys[view_mode].present?
      url = S3Utils.get_url(report.s3_keys[view_mode][:bucket], report.s3_keys[view_mode][:key])
      redirect_to url
    else
      raise Faraday::ResourceNotFound.new("Not Found")
    end
  end

  def report
    @norm_buckets = Vger::Resources::Suitability::NormBucket\
                        .where(order: "weight ASC").all                    
                        
    @report = api_resource.find(params[:id],params.merge(:patch => params[:patch]))
    if params[:view_mode]
      @view_mode = params[:view_mode]
    else
      if request.format == "application/pdf"
        @view_mode = "pdf"
      else  
        @view_mode = "html"
      end
    end
    template = "jq_report"
    template = @view_mode == "html" ? "#{template}.html.haml" : "#{template}.pdf.haml"
    case @view_mode
      when "html" 
        layout = "jq_reports.html.haml"
      when "pdf"
        layout  = "jq_reports.pdf.haml"
    end    
    @page = 1
    respond_to do |format|
      format.html { 
        render template: "jq/user_assessment_reports/#{template}", 
               layout: "layouts/#{layout}", 
               formats: [:pdf, :html]
      }
      format.pdf {
        render pdf: "report_#{params[:id]}.pdf",
        footer: {
          :html => {
            template: "shared/reports/pdf/_report_footer.pdf.haml",
            layout: "layouts/#{layout}"
          }
        },
        
        template: "jq/user_assessment_reports/#{template}",
        layout: "layouts/#{layout}",
        handlers: [ :haml ],
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        formats: [:pdf],
        locals: { :@view_mode => "pdf" }
      }
    end
  end
  
  def export_norm_population
    Vger::Resources::Jq::UserAssessmentReport\
      .export_norm_population({:args => params[:args]})
    redirect_to request.env['HTTP_REFERER'], notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def import_norm_population
    if !params[:file] || !params[:file][:file]
      flash[:notice] = "Please select a zip file."
      redirect_to request.env['HTTP_REFERER'] and return
    end
    data = params[:file][:file].read
    now = Time.now
    s3_key = "jq_norm_population/#{now.strftime('%d_%m_%Y_%H_%I_%p')}"
    obj = S3Utils.upload(s3_key, data)

    Vger::Resources::Jq::UserAssessmentReport\
      .import_norm_population(
                      :args => {
                        :bucket => obj.bucket.name,
                        :key => obj.key
                      }.merge(params[:args])
                    )
    redirect_to request.env['HTTP_REFERER'], notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end
  
  def index_columns
    [
      :id,
      :user_id,
      :assessment_id,
      :functional_area_id,
      :industry_id,
      :job_experience_id
    ]
  end
  
  def search_columns
    [
      :user_id,
      :assessment_id,
      :functional_area_id,
      :industry_id,
      :job_experience_id
    ]
  end
end
