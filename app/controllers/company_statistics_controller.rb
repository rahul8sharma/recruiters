class CompanyStatisticsController < ApplicationController
  before_filter :authenticate_user!

  layout "companies"

  before_filter :get_company

  def statistics
  end
  
  protected

  def get_company
    methods = []
    if Rails.application.config.statistics[:load_assessment_statistics]
      methods.push :assessment_statistics
    end  
    @company = Vger::Resources::Company.find(params[:id], :include => [:subscription], :methods => methods)
    @company.assessment_statistics ||= {}
  end
end

