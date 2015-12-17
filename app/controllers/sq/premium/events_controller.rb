class Sq::Premium::EventsController < MasterDataController
  def api_resource
    Vger::Resources::Sq::Premium::Event
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :name, :url]
  end
end
