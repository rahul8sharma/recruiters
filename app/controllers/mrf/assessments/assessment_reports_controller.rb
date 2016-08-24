class Mrf::Assessments::AssessmentReportsController < Mrf::Assessments::ReportsController
  before_filter :get_candidates, only: [:new_group_report, :edit_group_report]

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
            template: "shared/reports/pdf/_report_footer.pdf.haml",
            layout: layout
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
    report = Vger::Resources::Mrf::AssessmentReport.find(params[:report_id],{
      assessment_id: params[:id],
      company_id: params[:company_id],
      report_id: params[:report_id]
    })
    if request.format.to_s == "application/pdf"
      url = S3Utils.get_url(report.pdf_bucket, report.pdf_key)
    else
      url = S3Utils.get_url(report.html_bucket, report.html_key)
    end
    redirect_to url
  end
  
  def group_reports
    @group_reports = Vger::Resources::Mrf::AssessmentReport.where(
      query_options: {
        assessment_id: @assessment.id
      },
      page: params[:page],
      per: 10
    )
    render :layout => "mrf/mrf"
  end
  
  def edit_group_report
    @group_report = Vger::Resources::Mrf::AssessmentReport\
                        .find(params[:report_id], { 
                          company_id: params[:company_id], 
                          assessment_id: params[:id] 
                        })
    render :layout => "mrf/mrf"
  end
  
  def new_group_report
    @group_report = Vger::Resources::Mrf::AssessmentReport.new
    render :layout => "mrf/mrf"
  end
  
  def create
    params[:candidates] ||= {}
    @group_report = Vger::Resources::Mrf::AssessmentReport.create(params[:group_report].merge({
      :candidate_ids => params[:candidates].keys.map(&:to_i)
    }))
    if @group_report.error_messages.empty?
      redirect_to edit_group_report_company_mrf_assessment_path(@company.id, @assessment.id, @group_report.id)
    else
      render :action => :new_group_report, :layout => "mrf/mrf"
    end
  end
  
  def update
    params[:candidates] ||= {}                         
    @group_report = Vger::Resources::Mrf::AssessmentReport\
                        .find(params[:report_id], { 
                          company_id: params[:company_id], 
                          assessment_id: params[:id] 
                        })
    @group_report = Vger::Resources::Mrf::AssessmentReport\
                    .save_existing(params[:report_id], params[:group_report].merge(
                      :candidate_ids => params[:candidates].keys.map(&:to_i)
                    ))
    if @group_report.error_messages.empty?
      redirect_to group_reports_company_mrf_assessment_path(@company.id, @assessment.id)
    else
      render :action => :edit_group_report, :layout => "mrf/mrf"
    end
  end
  
  protected
  
  def get_candidates
    @users = Vger::Resources::User.where(
      joins: :feedbacks,
      query_options: {
        "mrf_feedbacks.assessment_id" => @assessment.id
      },
      select: "distinct(jombay_users.id),jombay_users.name,email",
      order: "jombay_users.id asc"
    ).all
  end
end
