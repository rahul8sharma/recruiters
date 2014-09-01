class Mrf::Assessments::ReportsController < ApplicationController
  before_filter :get_company
  before_filter :get_assessment
  layout "reports_360"
  
  def report
    report_type = params[:report_type] || "fit_report"  
    @norm_buckets = Vger::Resources::Suitability::NormBucket.all
  
    @report = Vger::Resources::Mrf::Report.where(:query_options =>{:candidate_id => params[:candidate_id], :assessment_id => params[:id]}).all.to_a.first  
  
    Rails.logger.debug(@report.report_data)
    
    if @assessment.configuration[:use_competencies]
      template = 'competency_report'
    else
      template = 'fit_report'
    end
    respond_to do |format|
      format.html { render :template => "mrf/assessments/reports/#{template}" }
    end
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