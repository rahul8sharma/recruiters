class Companies::SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:id]) }

  layout "companies"

  before_filter :get_company
  
  def api_resource
    Vger::Resources::Company
  end

  def manage
    status = Vger::Resources::Invitation::Status
    @children = api_resource.where(
      query_options: {
        parent_id: @company.id
      },
      select: [:id, :name],
      page: params[:page] || 1,
      per: 10
    ).all
    @assigned_invitation_counts = Vger::Resources::Invitation.group_count(
      query_options: {
        company_id: @children.map(&:id)
      },
      group: :company_id
    )
    @used_invitation_counts = Vger::Resources::Invitation.group_count(
      query_options: {
        company_id: @children.map(&:id),
        status: [status::LOCKED, status::USED, status::EXPIRED]
      },
      group: :company_id
    )
    @unassigned_invitations_count = Vger::Resources::Invitation.count(
      query_options: {
        company_id: @company.id,
        status: [status::UNLOCKED]
      }
    )
    @unused_invitations_count = Vger::Resources::Invitation.count(
      query_options: {
        company_id: @children.map(&:id),
        status: [status::UNLOCKED]
      }
    )
  end
  
  def assign
    @child = api_resource.find(params[:child_id], :methods => [])
    if request.post?
      @child = api_resource.new(@child.assign_invitations(params.merge({
        methods: [:error_messages]
      }))[:company])
      if @child.error_messages.present?
        flash[:error] = @child.error_messages.join("<br/>").html_safe
        render :assign
      else
        flash[:notice] = "#{params[:no_of_invitations]} successfully assigned to Account #{@child.id}"
        redirect_to manage_subscriptions_company_path(@company.id)
      end
    else
    end  
  end
  
  def revoke
    @child = api_resource.find(params[:child_id], :methods => [])
    if request.post?
      @child = api_resource.new(@child.revoke_invitations(params.merge({
        methods: [:error_messages]
      }))[:company])
      if @child.error_messages.present?
        flash[:error] = @child.error_messages.join("<br/>").html_safe
        render :assign
      else
        flash[:notice] = "#{params[:no_of_invitations]} successfully revoked from Account #{@child.id}"
        redirect_to manage_subscriptions_company_path(@company.id)
      end
    else
    end
  end

  protected

  def get_company
    methods = []
    @company = api_resource.find(params[:id], :methods => methods)
  end
end

