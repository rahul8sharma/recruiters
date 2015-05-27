class Suitability::CompanyNormBucketsController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::CompanyNormBucket
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :name, :weight, :description, :norm_bucket_ids, :company_id]
  end
end
