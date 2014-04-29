class Suitability::BenchmarksController < Suitability::CustomAssessmentsController
  # GET /assessments
  def index
    @assessments = Vger::Resources::Suitability::CustomAssessment.where(
      :query_options => { 
        :company_id => params[:company_id], 
        :assessment_type => [Vger::Resources::Suitability::CustomAssessment::AssessmentType::BENCHMARK] 
      }, 
      :order => "created_at DESC", 
      :page => params[:page], 
      :per => 10
    )
  end
  
  def download_benchmark_report
    if request.format.to_s == "application/pdf"
      type = "pdf"
    else
      type = "html"
    end  
    @assessment_report = Vger::Resources::Suitability::AssessmentReport.where(
                            :query_options => {
                              :assessment_id => params[:id],
                              :report_type   => Vger::Resources::Suitability::CustomAssessment::ReportType::BENCHMARK,
                              :status        => Vger::Resources::Suitability::AssessmentReport::Status::UPLOADED
                            }
                          ).all.first
    if @assessment_report && @assessment_report.report_data.present?
      url = S3Utils.get_url(@assessment_report.send("#{type}_bucket"),@assessment_report.send("#{type}_key"));
      redirect_to url
    else
      redirect_to company_benchmark_path(:company_id => params[:company_id], :id => params[:id]), alert: "Benchmark report is not ready yet."
    end
  end 
  
  def show
    @assessment_report = Vger::Resources::Suitability::AssessmentReport.where(
                            :query_options => {
                              :assessment_id => params[:id],
                              :report_type   => Vger::Resources::Suitability::CustomAssessment::ReportType::BENCHMARK,
                              :status        => Vger::Resources::Suitability::AssessmentReport::Status::UPLOADED
                            }
                          ).all.first
    @norm_buckets = Vger::Resources::Suitability::NormBucket.all
  end
end
