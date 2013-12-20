class BenchmarksController < AssessmentsController
  # GET /assessments
  def index
    @assessments = Vger::Resources::Suitability::Assessment.where(
      :query_options => { 
        :assessable_id => params[:company_id], 
        :assessable_type => "Company", 
        :assessment_type => [Vger::Resources::Suitability::Assessment::AssessmentType::BENCHMARK] 
      }, 
      :order => "created_at DESC", 
      :page => params[:page], 
      :per => 15
    )
  end
  
  def report
    if request.format.to_s == "application/pdf"
      type = "pdf"
    else
      type = "html"
    end  
    redirect_to @assessment.report_urls["benchmark"][type]
  end 
  
  def show
    @assessment = Vger::Resources::Suitability::Assessment.find(params[:id], :include => [:functional_area, :industry, :job_experience], methods: [ :benchmark_report ])
    @norm_buckets = Vger::Resources::Suitability::NormBucket.all
  end
end
