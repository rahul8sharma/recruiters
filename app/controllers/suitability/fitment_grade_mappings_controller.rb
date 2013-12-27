class Suitability::FitmentGradeMappingsController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::FitmentGradeMapping
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :fitment_grades, :overall_fitment_grade_id]
  end
end
