class Mrf::SubscriptionsController < MasterDataController
  skip_before_filter :authenticate_user!
  def api_resource
    Vger::Resources::Mrf::Subscription
  end

  def import_from
    "import_from_google_drive"
  end
  
  # Expires a subscription prematurely
  # Sets status of all invitations under a subscription to 'expired'
  def expire_subscription
    if params[:subscription_id].blank?  
      flash[:error] = "Please provide a valid Subscription ID."
      redirect_to manage_mrf_subscriptions_path and return
    end
    now = Time.now
    subscription = Vger::Resources::Mrf::Subscription.save_existing(params[:subscription_id], :valid_to => now)
    if subscription.error_messages.present?
      flash[:error] = subscription.error_messages.join("<br/>").html_safe
      redirect_to manage_mrf_subscriptions_path
    else
      Vger::Resources::Mrf::Invitation.update_all(
        :query_options => { 
          :company_id => params[:company_id],
          :subscription_id => params[:subscription_id], 
          :status => Vger::Resources::Mrf::Invitation::Status::UNLOCKED 
        }, 
        :update_attributes => { 
          :status => Vger::Resources::Mrf::Invitation::Status::EXPIRED, 
          :expiry => now
        }
      )
      flash[:notice] = "360 Subscription with id '#{params[:subscription_id]}' expired successfully."
      redirect_to manage_mrf_subscriptions_path
    end
  end

  def index_columns
    [
      :id,
      :company_id,
      :assessments_purchased,
      :valid_from,
      :valid_to
    ]
  end
  
  def search_columns
    [
      :id,
      :assessments_purchased,
      :company_id
    ]
  end
end
