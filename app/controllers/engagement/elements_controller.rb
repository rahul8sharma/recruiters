class Engagement::ElementsController < MasterDataController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Engagement::Element
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:uid, :name, :definition, :factor_id, :active]
  end
  
  def search_columns
    [:name, :factor_id]
  end
end
