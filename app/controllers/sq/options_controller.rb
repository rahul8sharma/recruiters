class Sq::OptionsController < MasterDataController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Sq::Option
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id, :item_id, :quadrant_id, :body]
  end
  
  def search_columns
    [:id, :item_id, :quadrant_id, :body]
  end
end
