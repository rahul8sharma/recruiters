class AssessmentReportsController < ApplicationController
  layout 'reports'
  before_filter :authenticate_user!, :only => [ :manage, :assessment_report ]
  before_filter :check_superadmin, :only => [ :manage, :assessment_report ]
  
  def manage
    @norm_buckets = Hash[Vger::Resources::Suitability::NormBucket.all.collect{|x| [x.name, x.id.to_s]}]
    @fitment_grades = Hash[Vger::Resources::Suitability::FitmentGrade.all.collect{|x| [x.name, x.name]}]
    @report = Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.find(params[:id], params.merge(:methods => [ :assessment_id, :candidate_id, :company_id, :report_hash ]))
    if request.put?
      report_data = {
        :id => @report.id,
        :company_id => @report.company_id,
        :assessment_id => @report.assessment_id,
        :candidate_id => @report.candidate_id
      }
      ReportUploader.perform_async(report_data, RequestStore.store[:auth_token], params[:report])
      flash[:notice] = "Report is being modified. Please check after some time."
      #redirect_to assessment_report_company_assessment_candidate_candidate_assessment_report_url(@report, :company_id => params[:company_id], :candidate_id => params[:candidate_id], :assessment_id => params[:assessment_id], :patch => params[:report]) and return
    end
    render :layout => "admin"
  end
  
  
  def show
    @report = Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.find(params[:id], params)
    if request.format.to_s == "application/pdf"
      type = "pdf"
    else
      type = "html"
    end  
    url = S3Utils.get_url(@report.s3_keys[type][:bucket], @report.s3_keys[type][:key])
    redirect_to url 
  end

  def assessment_report
    report_type = params[:report_type] || @report.report_hash[:assessment][:assessment_type]
    @report = Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.find(params[:id],params.merge(:patch => params[:patch], :report_type => report_type , :methods => [ :report_hash ]))
    if request.format == "application/pdf"
      @view_mode = "pdf"
    else  
      @view_mode = "html"
    end
    template = report_type == "fit" ? "assessment_report" : "competency_report"
    @page = 1
    respond_to do |format|
      format.html { render :template => "assessment_reports/#{template}" }
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
        template: "assessment_reports/#{template}.html.haml", 
        layout: "layouts/reports.html.haml", 
        handlers: [ :haml ], 
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        formats: [:html],
        locals: { :@view_mode => "pdf" }
      }
    end
  end
end
