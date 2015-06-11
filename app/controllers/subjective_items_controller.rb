class SubjectiveItemsController < MasterDataController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::SubjectiveItem
  end

  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [:id,:body, :behaviour, :active, :subjective_item_group_id, :section_id, :company_id]
  end
  
  def search_columns
    [:id,:body, :behaviour, :active, :subjective_item_group_id, :section_id, :company_id]
  end
end
