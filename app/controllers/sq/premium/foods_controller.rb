class Sq::Premium::FoodsController < MasterDataController
  def api_resource
    Vger::Resources::Sq::Premium::Food
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :name, :url]
  end
end
