class AssessmentReportsController < ApplicationController
  layout 'reports'
  before_filter :authenticate_user!, :only => [ :manage, :assessment_report ]
  before_filter :check_superadmin, :only => [ :manage, :assessment_report ]
  
  def manage
    
    @norm_buckets = Hash[Vger::Resources::Suitability::NormBucket.all.collect{|x| [x.name, x.id.to_s]}]
    @fitment_grades = Hash[Vger::Resources::Suitability::FitmentGrade.all.collect{|x| [x.name, x.name]}]
    @report = Vger::Resources::Suitability::CandidateAssessmentReport.find(params[:id], :methods => [ :report_hash ])
    if request.put?
      ReportUploader.perform_async(@report.id, RequestStore.store[:auth_token], params[:report])
      flash[:notice] = "Report is being modified. Please check after some time."
      #redirect_to assessment_report_path(@report.id, :patch => params[:report]) and return
    end
    render :layout => "admin"
  end
  
  
  def show
    @report = Vger::Resources::Suitability::CandidateAssessmentReport.find(params[:id])
    url = S3Utils.get_url(@report.s3_keys[:html][:bucket], @report.s3_keys[:html][:key])
    redirect_to url 
  end
  
  def assessment_report
    @report = Vger::Resources::Suitability::CandidateAssessmentReport.find(params[:id], :patch => params[:patch], :methods => [ :report_hash ])
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
  
  private
  
  def check_superadmin
    if current_user.type != "SuperAdmin"
      flash[:error] = "You are not authorized to access this page."
      redirect_to root_url and return
    end 
  end
end
