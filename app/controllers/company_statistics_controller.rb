class CompanyStatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action { authorize_user!(params[:id]) }

  layout "companies"

  before_action :get_company

  def statistics
    get_subscriptions(Vger::Resources::Subscription)
  end
  
  def statistics_360
    get_subscriptions(Vger::Resources::Mrf::Subscription)
  end
  
  def statistics_vac
    get_subscriptions(Vger::Resources::Oac::Subscription)
  end
  
  def email_usage_stats
     options = {
      :company_usage_stats => {
        :job_klass => (@company.parent_id.blank? ? "MotherAccountUsageStatsExporter" : "CompanyUsageStatsExporter"),
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
    methods = [
      :unlocked_invites_count,
      :unlocked_360_invites_count,
      :unlocked_oac_invites_count,
      :recent_usage_statistics, 
      :assessment_statistics
    ]
    @company = Vger::Resources::Company.find(params[:id], :methods => methods)
  end
  
  def get_subscriptions(subscription_klass)
    @subscriptions = subscription_klass.where(
      :query_options => {
        :company_id => @company.id
      },
      :order => ["valid_to DESC, id desc"],
      :scopes => {
        no_trials: nil
      },
      :methods => [
        :assessments_sent,
        :assessments_completed,
        :unlocked_invites_count
      ],
      :page => params[:page],
      :per => 5
    )
  end
end

