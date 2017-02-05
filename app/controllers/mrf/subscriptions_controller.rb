class Mrf::SubscriptionsController < SubscriptionsController
  def api_resource
    Vger::Resources::Mrf::Subscription
  end
  
  def invitation_klass
    Vger::Resources::Mrf::Invitation
  end
  
  def redirect_path
    manage_mrf_subscriptions_path
  end
end
