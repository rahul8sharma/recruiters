class CompanyStatisticsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:id]) }

  layout "companies"

  before_filter :get_company

  def statistics
    get_suitability_subscriptions
  end
  
  def statistics_360
    get_360_subscriptions
  end
  
  def statistics_vac
    get_vac_subscriptions
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
  
  def get_suitability_subscriptions
    @subscriptions = Vger::Resources::Subscription.where(
      query_options: {
        company_id: @company.id
      },
      scopes: {
        no_trials: nil
      },
      order: ["valid_to DESC, id desc"],
      page: params[:page],
      per: 5
    )
    status = Vger::Resources::Invitation::Status
    @invitation_counts = Vger::Resources::Invitation.group_count(
      query_options: {
        company_id: @company.id
      },
      scopes: {
        no_trials: nil
      },
      group: :subscription_id
    )
    @unlocked_invitation_counts = Vger::Resources::Invitation.group_count(
      query_options: {
        subscription_id: @subscriptions.map(&:id),
        status: [status::UNLOCKED]
      },
      scopes: {
        no_trials: nil
      },
      group: :subscription_id
    )
    @sent_invitation_counts = Vger::Resources::Invitation.group_count(
      query_options: {
        subscription_id: @subscriptions.map(&:id),
        status: [status::LOCKED,status::USED]
      },
      scopes: {
        no_trials: nil
      },
      group: :subscription_id
    )
    @completed_invitation_counts = Vger::Resources::Invitation.group_count(
      query_options: {
        subscription_id: @subscriptions.map(&:id),
        status: status::USED
      },
      scopes: {
        no_trials: nil
      },
      group: :subscription_id
    )
  end
  
  def get_360_subscriptions
    @subscriptions = Vger::Resources::Mrf::Subscription.where(
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
  
  def get_vac_subscriptions
    @subscriptions = Vger::Resources::Oac::Subscription.where(
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

