class Suitability::SuperCompetencyScoreBucketsController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::SuperCompetencyScoreBucket
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :name, :min_value, :max_value, :company_id]
  end

  def search_columns
    [
      :id,
      :name,
      :company_id
    ]
  end
end
