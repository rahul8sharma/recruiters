class Benchmarks::CandidateAssessmentsController < Assessments::CandidateAssessmentsController
  def send_reminder_to_candidate_url
    send_reminder_to_candidate_company_benchmark_path(:company_id => params[:company_id], :id => params[:id], :candidate_id => params[:candidate_id], :candidate_assessment_id => @candidate_assessment.id)
  end
  
  private
  
  def candidates_url
    candidates_company_benchmark_path(:company_id => params[:company_id], :id => params[:id])
  end
  
  def add_candidates_url
    add_candidates_company_benchmark_path(:company_id => params[:company_id], :id => params[:id])
  end
end
