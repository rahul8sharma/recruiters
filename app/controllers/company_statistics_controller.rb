class CompanyStatisticsController < ApplicationController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Company
  end

  layout "companies"

  before_filter :get_company

  def statistics
  end
  
  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:id], :methods => [ :subscription, :assessment_statistics ])
  end
end

