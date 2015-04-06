class CompanyStatisticsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:id]) }

  layout "companies"

  before_filter :get_company

  def statistics
  end

  def email_usage_stats
     options = {
      :company_usage_stats => {
        :job_klass => "CompanyUsageStatsExporter",
        :args => {
          :user_id => current_user.id,
          :company_id => @company.id
        }
      }
    }
    Vger::Resources::Company.find(params[:id])\
      .export_usage_stats(options)
    redirect_to request.env['HTTP_REFERER'], notice: "Overall Usage Summary will be generated and emailed to #{current_user.email}."
  end

  protected

  def get_company
    methods = [:unlocked_invites_count,:recent_usage_statistics]
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

