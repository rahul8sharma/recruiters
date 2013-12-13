class Suitability::Job::FactorNormsController < Suitability::MasterDataController
  def api_resource
    Vger::Resources::Suitability::Job::FactorNorm
  end

  def index
    params[:search] ||= {}
    @objects = Vger::Resources::Suitability::Job::FactorNorm.where(
      :include => [
        :factor,
        :industry,
        :functional_area,
        :job_experience
      ], 
      :query_options => params[:search], 
      :page => params[:page], 
      :per => 10
    ).all
  end
end
