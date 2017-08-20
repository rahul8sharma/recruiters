class Suitability::SuperCompetenciesController < MasterDataController
  def api_resource
    Vger::Resources::Suitability::SuperCompetency
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :uid, :name, :company_id, :modules, :competency_ids, :competency_names, :active]
  end
  
  def form_fields
    [:id, :uid, :name, :company_id, :active, :description]
  end

  def search_columns
    [
      :id,
      :name,
      :active
    ]
  end
end
