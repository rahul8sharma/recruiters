class Engagement::FactorsController < MasterDataController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Engagement::Factor
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:uid, :name, :definition, :facet_id, :active]
  end
  
  def search_columns
    [:name, :facet_id]
  end
end
