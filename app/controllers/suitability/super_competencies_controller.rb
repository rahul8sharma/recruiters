class Suitability::SuperCompetenciesController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::SuperCompetency
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :uid, :name, :company_id, :modules, :active]
  end

  def search_columns
    [
      :id,
      :name,
      :active
    ]
  end
end
