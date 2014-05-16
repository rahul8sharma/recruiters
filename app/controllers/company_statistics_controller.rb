class CompanyStatisticsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:id]) }

  layout "companies"

  before_filter :get_company

  def statistics
  end
  
  protected

  def get_company
    methods = [:unlocked_invites_count]
    if Rails.application.config.statistics[:load_assessment_statistics]
      methods.push :assessment_statistics
    end  
    @company = Vger::Resources::Company.find(params[:id], :methods => methods)
    @company.assessment_statistics ||= {}
    @subscriptions = Vger::Resources::Subscription.where(
      :query_options => { 
        :company_id => @company.id 
      }, 
      :order => ["valid_to DESC"],
      :methods => [:assessments_sent,:assessments_completed],
      :page => params[:page], 
      :per => 5
    )
  end
end

