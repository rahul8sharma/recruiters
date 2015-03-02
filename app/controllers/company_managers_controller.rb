class CompanyManagersController < MasterDataController
  def api_resource
    Vger::Resources::CompanyManager
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :name,
      :email,
      :reset_password_token
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
