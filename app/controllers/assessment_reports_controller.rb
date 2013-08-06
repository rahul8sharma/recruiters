class AssessmentReportsController < ApplicationController
  layout 'reports'
  
  def show
    @report = Vger::Resources::Suitability::CandidateAssessmentReport.find(params[:id])
    url = AWS::S3::S3Object.find(@report.s3_keys[:html][:key],@report.s3_keys[:html][:bucket]).url rescue nil
    if url
      redirect_to url 
    else
      flash[:notice] = "This is not a valid report url."
      redirect_to root_url
    end
  end
  
  def assessment_report
    @report = Vger::Resources::Suitability::CandidateAssessmentReport.find(params[:id], :methods => [ :report_hash ])
    @view_mode = "html"
    respond_to do |format|
      format.html
    end
  end
end
