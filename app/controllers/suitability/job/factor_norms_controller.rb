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
      :norm_bucket_id,
      :norm_min,
      :norm_max,
      :purpose
    ]
  end
  
  def search_columns
    [
      :industry_id,
      :functional_area_id, 
      :job_experience_id,
      :factor_id,
      :purpose
    ]
  end
  
  def select_purpose
    ['suitability','vac']
  end
end
