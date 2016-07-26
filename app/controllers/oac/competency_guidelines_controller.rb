class Oac::CompetencyGuidelinesController < MasterDataController
  def api_resource
    Vger::Resources::Oac::CompetencyGuideline
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id,  :exercise_id, :competency_id, :body]
  end
end



