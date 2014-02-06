class TrainingRequirementGroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_company
  before_filter :get_training_requirement_group, :except => [:index]
  
  layout "training_requirement_groups"
  
  def index
    @training_requirement_groups = Vger::Resources::Suitability::TrainingRequirementGroup.where(:query_options => {  
                            company_id: @company.id
                          },
                          methods: [:total_candidates, :completed_candidates],
                          page: params[:page],
                          per: 10
                        ).all
  end
  
  def new
    @assessments = Vger::Resources::Suitability::Assessment.where(:query_options => { :company_id => @company.id }, select: ["name","id"], order: ["created_at DESC"]).all
    @training_requirement_groups = Vger::Resources::Suitability::Assessment.where(:query_options => { :company_id => @company.id }, select: ["name","id"], order: ["created_at DESC"]).all
  end
  
  def create
    @training_requirement_groups = Vger::Resources::Suitability::Assessment.where(:query_options => { :company_id => @company.id }, select: ["name","id"]).all
    params[:training_requirement][:assessment_hash].reject!{|training_requirement_group_id, training_requirement_group_data| training_requirement_group_data["enabled"] != "true" }
    if @training_requirement_group.assessment_hash.present? && @training_requirement_group.save
      redirect_to company_training_requirement_group_path(@company, @training_requirement_group)
    else
      @training_requirement_group.error_messages ||= []
      @training_requirement_group.error_messages << "Please select at least one training_requirement_group." if !@training_requirement_group.assessment_hash.present?
      flash[:error] = @training_requirement_group.error_messages.join("<br/>")
      render :action => :new
    end
  end
  
  def show
  end
  
  def training_requirements
    @training_requirement_group_report = Vger::Resources::Suitability::AssessmentGroupReport.where(
                            :query_options => {
                              :assessment_group_id => @training_requirement_group.id,
                              :report_type   => Vger::Resources::Suitability::AssessmentGroup::ReportType::TRAINING_REQUIREMENT,
                              :status        => Vger::Resources::Suitability::AssessmentGroupReport::Status::UPLOADED,
                            }
                          ).all.first
    @report_data = @training_requirement_group_report.report_data if @training_requirement_group_report
    respond_to do |format|
      format.html
    end
  end
  
  def download_report
    if request.format.to_s == "application/pdf"
      type = "pdf"
    else
      type = "html"
    end  
    @training_requirement_group_report = Vger::Resources::Suitability::AssessmentGroupReport.where(
                            :query_options => {
                              :assessment_group_id => @training_requirement_group.id,
                              :report_type   => Vger::Resources::Suitability::AssessmentGroup::ReportType::TRAINING_REQUIREMENT,
                              :status        => Vger::Resources::Suitability::AssessmentGroupReport::Status::UPLOADED,
                            }
                          ).all.first
    if @training_requirement_group_report && @training_requirement_group_report.report_data.present?                      
      url = S3Utils.get_url(@training_requirement_group_report.send("#{type}_bucket"),@training_requirement_group_report.send("#{type}_key"));
      redirect_to url
    else
      redirect_to training_requirements_company_training_requirement_group_path(:company_id => params[:company_id], :id => params[:id])   
    end
  end 
  
  def training_requirements_report
    @training_requirement_group_report = Vger::Resources::Suitability::AssessmentGroupReport.where(
                            :query_options => {
                              :assessment_group_id => @training_requirement_group.id,
                              :report_type   => Vger::Resources::Suitability::AssessmentGroup::ReportType::TRAINING_REQUIREMENT,
                              :status        => Vger::Resources::Suitability::AssessmentGroupReport::Status::UPLOADED,
                            }
                          ).all.first
    if !@training_requirement_group_report
      redirect_to company_training_requirement_group_path(:company_id => params[:company_id], :id => params[:id]), alert: "Training Requirement Report not found!"
      return
    end
    @report_data = @training_requirement_group_report.report_data
    if request.format == "application/pdf"
      @view_mode = "pdf"
    else  
      @view_mode = "html"
    end
    respond_to do |format|
      format.html { 
        render template: "assessment_group_reports/training_requirements_report",
               layout: "reports"
      }
      format.pdf { 
        render pdf: "training_requirements_report_#{params[:id]}.pdf",
        footer: {
          :html => {
            template: "shared/reports/_report_footer.html.haml"
          }
        },           
        template: "assessment_group_reports/training_requirements_report.html.haml", 
        layout: "layouts/reports.html.haml", 
        handlers: [ :haml ], 
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        formats: [:html],
        locals: { :@view_mode => "pdf" }
      }
    end
  end
  
  protected
  
  def get_training_requirement_group
    if params[:id].present?
      @training_requirement_group = Vger::Resources::Suitability::TrainingRequirementGroup.find(params[:id], methods: [:total_candidates, :completed_candidates ])  
    else
      params[:training_requirement] ||= {}
      params[:training_requirement][:company_id] = params[:company_id]
      @training_requirement_group = Vger::Resources::Suitability::TrainingRequirementGroup.new(params[:training_requirement])
    end
  end
  
  def get_company
    methods = []
    @company = Vger::Resources::Company.find(params[:company_id], :methods => methods)
  end
end
