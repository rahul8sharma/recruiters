class TemplateCategoriesController < MasterDataController
  def api_resource
    Vger::Resources::TemplateCategory
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
  
  def search_columns
    [
      :id,
      :name
    ]
  end
end
