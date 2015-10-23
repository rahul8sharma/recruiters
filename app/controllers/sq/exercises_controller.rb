class Sq::ExercisesController < MasterDataController
  def api_resource
    Vger::Resources::Sq::Exercise
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :scheduled_for, :quadrant_id, :bonus_score, :item_ids]
  end
end
