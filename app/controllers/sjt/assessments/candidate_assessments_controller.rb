class Sjt::Assessments::CandidateAssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company

  layout 'sjt/sjt'

  def candidates
  end
  

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end


end