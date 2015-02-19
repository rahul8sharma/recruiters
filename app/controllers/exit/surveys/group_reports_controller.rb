class Exit::Surveys::GroupReportsController < ApplicationController
  before_filter :get_company, except: [:s3_report]
  before_filter :get_survey, except: [:s3_report]
  
  layout "exit"
  
  def index
    params[:order_by] ||= "id"
    params[:order_type] ||= "DESC"
    @reports = Vger::Resources::Exit::GroupReport.where(
      query_options: {
        :survey_id => @survey.id
      },
      order: "#{params[:order_by]} #{params[:order_type]}",
      page: params[:page],
      per: 5
    ).all
  end

  def report
    @report = Vger::Resources::Exit::GroupReport.find(params[:report_id], params)
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
    layout = "layouts/exit_group_report.#{@view_mode}.haml"
    @page = 1
    respond_to do |format|
      format.html {
        render :template => "exit/surveys/group_reports/#{template}",
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
        template: "exit/surveys/group_reports/#{template}",
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
    report = Vger::Resources::Exit::GroupReport.find(params[:report_id], params)
    if request.format.to_s == "application/pdf"
      url = S3Utils.get_url(report.s3_keys[:pdf][:bucket], report.s3_keys[:pdf][:key])
    else
      url = S3Utils.get_url(report.s3_keys[:html][:bucket], report.s3_keys[:html][:key])
    end
    redirect_to url
  end
  
  def new
    get_custom_form
    @report = Vger::Resources::Exit::GroupReport.new(params[:group_report])
    @report.criteria ||= {}
  end
  
  def edit
    get_custom_form
    @report = Vger::Resources::Exit::GroupReport.find(params[:report_id], :company_id => @survey.company_id)
    @report.criteria ||= {}
  end
  
  def create
    @report = Vger::Resources::Exit::GroupReport.create(params[:group_report])
    if @report.error_messages.empty?
      redirect_to group_reports_company_exit_survey_path(@company.id, @survey.id)
    else  
      get_custom_form
      @report.criteria ||= {}
      flash[:error] = @report.error_messages.join("<br/>").html_safe
      render :action => :new
    end
  end
  
  def update
    @report = Vger::Resources::Exit::GroupReport.find(params[:report_id], :company_id => @survey.company_id)
    if Vger::Resources::Exit::GroupReport.save_existing(params[:report_id],params[:group_report])
      redirect_to group_reports_company_exit_survey_path(@company.id, @survey.id)
    else
      get_custom_form
      @report.criteria ||= {}
      flash[:error] = @report.error_messages.join("<br/>").html_safe
      render :action => :edit
    end
  end
  
  def show
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
  
  def get_custom_form
    @custom_form = Vger::Resources::FormBuilder::FactualInformationForm.where({
      query_options: {
        :assessment_id => @survey.id,
        :assessment_type => @survey.class.name.gsub("Vger::Resources::","")
      }
    }).all.to_a[0]
    if @custom_form
      @defined_fields = Vger::Resources::FormBuilder::DefinedField.where(
        query_options: {
          defined_form_id: @custom_form.defined_form_id
        }, 
        order: "field_order ASC"
      ).all.to_a
    end
  end
end
