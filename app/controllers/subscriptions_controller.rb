class SubscriptionsController < MasterDataController
  def api_resource
    Vger::Resources::Subscription
  end
  
  def import_from
    "import_from_google_drive"
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
end
