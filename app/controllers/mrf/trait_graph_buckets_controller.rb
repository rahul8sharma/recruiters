class Mrf::TraitGraphBucketsController < MasterDataController
  def api_resource
    Vger::Resources::Mrf::TraitGraphBucket
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :uid, :name, :min_val, :max_val, :company_id]
  end

end



