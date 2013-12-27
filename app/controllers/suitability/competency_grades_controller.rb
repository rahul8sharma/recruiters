class Suitability::CompetencyGradesController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::CompetencyGrade
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :uid, :name, :min_score, :max_score]
  end
end
