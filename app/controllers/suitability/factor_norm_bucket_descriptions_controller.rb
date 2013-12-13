class Suitability::FactorNormBucketDescriptionsController < Suitability::MasterDataController
  def api_resource
    Vger::Resources::Suitability::FactorNormBucketDescription
  end

  def index
    params[:search] ||= {}
    @objects = Vger::Resources::Suitability::FactorNormBucketDescription.where(
      :query_options => params[:search],
      :page => params[:page], 
      :per => 10, 
      :include => [:factor, :norm_bucket]
    ).all
  end
end
