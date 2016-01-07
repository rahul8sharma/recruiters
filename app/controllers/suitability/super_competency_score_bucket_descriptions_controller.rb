class Suitability::SuperCompetencyScoreBucketDescriptionsController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::SuperCompetencyScoreBucketDescription
  end
  
  def s3_key
    "super_competency_score_bucket_descriptions.csv.zip"
  end

  def index_columns
    [
      :id, 
      :super_competency_id, 
      :company_id,
      :scored_score_bucket_id, 
      :desired_score_bucket_id,
      :description
    ]
  end

  def search_columns
    [
      :super_competency_id, 
      :company_id,
      :scored_score_bucket_id, 
      :desired_score_bucket_id
    ]
  end
end
