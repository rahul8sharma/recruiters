class Suitability::FactorScoreRatingsController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::FactorScoreRating
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :uid, :name, :min_val, :max_val, :color, :company_id]
  end
end
