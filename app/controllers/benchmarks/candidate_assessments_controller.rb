class Benchmarks::CandidateAssessmentsController < Assessments::CandidateAssessmentsController
  private
  
  def candidates_url
    candidates_company_benchmark_path(:company_id => params[:company_id], :id => params[:id])
  end
  
  def add_candidates_url
    add_candidates_company_benchmark_path(:company_id => params[:company_id], :id => params[:id])
  end
end
