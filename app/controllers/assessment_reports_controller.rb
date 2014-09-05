class AssessmentReportsController < ApplicationController
  layout 'candidate_reports'
  before_filter :authenticate_user!, :only => [ :manage, :assessment_report ]
  before_filter :check_superadmin, :only => [ :manage, :assessment_report ]

  def training_requirements_report
    @assessment = Vger::Resources::Suitability::CustomAssessment.find(params[:id])
    @assessment_report = Vger::Resources::Suitability::AssessmentReport.where(:query_options => {
                            assessment_id: params[:id],
                            report_type: Vger::Resources::Suitability::CustomAssessment::ReportType::TRAINING_REQUIREMENT,
                            status: Vger::Resources::Suitability::AssessmentReport::Status::UPLOADED
                          }).all.to_a.first
    if !@assessment_report
      redirect_to company_assessment_path(:company_id => params[:company_id], :id => params[:id]), alert: "Assessment Report not found!"
      return
    end
    @report_data = @assessment_report.report_data
    if request.format == "application/pdf"
      @view_mode = "pdf"
    else
      @view_mode = "html"
    end
    respond_to do |format|
      format.html {
        render template: "assessment_reports/training_requirements_report",
               layout: "layouts/training_requirements_report.html.haml"
      }
      format.pdf {
        render pdf: "training_requirements_report_#{params[:id]}.pdf",
        footer: {
          :html => {
            template: "shared/reports/pdf/_report_footer.pdf.haml"
          }
        },
        template: "assessment_reports/training_requirements_report.html.haml",
        layout: "layouts/training_requirements_report.html.haml",
        handlers: [ :haml ],
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        formats: [:html],
        locals: { :@view_mode => "pdf" }
      }
    end
  end

  def benchmark_report
    @assessment = Vger::Resources::Suitability::CustomAssessment.find(params[:id], methods: [:benchmark_report])
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(order: "weight ASC").all
    @report = @assessment.benchmark_report
    if request.format == "application/pdf"
      @view_mode = "pdf"
    else
      @view_mode = "html"
    end
    respond_to do |format|
      format.html { render :template => "assessment_reports/benchmark_report",
        layout: "layouts/benchmark_report.html.haml"}
      format.pdf {
        render pdf: "report_#{params[:id]}.pdf",
        footer: {
          :html => {
            template: "shared/reports/pdf/_report_footer.pdf.haml"
          }
        },
        template: "assessment_reports/benchmark_report.html.haml",
        layout: "layouts/benchmark_report.html.haml",
        handlers: [ :haml ],
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        formats: [:html],
        locals: { :@view_mode => "pdf" }
      }
    end
  end

  def manage
    @norm_buckets = Hash[Vger::Resources::Suitability::NormBucket.where(order: "weight ASC").all.collect{|x| [x.name, x.id.to_s]}]
    @overall_factor_score_buckets = Hash[Vger::Resources::Suitability::OverallFactorScoreBucket.all.collect{|x| [x.name, x.id.to_s]}]
    @fitment_grades = Hash[Vger::Resources::Suitability::FitmentGrade.all.collect{|x| [x.name, x.name]}]
    @fitment_grades["N/A"] = "N/A"
    @fitment_grades["Blank"] = ""
    @competency_grades = Hash[Vger::Resources::Suitability::CompetencyGrade.all.collect{|x| [x.name, x.name]}]
    @aggregate_competency_score_buckets = Hash[Vger::Resources::Suitability::AggregateCompetencyScoreBucket.all.collect{|x| [x.name, x.id.to_s]}]
    @report = Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.find(params[:id], params.merge(:methods => [ :assessment_id, :candidate_id, :company_id ]))
    @report.report_hash = @report.report_data
    if request.put?
      report_data = {
        :id => @report.id,
        :company_id => @report.company_id,
        :assessment_id => @report.assessment_id,
        :candidate_id => @report.candidate_id
      }
      ReportUploader.perform_async(report_data, RequestStore.store[:auth_token], params[:report])
      flash[:notice] = "Report is being modified. Please check after some time."
      #redirect_to assessment_report_company_custom_assessment_candidate_candidate_assessment_report_url(@report, :company_id => params[:company_id], :candidate_id => params[:candidate_id], :custom_assessment_id => params[:custom_assessment_id], :patch => params[:report], :view_mode => params[:view_mode]) and return
    end
    render :layout => "admin"
  end

  def show
    report = Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.find(params[:id], params)
    if request.format.to_s == "application/pdf"
      view_mode = "pdf"
    else
      view_mode = params[:view_mode] || "html"
    end
    url = S3Utils.get_url(report.s3_keys[view_mode][:bucket], report.s3_keys[view_mode][:key])
    redirect_to url
  end

  def assessment_report
    report_type = params[:report_type] || "fit"
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(order: "weight ASC").all
    @report = Vger::Resources::Suitability::Assessments::CandidateAssessmentReport.find(params[:id],params.merge(:patch => params[:patch], :report_type => report_type))
    @report.report_hash = @report.report_data
    Rails.logger.debug(@report.report_hash)
    @view_mode = params[:view_mode]
    request.format = "pdf" if @view_mode == "pdf"
    template = report_type == "fit" ? "assessment_report" : "competency_report"
    @page = 1
    respond_to do |format|
      format.html { render :template => "assessment_reports/#{template}" }
      format.pdf {
        render pdf: "report_#{params[:id]}.pdf",
        footer: {
          :html => {
            template: "shared/reports/pdf/_report_footer.pdf.haml",
            layout: "layouts/candidate_reports.pdf.haml"
          }
        },
        template: "assessment_reports/#{template}.pdf.haml",
        layout: "layouts/candidate_reports.pdf.haml",
        handlers: [ :haml ],
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        formats: [:html],
        locals: { :@view_mode => "pdf" }
      }
    end
  end
end
