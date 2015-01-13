class SocialRecognition::LeadPointsController < MasterDataController
  def api_resource
    Vger::Resources::SocialRecognition::LeadPoint
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [
      :id,
      :unit_size,
      :value_per_unit,
      :currency,
      :company_id,
      :uid
    ]
  end

end
