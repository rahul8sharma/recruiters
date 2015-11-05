class Sjt::Assessments::CandidateAssessmentsController < Suitability::CustomAssessments::CandidateAssessmentsController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company

  layout 'sjt/sjt'

  def candidate
  end
  
  def candidates
  end

  def competencies_measured
  end

  def reports
  end

  def add_candidates_bulk_url
    add_candidates_bulk_company_sjt_assessment_url(company_id: @company.id,id: @assessment.id)
  end

  def competencies_url
    competencies_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def candidates_url
    candidates_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end


end