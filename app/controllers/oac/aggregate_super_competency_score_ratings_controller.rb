class Oac::AggregateSuperCompetencyScoreRatingsController < MasterDataController
  def api_resource
    Vger::Resources::Oac::AggregateSuperCompetencyScoreRating
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :uid, :name, :min_val, :max_val, :color]
  end
end
