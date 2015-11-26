class Mrf::CompetencyGuidelinesController < MasterDataController
  def api_resource
    Vger::Resources::Mrf::CompetencyGuideline
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id,  :assessment_id, :competency_id, :guideline_for_user, :guideline_for_manager]
  end
end



