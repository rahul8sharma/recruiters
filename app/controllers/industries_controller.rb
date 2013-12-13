class IndustriesController < MasterDataController
  def api_resource
    Vger::Resources::Industry
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
end
