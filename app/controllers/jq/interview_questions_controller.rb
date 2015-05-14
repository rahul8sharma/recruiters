class Jq::InterviewQuestionsController < MasterDataController
  before_filter :authenticate_user!
  
  def api_resource
    Vger::Resources::Jq::InterviewQuestion
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :type,
      :job_id,
      :company_id,
      :body,
      :allowed_time
    ]
  end
  
  def search_columns
    [
      :id,
      :job_id,
      :company_id,
      :body,
      :allowed_time
    ]
  end
end
