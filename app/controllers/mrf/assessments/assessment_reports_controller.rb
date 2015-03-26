class Mrf::Assessments::AssessmentReportsController < Mrf::Assessments::ReportsController
  def group_report
    get_norm_buckets
    @norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
    @report = Vger::Resources::Mrf::AssessmentReport.find(params[:report_id], 
      { company_id: params[:company_id], assessment_id: params[:id] }
    )
    @report.report_hash = @report.report_data
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
      template = "competency_group_report.#{@view_mode}.haml"
    else
      template = "fit_group_report.#{@view_mode}.haml" 
    end  
    layout = "layouts/mrf/group_reports.#{@view_mode}.haml"
    @page = 1
    respond_to do |format|
      format.html { 
        render :template => "mrf/assessments/assessment_reports/#{template}",
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
        template: "mrf/assessments/assessment_reports/#{template}",
        layout: layout,
        handlers: [ :haml ],
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        formats: [:pdf],
        locals: { :@view_mode => "pdf" }
      }
    end
  end
  
  def s3_report
    report = Vger::Resources::Mrf::AssessmentReport.find(params[:report_id],params)
    if request.format.to_s == "application/pdf"
      url = S3Utils.get_url(report.pdf_bucket, report.pdf_key)
    else
      url = S3Utils.get_url(report.html_bucket, report.html_key)
    end
    redirect_to url
  end
  
  def manage
    @group_report = Vger::Resources::Mrf::AssessmentReport.where(
      query_options: {
      assessment_id: @assessment.id
    }).all.first
    @group_report ||= Vger::Resources::Mrf::AssessmentReport.new
    render :layout => "mrf/mrf"
  end
  
  def create
    @group_report = Vger::Resources::Mrf::AssessmentReport.create(params[:group_report])
    if @group_report.error_messages.empty?
      redirect_to manage_group_report_company_mrf_assessment_path(@company.id, @assessment.id)
    else
      render :action => :manage, :layout => "mrf/mrf"
    end
  end
  
  def update
    @group_report = Vger::Resources::Mrf::AssessmentReport.save_existing(params[:report_id], params[:group_report])
    if @group_report.error_messages.empty?
      redirect_to manage_group_report_company_mrf_assessment_path(@company.id, @assessment.id)
    else
      render :action => :manage, :layout => "mrf/mrf"
    end
  end
end
