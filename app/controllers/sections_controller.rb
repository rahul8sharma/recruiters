class SectionsController < MasterDataController
  def api_resource
    Vger::Resources::Section
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :name,
      :company_id,
      :active
    ]
  end
  
  def search_columns
    [
      :id,
      :name,
      :company_id,
      :active
    ]
  end
end
