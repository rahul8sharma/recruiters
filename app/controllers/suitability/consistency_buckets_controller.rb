class Suitability::ConsistencyBucketsController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::ConsistencyBucket
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :uid, :name, :min_val, :max_val]
  end
end
