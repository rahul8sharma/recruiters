class Jq::JobsController < MasterDataController
  before_filter :authenticate_user!
  before_filter :set_params, :only => [:create, :update]
  
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
      :jombay_ref_no,
      :posted_on,
      :location_ids
    ]
  end
  
  def search_columns
    [
      :id,
      :title,
      :company_id,
      :jombay_ref_no
    ]
  end
  
  private
  
  def set_params
    params[:jq_job][:location_ids] = params[:jq_job][:location_ids].to_s.split(",") 
  end
end
