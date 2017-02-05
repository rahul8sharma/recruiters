class Oac::SubscriptionsController < SubscriptionsController
  def api_resource
    Vger::Resources::Oac::Subscription
  end
  
  def invitation_klass
    Vger::Resources::Oac::Invitation
  end
  
  def redirect_path
    manage_oac_subscriptions_path
  end
end
