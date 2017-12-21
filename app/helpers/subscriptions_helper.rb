module SubscriptionsHelper
  def free_plan
    trial_plan = Vger::Resources::Plan.where(
      scopes: [:free_plan]
    ).first
  end
  
  def subscription_type_options
    {
      "Invoice" => nil,
      "Free" => free_plan.id
    }
  end
end
