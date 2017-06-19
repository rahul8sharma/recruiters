class Companies::SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:id]) }

  layout "companies"

  before_filter :get_company
  
  def api_resource
    Vger::Resources::Company
  end

  def manage
    if @company.parent_id.present?
      flash[:error] = "You are not allowed to access this page."
      redirect_to company_path(@company.id)
    end
    get_suitability_subscriptions
    status = Vger::Resources::Invitation::Status
    @children = api_resource.where(
      query_options: {
        parent_id: @company.id
      },
      select: [:id, :name],
      order: "id desc"
    ).all
    @children.unshift(@company)
    @assigned_invitation_counts = Vger::Resources::Invitation.group_count(
      query_options: {
        "invitations.company_id" => @children.map(&:id)
      },
      scopes: {
        no_trials: nil
      },
      group: "invitations.company_id"
    )
    @used_invitation_counts = Vger::Resources::Invitation.group_count(
      query_options: {
        "invitations.company_id" => @children.map(&:id),
        status: [status::LOCKED, status::USED]
      },
      scopes: {
        no_trials: nil
      },
      group: "invitations.company_id"
    )
    @completed_assessment_counts = Vger::Resources::Invitation.group_count(
      query_options: {
        "invitations.company_id" => @children.map(&:id),
        status: [status::USED]
      },
      scopes: {
        no_trials: nil
      },
      group: "invitations.company_id"
    )
    @unused_assessment_counts = Vger::Resources::Invitation.group_count(
      query_options: {
        "invitations.company_id" => @children.map(&:id),
        status: [status::UNLOCKED]
      },
      scopes: {
        no_trials: nil
      },
      group: "invitations.company_id"
    )
    
    
    @unused_invitations_count = Vger::Resources::Invitation.count(
      query_options: {
        "invitations.company_id" => @children.map(&:id),
        status: [status::UNLOCKED]
      },
      scopes: {
        no_trials: nil
      }
    )
  end
  
  def assign
    @child = api_resource.find(params[:child_id], 
      methods: [], 
      select: [:id, :name]
    )
    if request.post?
      if params[:no_of_invitations].to_i == 0
        flash[:error] = "Please enter subscriptions to add"
        render :assign and return
      end
      @child = api_resource.new(@child.assign_invitations(params.merge({
        methods: [:error_messages]
      }))[:company])
      if @child.error_messages.present?
        flash[:error] = @child.error_messages.join("<br/>").html_safe
        render :assign
      else
        flash[:notice] = "#{params[:no_of_invitations]} subscriptions successfully added to Account #{@child.id}"
        redirect_to manage_subscriptions_company_path(@company.id)
      end
    else
    end  
  end
  
  def revoke
    methods = [
      :assigned_invitations_count,
      :used_invitations_count,
      :unused_invitations_count
    ]
    @child = api_resource.find(params[:child_id],
      methods: methods, 
      select: [:id, :name]
    )
    if request.post?
      if params[:no_of_invitations].to_i == 0
        flash[:error] = "Please enter subscriptions to remove"
        render :revoke and return
      end
      @child = api_resource.new(@child.revoke_invitations(params.merge({
        methods: methods+[:error_messages]
      }))[:company])
      if @child.error_messages.present?
        flash[:error] = @child.error_messages.join("<br/>").html_safe
        render :revoke
      else
        flash[:notice] = "#{params[:no_of_invitations]} subscriptions successfully removed from Account #{@child.id}"
        redirect_to manage_subscriptions_company_path(@company.id)
      end
    else
    end
  end

  protected

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

  def get_company
    methods = [
      :unassigned_invitations_count
    ]
    @company = api_resource.find(params[:id], :methods => methods)
  end
end

