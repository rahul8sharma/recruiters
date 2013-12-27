class Suitability::FitsController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::Fit
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :uid, :name, :factor_ids]
  end
end
