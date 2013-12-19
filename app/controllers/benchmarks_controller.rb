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
    url = S3Utils.get_url("#{Rails.env.to_s}_benchmark_reports", "benchmark_report_assessment_#{params[:id]}.#{type}")
    redirect_to url 
  end 
  
  def show
    @norm_buckets = Vger::Resources::Suitability::NormBucket.all.to_a
    @factor_benchmarks = Vger::Resources::Suitability::FactorBenchmark.where(assessment_id: params[:id], :methods => [:factor_name, :factor_definition, :norm_bucket_name]).all.to_a.group_by{|factor_benchmark| factor_benchmark.factor_id }
    colors = ["#a2c7f4","#8eb4e3","#366092","#17355d", "#102540"]
    @factor_benchmark_percentages = Hash[
      @factor_benchmarks.map do |factor_id, factor_benchmarks|
        factor_benchmarks = factor_benchmarks\
                                          .sort_by{|factor_benchmark| factor_benchmark.score_percentage }
        scores = Hash[
          @norm_buckets.map do |norm_bucket|
            score = factor_benchmarks\
                    .find{|factor_benchmark| factor_benchmark.norm_bucket_id == norm_bucket.id }\
                    .score_percentage rescue 0
            color = colors[factor_benchmarks.map(&:score_percentage).sort.index(score).to_i]
            [norm_bucket.name, [score,color]]
          end
        ]
        [factor_id,scores.to_json]
      end
    ]
  end
end
