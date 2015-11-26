class Mrf::TraitGuidelinesController < MasterDataController
  def api_resource
    Vger::Resources::Mrf::TraitGuideline
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id,  :assessment_id, :trait_type, :trait_id, :guideline_for_user, :guideline_for_manager]
  end
end



