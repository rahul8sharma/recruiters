class Mrf::Assessments::ReportsController < ApplicationController
  before_filter :get_company, except: [:s3_report]
  before_filter :get_assessment, except: [:s3_report]
  
  def report
    report_type = params[:report_type] || "fit_report"  
    @norm_buckets = Vger::Resources::Mrf::NormBucket.where(order: "weight ASC").all
    @norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
    @report = Vger::Resources::Mrf::Report.find(params[:report_id], params) 
    @report.report_hash = @report.report_data
    
    if @assessment.configuration[:use_competencies]
      if params[:view_mode]
        @view_mode = params[:view_mode]
      else
        if request.format == "application/pdf"
          @view_mode = "pdf"
          template = "competency_report.pdf.haml"
          layout = "layouts/reports_360.pdf.html"
        else  
          @view_mode = "html"
          template = "competency_report.html.haml"
          layout = "layouts/reports_360.html.haml"
        end
      end
    else
      if params[:view_mode]
        @view_mode = params[:view_mode]
      else
        if request.format == "application/pdf"
          @view_mode = "pdf"
          template = "fit_report.pdf.haml"
          layout = "layouts/reports_360.pdf.haml"
        else  
          @view_mode = "html"
          template = "fit_report.html.haml"
          layout = "layouts/reports_360.html.haml"
        end
      end
    end

    @page = 1
    respond_to do |format|
      format.html { 
        render :template => "mrf/assessments/reports/#{template}",
        layout: layout,
        formats: [:pdf, :html]
      }
      format.pdf {
        render pdf: "report_#{params[:id]}.pdf",
        template: template,
        layout: layout
        handlers: [ :haml ],
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        formats: [:pdf],
        locals: { :@view_mode => "pdf" }
      }
    end
  end

  def s3_report
    report = Vger::Resources::Mrf::Report.find(params[:report_id], params)
    url = S3Utils.get_url(report.html_bucket, report.html_key)
    redirect_to url
  end

  protected

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
