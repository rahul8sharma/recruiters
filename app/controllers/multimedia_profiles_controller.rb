class MultimediaProfilesController < MasterDataController
  before_filter :authenticate_user!
  
  def api_resource
    Vger::Resources::MultimediaProfile
  end
  
  def index_columns
    [
      :id,
      :candidate_id
    ]
  end
  
  def search_columns
    [
      :id,
      :candidate_id
    ]
  end
end
