class Oac::Assessments::UserAssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:company_id]) }
  before_filter :get_company
  layout 'oac/oac'

  def candidates
  end

  def candidate
    
  end

  def add_candidates
  end

  def bulk_upload_candidates
  end

  def assign_assessors
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

end