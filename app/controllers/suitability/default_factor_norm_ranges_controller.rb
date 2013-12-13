class Suitability::DefaultFactorNormRangesController < Suitability::MasterDataController
  def api_resource
    Vger::Resources::Suitability::DefaultFactorNormRange
  end
  
  def index
    params[:search] ||= {}
    @objects = Vger::Resources::Suitability::DefaultFactorNormRange.where(
      :include => [:factor, :functional_area, :industry, :from_norm_bucket, :to_norm_bucket, :job_experience], 
      :query_options => params[:search], 
      :page => params[:page], 
      :per => 10
    ).all
  end
end
