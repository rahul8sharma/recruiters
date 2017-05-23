class TrainingRequirementGroupsController < ApplicationController
  before_filter :authenticate_user!, except: [:download_report]
  before_filter(except: [:download_report])  { authorize_user!(params[:company_id]) }
  before_filter :get_company, except: [:download_report]
  before_filter :get_training_requirement_group, :except => [:index]
  
  layout "training_requirement_groups"
  
  def index
    @training_requirement_groups = Vger::Resources::Suitability::TrainingRequirementGroup.where(:query_options => {  
                            company_id: @company.id
                          },
                          methods: [:total_users, :completed_users],
                          page: params[:page],
                          per: 10,
                          order: ["created_at DESC"]
                        ).all
  end
  
  def new
  end
  
  def customize
    @assessments = Vger::Resources::Suitability::CustomAssessment.where(:query_options => { :company_id => @company.id, id: @training_requirement_group.assessment_hash.keys }, select: ["name","id","assessment_type"], order: ["created_at DESC"]).all
    if request.put?
      @training_requirement_group_report = Vger::Resources::Suitability::AssessmentGroupReport.save_existing(params[:assessment_report_id], params[:assessment_group_report])
      if @training_requirement_group_report.error_messages.empty?
        flash[:notice] = "Training Requirement updated successfully."
        redirect_to training_requirements_company_training_requirement_group_path(:company_id => params[:company_id], :id => params[:id])   
      else
        flash[:error] = @training_requirement_group_report.error_messages.join("<br/>").html_safe
        render action: :customize
      end
    else
      @training_requirement_group_report = Vger::Resources::Suitability::AssessmentGroupReport.where(
                            :query_options => {
                              :assessment_group_id => @training_requirement_group.id,
                              :report_type   => Vger::Resources::Suitability::AssessmentGroup::ReportType::TRAINING_REQUIREMENT
                            }
                          ).all.first
    end                      
  end
  
  def create
    params[:training_requirement][:assessment_hash].reject!{|training_requirement_group_id, training_requirement_group_data| training_requirement_group_data["enabled"] != "true" }
    if @training_requirement_group.assessment_hash.present? && @training_requirement_group.save
      redirect_to customize_company_training_requirement_group_path(:company_id => params[:company_id], :id => @training_requirement_group.id)
    else
      @training_requirement_group.error_messages ||= []
      @training_requirement_group.error_messages << "Please select at least one assessment." if !@training_requirement_group.assessment_hash.present?
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
    @report = Vger::Resources::Suitability::AssessmentGroupReport.where(
                            :query_options => {
                              :assessment_group_id => @training_requirement_group.id,
                              :report_type   => Vger::Resources::Suitability::AssessmentGroup::ReportType::TRAINING_REQUIREMENT
                            }
                          ).all.first
    if @report.send("#{type}_bucket").present? && @report.send("#{type}_key").present?
      url = S3Utils.get_url(@report.send("#{type}_bucket"),@report.send("#{type}_key"));
      redirect_to url
    else
      redirect_to training_requirements_company_training_requirement_group_path(:company_id => params[:company_id], :id => params[:id])   
    end
  end 
  
  def training_requirements_report
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(order: "weight ASC").all.to_a  
    @report = Vger::Resources::Suitability::AssessmentGroupReport.where(
                            :query_options => {
                              :assessment_group_id => @training_requirement_group.id,
                              :report_type   => Vger::Resources::Suitability::AssessmentGroup::ReportType::TRAINING_REQUIREMENT
                            }
                          ).all.first
    if !@report.report_data
      redirect_to company_training_requirement_group_path(:company_id => params[:company_id], :id => params[:id]), alert: "Training Requirement Report not found!"
      return
    end
    @report_data = @report.report_data
    @report_data["company_id"] = @training_requirement_group.company_id
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
    template = @view_mode == "pdf"  ? "training_requirements_report.pdf.haml" : "training_requirements_report.html.haml"
    respond_to do |format|
      format.html { 
        render template: "assessment_group_reports/#{template}",
               layout: "#{template}",
               formats: [:pdf, :html]
      }
      format.pdf { 
        render pdf: "training_requirements_report_#{params[:id]}.pdf",
        footer: {
          :html => {
            template: "shared/reports/pdf/_report_footer.pdf.haml"
          }
        },
        
        template: "assessment_group_reports/training_requirements_report.pdf.haml", 
        layout: "layouts/training_requirements_report.pdf.haml", 
        handlers: [ :haml ], 
        margin: { :left => 0,:right => 0, :top => 0, :bottom => 8 },
        formats: [:pdf],
        locals: { :@view_mode => "pdf" }
      }
    end
  end
  
  protected
  
  def get_training_requirement_group
    if params[:id].present?
      @training_requirement_group = Vger::Resources::Suitability::TrainingRequirementGroup.find(params[:id], methods: [:total_users, :completed_users ])  
    else
      params[:training_requirement] ||= {}
      params[:training_requirement][:company_id] = params[:company_id]
      @training_requirement_group = Vger::Resources::Suitability::TrainingRequirementGroup.new(params[:training_requirement])
      @assessments = Vger::Resources::Suitability::CustomAssessment.where(:query_options => { :company_id => @company.id }, select: ["name","id"], order: ["created_at DESC"]).all
    end
  end
  
  def get_company
    methods = []
    @company = Vger::Resources::Company.find(params[:company_id], :methods => methods)
  end
end
