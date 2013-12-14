class Suitability::OverallFitmentGradesController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::OverallFitmentGrade
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :uid, :name]
  end
end
