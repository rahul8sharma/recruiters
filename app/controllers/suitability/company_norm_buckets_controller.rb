class Suitability::CompanyNormBucketsController < MasterDataController
  before_filter :split_norm_bucket_ids, only: [:create, :update]
  
  def api_resource
    Vger::Resources::Suitability::CompanyNormBucket
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :name, :weight, :description, :norm_bucket_ids, :company_id]
  end
  
  def search_columns
    [:id, :name, :weight, :company_id]
  end
  
  def split_norm_bucket_ids
    params[resource_name.singularize][:norm_bucket_ids] = params[resource_name.singularize][:norm_bucket_ids].to_s.split(";").map(&:strip)
  end
end
