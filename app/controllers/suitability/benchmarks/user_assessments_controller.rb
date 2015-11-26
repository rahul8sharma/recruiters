class Suitability::Benchmarks::UserAssessmentsController < Suitability::CustomAssessments::UserAssessmentsController
  def send_reminder_to_user_url
    send_reminder_to_user_company_benchmark_path(:company_id => params[:company_id], :id => params[:id], :user_id => params[:user_id], :user_assessment_id => @user_assessment.id)
  end
  
  private
  
  def users_url
    users_company_benchmark_path(:company_id => params[:company_id], :id => params[:id])
  end
  
  def add_users_url
    add_users_company_benchmark_path(:company_id => params[:company_id], :id => params[:id])
  end
end
