class Sq::ActivitiesController < MasterDataController
  def api_resource
    Vger::Resources::Sq::Activity
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :scheduled_for, :name, :description]
  end
end
