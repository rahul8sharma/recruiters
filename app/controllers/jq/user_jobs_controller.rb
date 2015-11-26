class Jq::UserJobsController < MasterDataController
  before_filter :authenticate_user!
  
  def api_resource
    Vger::Resources::Jq::UserJob
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :user_id,
      :job_id,
      :company_id,
      :user_status,
      :recruiter_status
    ]
  end
  
  def search_columns
    [
      :id,
      :user_id,
      :job_id,
      :company_id,
      :user_status,
      :recruiter_status
    ]
  end
end
