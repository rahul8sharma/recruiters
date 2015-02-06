class SocialRecognition::BehaviorsController < MasterDataController
  def api_resource
    Vger::Resources::SocialRecognition::Behavior
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [
      :id,
      :name,
      :active,
      :uid
    ]
  end

end
