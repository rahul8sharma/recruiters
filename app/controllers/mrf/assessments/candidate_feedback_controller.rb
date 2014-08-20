class Mrf::Assessments::CandidateFeedbackController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_assessment

  layout 'mrf'

  def statistics
  end

  def stakeholders
  end

  def add_stakeholders
  end

  protected  
  
  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

  def get_assessment
    if params[:id].present?
      @assessment = Vger::Resources::Mrf::Assessment.find(params[:id], company_id: @company.id, :include => {:assessment_traits => { methods: [:trait] } })
    else
      @assessment = Vger::Resources::Mrf::Assessment.new
    end
  end

end
