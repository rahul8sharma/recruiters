class Jq::QuadrantDescriptionsController < MasterDataController
  def api_resource
    Vger::Resources::Jq::QuadrantDescription
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :competency_id,
      :functional_area_id,
      :description
    ]
  end
  
  def search_columns
    [
      :id,
      :functional_area_id,
      :competency_id
    ]
  end
end
