class SubjectiveItemsController < MasterDataController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::SubjectiveItem
  end

  def import_from
    "import_from_google_drive"
  end
  def index_columns
    [:id,:body, :active, :subjective_item_group_id]
  end


end
