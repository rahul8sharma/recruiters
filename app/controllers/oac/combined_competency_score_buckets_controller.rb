class Oac::CombinedCompetencyScoreBucketsController < MasterDataController
  def api_resource
    Vger::Resources::Oac::CombinedCompetencyScoreBucket
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:uid, :name, :min_val, :max_val, :weight]
  end
end
