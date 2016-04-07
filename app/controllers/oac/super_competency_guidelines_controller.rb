class Oac::SuperCompetencyGuidelinesController < MasterDataController
  def api_resource
    Vger::Resources::Oac::SuperCompetencyGuideline
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id,  :exercise_id, :super_competency_id, :combined_super_competency_score_bucket_id]
  end
end



