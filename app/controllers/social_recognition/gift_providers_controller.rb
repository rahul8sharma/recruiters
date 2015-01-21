class SocialRecognition::GiftProvidersController < MasterDataController
  def api_resource
    Vger::Resources::SocialRecognition::GiftProvider
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [
      :id,
      :name,
      :uid
    ]
  end

end
