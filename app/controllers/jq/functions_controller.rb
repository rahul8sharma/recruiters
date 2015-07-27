class Jq::FunctionsController < MasterDataController
  def api_resource
    Vger::Resources::Jq::Function
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :competency_id,
      :name
    ]
  end
  
  def search_columns
    [
      :id,
      :competency_id,
      :name
    ]
  end
end
