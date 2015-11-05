class Sjt::AssessmentsController < Suitability::CustomAssessmentsController
  layout 'sjt/sjt'

  def home
    order_by = params[:order_by] || "created_at"
    params[:order_by] ||= order_by
    order_type = params[:order_type] || "DESC"
    @assessments = api_resource.where(
      :query_options => { 
        :company_id => params[:company_id], 
        :assessment_type => ["sjt_competency"] 
      }, 
      :order => "#{order_by} #{order_type}", 
      :page => params[:page], 
      :per => 15
    )
    Rails.logger.ap("--LOGGER--")
    Rails.logger.ap(@assessments.size)
  end

  def edit
  end

  def new
  end

  def competencies
  end

  def add_candidates
  end

  def send_assessment
  end

  protected

end