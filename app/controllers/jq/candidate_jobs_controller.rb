class Jq::CandidateJobsController < MasterDataController
  before_filter :authenticate_user!
  
  def api_resource
    Vger::Resources::Jq::CandidateJob
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :candidate_id,
      :job_id,
      :company_id,
      :candidate_status,
      :recruiter_status
    ]
  end
  
  def search_columns
    [
      :id,
      :candidate_id,
      :job_id,
      :company_id,
      :candidate_status,
      :recruiter_status
    ]
  end
end
