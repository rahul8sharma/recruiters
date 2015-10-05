class Sq::QuadrantsController < MasterDataController
  def api_resource
    Vger::Resources::Sq::Quadrant
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :uid, :name, :description]
  end
end
