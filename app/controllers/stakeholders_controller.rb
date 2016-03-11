class StakeholdersController < MasterDataController
  def api_resource
    Vger::Resources::Stakeholder
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :name,
      :email
    ]
  end
  
  def search_columns
    [
      :id,
      :name,
      :email
    ]
  end
end
