class Oac::ExerciseSuperCompetenciesController < MasterDataController
  def api_resource
    Vger::Resources::Oac::ExerciseSuperCompetency
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :exercise_id, :super_competency_id, :definition, :description]
  end
end
