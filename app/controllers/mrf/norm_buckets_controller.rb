class Mrf::NormBucketsController < MasterDataController
  def api_resource
    Vger::Resources::Mrf::NormBucket
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id,:uid,:name,:description,:weight]
  end

end



