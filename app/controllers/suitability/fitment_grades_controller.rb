class Suitability::FitmentGradesController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::FitmentGrade
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :uid, :min_factors_pass_percent, :max_factors_pass_percent]
  end
end
