class Suitability::PostAssessmentGuidelinesController < Suitability::MasterDataController
  def api_resource
    Vger::Resources::Suitability::PostAssessmentGuideline
  end
  
  def index
    params[:search] ||= {}
    @objects = Vger::Resources::Suitability::PostAssessmentGuideline.where(
      :query_options => params[:search], 
      :page => params[:page], 
      :per => 10, 
      :include => [:factor]
    ).all
  end
end
