class Exit::Surveys::ReportsController < ApplicationController
  before_filter :get_company, except: [:s3_report]
  before_filter :get_survey, except: [:s3_report]
  
  layout "exit"

  def report
    @candidate_survey = Vger::Resources::Exit::CandidateSurvey.where(:survey_id => params[:id], :query_options => { :candidate_id => params[:candidate_id] }).all[0]
    params[:survey_id] = params[:id]
    params[:candidate_survey_id] = @candidate_survey.id
    @report = Vger::Resources::Exit::Report.find(params[:report_id], params)
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
    template = "exit_report.#{@view_mode}.haml"
    layout = "layouts/exit_report.#{@view_mode}.haml"
    @page = 1
    respond_to do |format|
      format.html {
        render :template => "exit/surveys/reports/#{template}",
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
        template: "exit/surveys/reports/#{template}",
        layout: layout,
        handlers: [ :haml ],
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        formats: [:pdf],
        locals: { :@view_mode => "pdf" }
      }
    end
  end

  def s3_report

    params[:survey_id] =params[:id]
    report = Vger::Resources::Exit::Report.find(params[:report_id], params)
    if request.format.to_s == "application/pdf"
      url = S3Utils.get_url(report.s3_keys[:pdf][:bucket], report.s3_keys[:pdf][:key])
    else
      url = S3Utils.get_url(report.s3_keys[:html][:bucket], report.s3_keys[:html][:key])
    end
    redirect_to url
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

  def get_survey
    if params[:id].present?
      @survey = Vger::Resources::Exit::Survey.find(params[:id], company_id: @company.id)
    else
      @survey = Vger::Resources::Exit::Survey.new
    end
  end

end
