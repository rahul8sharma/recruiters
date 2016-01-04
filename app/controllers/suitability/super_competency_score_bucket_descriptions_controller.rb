class Suitability::SuperCompetencyScoreBucketDescriptionsController < SpecialMasterDataController
  def api_resource
    Vger::Resources::Suitability::SuperCompetencyScoreBucketDescription
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [
      :id, 
      :super_competency_id, 
      :company_id,
      :industry_id, 
      :functional_area_id, 
      :job_experience_id, 
      :scored_score_bucket_id, 
      :desired_score_bucket_id
    ]
  end

  def search_columns
    [
      :industry_id, 
      :functional_area_id, 
      :job_experience_id
    ]
  end
end
