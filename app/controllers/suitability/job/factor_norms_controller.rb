class Suitability::Job::FactorNormsController < SpecialMasterDataController
  def api_resource
    Vger::Resources::Suitability::Job::FactorNorm
  end

  def index_columns
    [
      :id,
      :factor_id,
      :industry_id,
      :functional_area_id, 
      :job_experience_id,
      :norm_min,
      :norm_max
    ]
  end
  
  def s3_bucket_name
    "master_data"
  end
  
  def s3_key
    "factor_norms.csv.zip"
  end
end
