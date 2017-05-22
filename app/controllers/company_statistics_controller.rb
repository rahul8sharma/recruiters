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
  
  def subscription_management
    @children = Vger::Resources::Company.where(
      query_options: {
        parent_id: @company.id
      },
      select: [:id, :name]
    ).all
    @subscriptions = Vger::Resources::Subscription.where(
      query_options: {
        parent_id: @company.id
      },
      select: [:id, :assessments_purchased, :valid_from, :valid_to]
    )
    @allocated_invitations = Vger::Resources::Invitation.group_count(
      query_options: {
        company_id: @children.map(&:id)
      },
      group: :company_id
    )
    @unallocated_invitations = Vger::Resources::Invitation.group_count(
      query_options: {
        company_id: @company.id
      },
      group: :subscription_id
    )
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
    @trial_plan = Vger::Resources::Plan.where(scopes: { trial_plan: nil }).first
    @vac_suitability_plan = Vger::Resources::Plan.where(scopes: { vac_suitability_plan: nil }).first
    @subscriptions = Vger::Resources::Subscription.where(
      :query_options => {
        :company_id => @company.id
      },
      :scopes => {
        plan_id_not_in: [@trial_plan.id.to_i, @vac_suitability_plan.id.to_i]
      },
      :order => ["valid_to DESC, id desc"],
      :methods => [
        :assessments_sent,
        :assessments_completed,
        :unlocked_invites_count
      ],
      :page => params[:page],
      :per => 5
    )
  end
  
  def get_360_subscriptions
    @trial_plan = Vger::Resources::Plan.where(scopes: { trial_plan: nil }).first
    @subscriptions = Vger::Resources::Mrf::Subscription.where(
      :query_options => {
        :company_id => @company.id
      },
      :order => ["valid_to DESC, id desc"],
      :scopes => {
        plan_id_not_in: [@trial_plan.id.to_i]
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
    @trial_plan = Vger::Resources::Plan.where(scopes: { trial_plan: nil }).first
    @subscriptions = Vger::Resources::Oac::Subscription.where(
      :query_options => {
        :company_id => @company.id
      },
      :order => ["valid_to DESC, id desc"],
      :scopes => {
        plan_id_not_in: [@trial_plan.id.to_i]
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

