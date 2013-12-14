class LocationsController < MasterDataController
  def api_resource
    Vger::Resources::Location
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :name,
      :location_type,
      :parent_id
    ]
  end
end
