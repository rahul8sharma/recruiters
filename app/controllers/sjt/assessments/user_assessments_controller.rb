class Sjt::Assessments::UserAssessmentsController < Suitability::CustomAssessments::UserAssessmentsController
  layout 'sjt/sjt'

  private

  def extend_validity_url
    extend_validity_company_sjt_assessment_path(:company_id => params[:company_id],:id => params[:id],:user_id => params[:user_id])
  end
  
  def add_users_bulk_url
    add_users_bulk_company_sjt_assessment_url(company_id: @company.id,id: @assessment.id)
  end

  def competencies_url
    competencies_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end
  
  def send_reminder_to_user_url(user,user_assessment)
    send_reminder_to_user_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id], :user_id => user.id, :user_assessment_id => user_assessment.id)
  end

  def users_url
    users_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def reports_url
    reports_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def user_url(user)
    user_company_sjt_assessment_path(params[:company_id], params[:id], :user_id => user.id)
  end

  def send_test_to_users_path
    send_test_to_users_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def bulk_send_test_to_users_path
    bulk_send_test_to_users_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])   
  end

  def new_assessment_url
    new_company_sjt_assessment_path(params[:company_id])
  end

  def add_users_url
    add_users_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def expire_links_url
    expire_links_company_sjt_assessment_path(params[:company_id], params[:id])
  end

  def email_assessment_status_url
    email_assessment_status_company_sjt_assessment_path(params[:company_id], params[:id])
  end

  def resend_invitations_url
    resend_invitations_company_sjt_assessment_path(params[:company_id],params[:id])
  end

  def trigger_report_downloader_url
    trigger_report_downloader_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def export_feedback_scores_url
    export_feedback_scores_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end
end
