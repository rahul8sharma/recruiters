class TemplateVariablesController < MasterDataController
  def api_resource
    Vger::Resources::TemplateVariable
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :category,
      :name,
      :value
    ]
  end
  
  def search_columns
    [
      :id,
      :name,
      :category
    ]
  end
end
