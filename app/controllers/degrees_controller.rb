class DegreesController < MasterDataController
  def api_resource
    Vger::Resources::Degree
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :name
    ]
  end
end
