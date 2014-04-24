class Suitability::CustomAssessments::TrainingRequirementsReportsController < Suitability::CustomAssessmentsController
  def training_requirements
    @assessment.report_types ||= []
    @assessment_report = Vger::Resources::Suitability::AssessmentReport.where(
                            :query_options => {
                              :assessment_id => @assessment.id,
                              :report_type   => Vger::Resources::Suitability::CustomAssessment::ReportType::TRAINING_REQUIREMENT,
                              :status        => Vger::Resources::Suitability::AssessmentReport::Status::UPLOADED,
                            }
                          ).all.first
    @report_data = @assessment_report.report_data if @assessment_report
    respond_to do |format|
      format.html
    end
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
    @assessment_report = Vger::Resources::Suitability::AssessmentReport.where(
                            :query_options => {
                              :assessment_id => @assessment.id,
                              :report_type   => Vger::Resources::Suitability::CustomAssessment::ReportType::TRAINING_REQUIREMENT,
                              :status        => Vger::Resources::Suitability::AssessmentReport::Status::UPLOADED,
                            }
                          ).all.first
    if @assessment_report && @assessment_report.report_data.present?                      
      url = S3Utils.get_url(@assessment_report.send("#{type}_bucket"),@assessment_report.send("#{type}_key"));
      redirect_to url
    else
      redirect_to training_requirements_company_assessment_path(:company_id => params[:company_id], :id => params[:id])   
    end
  end 
end
