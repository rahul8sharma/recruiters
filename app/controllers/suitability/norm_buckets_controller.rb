class Suitability::NormBucketsController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::NormBucket
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :uid, :name, :weight]
  end
end
