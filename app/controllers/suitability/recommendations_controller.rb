class Suitability::RecommendationsController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::Recommendation
  end
  
  def index_columns
    [:id, :uid, :body]
  end
  
  def import_from
    "import_from_google_drive"
  end
end
