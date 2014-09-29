class Mrf::SubjectiveItemsController < MasterDataController
  def api_resource
    Vger::Resources::Mrf::SubjectiveItem
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :body,
      :trait_type,
      :trait_id,
      :identifier
    ]
  end
  
  def search_columns
    [
      :id,
      :body
    ]
  end
end
