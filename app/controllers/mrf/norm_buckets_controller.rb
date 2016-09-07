class Mrf::NormBucketsController < MasterDataController
  def api_resource
    Vger::Resources::Mrf::NormBucket
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id,:uid,:name,:description,:weight,:company_id]
  end
  
  def search_columns
    [:id,:uid,:name,:weight,:company_id]
  end
end



