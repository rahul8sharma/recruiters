class WorkExperiencesController < MasterDataController
  before_filter :authenticate_user!
  
  def api_resource
    Vger::Resources::WorkExperience
  end
  
  def index_columns
    [
      :id,
      :candidate_id,
      :company,
      :role,
      :years
    ]
  end
  
  def search_columns
    [
      :id,
      :candidate_id,
      :company,
      :role,
      :years
    ]
  end
end
