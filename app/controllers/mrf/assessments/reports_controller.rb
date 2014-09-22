class Mrf::Assessments::ReportsController < ApplicationController
  before_filter :get_company, except: [:s3_report]
  before_filter :get_assessment, except: [:s3_report]
  layout "reports_360"
  
  def report
    report_type = params[:report_type] || "fit_report"  
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(order: "weight ASC").all
  
    @report = Vger::Resources::Mrf::Report.find(params[:report_id], params) 
    @report.report_hash = @report.report_data

    if @assessment.configuration[:use_competencies]
      template = 'competency_report'
    else
      template = 'fit_report'
    end
    respond_to do |format|
      format.html { render :template => "mrf/assessments/reports/#{template}" }
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
