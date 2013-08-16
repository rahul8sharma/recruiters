class AssessmentReportsController < ApplicationController
  layout 'reports'
  
  def show
    @report = Vger::Resources::Suitability::CandidateAssessmentReport.find(params[:id])
    url = S3Utils.get_url(@report.s3_keys[:html][:bucket], @report.s3_keys[:html][:key])
    redirect_to url 
  end
  
  def assessment_report
    @report = Vger::Resources::Suitability::CandidateAssessmentReport.find(params[:id], :methods => [ :report_hash ])
    @view_mode = "html"
    respond_to do |format|
      format.html
    end
  end
end
