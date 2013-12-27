class Suitability::DefaultFactorNormRangesController < SpecialMasterDataController
  def api_resource
    Vger::Resources::Suitability::DefaultFactorNormRange
  end
  
  def index_columns
    [
      :id,
      :factor_id,
      :industry_id,
      :functional_area_id, 
      :job_experience_id,
      :from_norm_bucket_id,
      :to_norm_bucket_id
    ]
  end
end
