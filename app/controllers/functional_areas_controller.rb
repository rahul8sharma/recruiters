class FunctionalAreasController < MasterDataController
  def api_resource
    Vger::Resources::FunctionalArea
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :active,
      :name
    ]
  end
  
  def search_columns
    [
      :id,
      :name
    ]
  end
end
