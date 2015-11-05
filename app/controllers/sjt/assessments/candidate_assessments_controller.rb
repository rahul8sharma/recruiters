class Sjt::Assessments::CandidateAssessmentsController < Suitability::CustomAssessments::CandidateAssessmentsController
  layout 'sjt/sjt'

  helper_method :add_candidates_bulk_url, 
                :competencies_url, 
                :send_reminder_to_candidate_url, 
                :candidates_url, 
                :candidate_url,
                :add_candidates_url, 
                :reports_url, 
                :send_test_to_candidates_path, 
                :bulk_send_test_to_candidates_path, 
                :new_assessment_url, 
                :expire_links_url, 
                :email_assessment_status_url, 
                :resend_invitations_url
    
  

  private

  def add_candidates_bulk_url
    add_candidates_bulk_company_sjt_assessment_url(company_id: @company.id,id: @assessment.id)
  end

  def competencies_url
    competencies_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def candidates_url
    candidates_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def candidate_url(candidate)
    candidate_company_sjt_assessment_path(params[:company_id], params[:id], :candidate_id => candidate.id)
  end

  def send_test_to_candidates_path
    send_test_to_candidates_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def bulk_send_test_to_candidates_path
    bulk_send_test_to_candidates_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])   
  end

  def new_assessment_url
    new_company_sjt_assessment_path(params[:company_id])
  end

  def add_candidates_url
    add_candidates_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
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
end