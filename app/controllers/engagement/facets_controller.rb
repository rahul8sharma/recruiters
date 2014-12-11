class Engagement::FacetsController < MasterDataController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Engagement::Facet
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:uid, :name, :definition, :active]
  end
  
  def search_columns
    [:name]
  end
end
