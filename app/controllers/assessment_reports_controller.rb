class AssessmentReportsController < ApplicationController
  layout 'reports'
  
  def show
    @report = Vger::Resources::Suitability::CandidateAssessmentReport.find(params[:id])
    url = S3Utils.get_url(@report.s3_keys[:html][:bucket], @report.s3_keys[:html][:key])
    redirect_to url 
  end
  
  def assessment_report
    @report = Vger::Resources::Suitability::CandidateAssessmentReport.find(params[:id], :methods => [ :report_hash ])
    if request.format == "application/pdf"
      @view_mode = "pdf"
    else  
      @view_mode = "html"
    end
    @page = 1
    respond_to do |format|
      format.html
      format.pdf { 
        render pdf: "report_#{params[:id]}.pdf",
        header: { 
          :html => {
            template: "shared/_report_header.html.haml"
          }
        },
        footer: {
          :html => {
            template: "shared/_report_footer.html.haml"
          }
        },           
        template: 'assessment_reports/assessment_report.html.haml', 
        layout: "layouts/reports.html.haml", 
        handlers: [ :haml ], margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        locals: { :@view_mode => "pdf" }
      }
    end
  end
end
