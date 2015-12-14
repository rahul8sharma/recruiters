class Sq::Inspirations::StoriesController < MasterDataController
  def api_resource
    Vger::Resources::Sq::Inspirations::Story
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :title, :description, :scheduled_for]
  end
end
