class LanguagesController < MasterDataController
  def api_resource
    Vger::Resources::Language
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    return [:id, :name,:language_code]
  end
  
  def search_columns
    [
      :id,
      :name,
      :language_code
    ]
  end
end
