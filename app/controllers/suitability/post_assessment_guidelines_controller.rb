class Suitability::PostAssessmentGuidelinesController < SpecialMasterDataController
  def api_resource
    Vger::Resources::Suitability::PostAssessmentGuideline
  end
  
  def index_columns
    [
      :id, 
      :factor_id,
      :industry_id,
      :functional_area_id, 
      :job_experience_id,
      :body, 
      :candidate_stage, 
      :norm_bucket_id
    ]
  end
end
