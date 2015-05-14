class Jq::JobsController < MasterDataController
  before_filter :authenticate_user!
  
  def api_resource
    Vger::Resources::Jq::Job
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :title,
      :description,
      :company_id,
    ]
  end
  
  def search_columns
    [
      :id,
      :title,
      :company_id
    ]
  end
end
