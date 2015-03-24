class Suitability::CustomAssessments::TrainingRequirementsReportsController < ApplicationController
  layout "tests"
  
  before_filter :authenticate_user!, :except => [:download_report]
  before_filter :get_assessment, :except => [:download_report]
  before_filter :get_company, :except => [:download_report]
  
  def training_requirements
    @assessment_report = Vger::Resources::Suitability::AssessmentReport.where(
                            :query_options => {
                              :assessment_id => @assessment.id,
                              :report_type   => Vger::Resources::Suitability::CustomAssessment::ReportType::TRAINING_REQUIREMENT
                            }
                          ).all.first
    @assessment_report = Vger::Resources::Suitability::AssessmentReport.new if !@assessment_report                          
    @report_data = @assessment_report.report_data if @assessment_report
  end
  
  def create
    @assessment_report = Vger::Resources::Suitability::AssessmentReport.new(params[:assessment_report])
    report_types = (@assessment.report_types + [Vger::Resources::Assessment::ReportType::TRAINING_REQUIREMENT]).compact.flatten.uniq
    @assessment = Vger::Resources::Suitability::CustomAssessment.save_existing(@assessment.id, report_types: report_types)
    if @assessment_report.save && @assessment.error_messages.empty?
      flash[:notice] = "Training Requirements report created for this assessment."
    else
      flash[:error] = (@assessment_report.error_messages + @assessment.error_messages).join("<br/>").html_safe
    end  
    redirect_to training_requirements_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end
  
  def update
    @assessment_report = Vger::Resources::Suitability::AssessmentReport.save_existing(params[:assessment_report_id], params[:assessment_report])
    if @assessment_report.error_messages.present?
      flash[:error] = @assessment_report.error_messages.join("<br/>").html_safe
    else
      flash[:notice] = "Training Requirements report updated successfully."
    end
    redirect_to training_requirements_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end
  
  def enable_training_requirements_report
    @assessment.report_types ||= []
    @assessment.report_types << Vger::Resources::Suitability::CustomAssessment::ReportType::TRAINING_REQUIREMENT
    @assessment.report_types.uniq!
    respond_to do |format|
      if Vger::Resources::Suitability::CustomAssessment.save_existing(@assessment.id, { report_types: @assessment.report_types })
        format.html { redirect_to training_requirements_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id]) }
      else
        format.html { redirect_to training_requirements_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id]), alert: "Could not enable training requirements report. Please try again." }
      end
    end
  end
  
  def download_report
    if request.format.to_s == "application/pdf"
      type = "pdf"
    else
      type = "html"
    end  
    @report = Vger::Resources::Suitability::AssessmentReport.where(
                            :query_options => {
                              :assessment_id => params[:id],
                              :report_type   => Vger::Resources::Suitability::CustomAssessment::ReportType::TRAINING_REQUIREMENT
                            }
                          ).all.first
    if @report.send("#{type}_bucket").present? && @report.send("#{type}_key").present?
      url = S3Utils.get_url(@report.send("#{type}_bucket"),@report.send("#{type}_key"));
      redirect_to url
    else
      redirect_to training_requirements_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])   
    end
  end 
  
  protected
  
  def get_company
    methods = []
    if ["show","index", "training_requirements"].include? params[:action]
      if Rails.application.config.statistics[:load_assessmentwise_statistics]
        methods << :assessmentwise_statistics
      end
    end
    @company = Vger::Resources::Company.find(params[:company_id], :methods => methods)
  end
  
  def get_assessment
    @assessment = Vger::Resources::Suitability::CustomAssessment.find(params[:id], :include => [:functional_area, :industry, :job_experience], :methods => [:competency_ids])
    if(@assessment.company_id.to_i == params[:company_id].to_i)
    else
      redirect_to root_path, error: "Page you are looking for doesn't exist."
    end
  end
end
