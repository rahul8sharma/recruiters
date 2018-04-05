class Mrf::Assessments::ReportsController < ApplicationController
  before_action :get_company, except: [:s3_report]
  before_action :get_assessment, except: [:s3_report]
  
  def report
    report_type = params[:report_type] || "fit_report"  
    get_norm_buckets
    @norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
    @report = Vger::Resources::Mrf::Report.find(params[:report_id], params) 
    @report.report_hash = @report.report_data
    @report.report_configuration = @assessment.report_configuration
    if params[:view_mode]
      @view_mode = params[:view_mode]
    else
      if request.format == "application/pdf"
        @view_mode = "pdf"
      else  
        @view_mode = "html"
      end
    end
    if @report.report_data[:assessment][:use_competencies]
      template = "competency_report.#{@view_mode}.haml"
    else
      template = "fit_report.#{@view_mode}.haml" 
    end  
    layout = "layouts/mrf/reports.#{@view_mode}.haml"
    @page = 1
    respond_to do |format|
      format.html { 
        render :template => "mrf/assessments/reports/#{template}",
        layout: layout,
        formats: [:pdf, :html]
      }
      format.pdf {
        render pdf: "report_#{params[:id]}.pdf",
        footer: {
          :html => {
            template: "shared/reports/pdf/_report_footer.pdf.haml"
          }
        },
        template: "mrf/assessments/reports/#{template}",
        layout: layout,
        handlers: [ :haml ],
        margin: { :left => 0,:right => 0, :top => 0, :bottom => 8 },
        formats: [:pdf],
        locals: { :@view_mode => "pdf" }
      }
    end
  end


  def s3_report
    report = Vger::Resources::Mrf::Report.find(params[:report_id], params.to_h)
    if request.format.to_s == "application/pdf"
      view_mode = "pdf"
    else
      view_mode = params[:view_mode] || "html"
    end
    bucket = report.send("#{view_mode}_bucket")
    key = report.send("#{view_mode}_key")
    if report.send("#{view_mode}_bucket").present? && (is_superuser? || report.uploaded?)
      url = S3Utils.get_url(bucket, key)
      redirect_to url
    else
      raise Faraday::ResourceNotFound.new("Not Found")
    end
  end


  protected
  
  def get_norm_buckets
    @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                      order: "weight ASC", query_options: {
                        company_id: @company.id
                      }).all
    
    if @norm_buckets.empty?
      @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                      order: "weight ASC", query_options: {
                        company_id: nil
                      }).all
    end
    @trait_graph_buckets = Vger::Resources::Mrf::TraitGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: @company.id
                      }).all
    
    if @trait_graph_buckets.empty?
      @trait_graph_buckets = Vger::Resources::Mrf::TraitGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: nil
                      }).all
    end
    @competency_graph_buckets = Vger::Resources::Mrf::CompetencyGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: @company.id
                      }).all
    
    if @competency_graph_buckets.empty?
      @competency_graph_buckets = Vger::Resources::Mrf::CompetencyGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: nil
                      }).all
    end
  end

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

  def get_assessment
    if params[:id].present?
      @assessment = Vger::Resources::Mrf::Assessment.find(params[:id], company_id: @company.id, :include => {:assessment_traits => { methods: [:trait] } })
    else
      @assessment = Vger::Resources::Mrf::Assessment.new
    end
  end

end
