class WorkExperiencesController < MasterDataController
  before_action :authenticate_user!
  
  def api_resource
    Vger::Resources::WorkExperience
  end
  
  def index_columns
    [
      :id,
      :user_id,
      :company,
      :role,
      :years
    ]
  end
  
  def search_columns
    [
      :id,
      :user_id,
      :company,
      :role,
      :years
    ]
  end
end
