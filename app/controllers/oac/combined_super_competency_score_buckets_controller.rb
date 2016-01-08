class Oac::CombinedSuperCompetencyScoreBucketsController < MasterDataController
  def api_resource
    Vger::Resources::Oac::CombinedSuperCompetencyScoreBucket
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :uid, :name, :min_val, :max_val, :weight]
  end
end
