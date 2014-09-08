class Suitability::FactorNormBucketDescriptionsController < SpecialMasterDataController
  def api_resource
    Vger::Resources::Suitability::FactorNormBucketDescription
  end

  def index_columns
    [:id, :factor_id, :industry_id, :functional_area_id, :job_experience_id, :description]
  end
  
  def s3_key
    "factor_norm_bucket_descriptions.csv.zip"
  end
end
