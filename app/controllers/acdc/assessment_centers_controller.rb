class Acdc::AssessmentCentersController < ApplicationController
  before_action :authenticate_user!
  before_action { authorize_user!(params[:company_id]) }
  before_action :get_company

  layout 'companies'

  def home
  end

  def edit
  end

  def create
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end
end
