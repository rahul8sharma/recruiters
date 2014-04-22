class Companies::StandardAssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_company
  
  layout "companies"
  
  def show
    @standard_assessment = Vger::Resources::Suitability::StandardAssessment.find(params[:id])
    @assessment_factor_norms = @standard_assessment.job_assessment_factor_norms.where(:include  => [:functional_area, :industry, :job_experience, :from_norm_bucket, :to_norm_bucket], :include => { :factor => { :methods => [:type, :direct_predictor_ids] } }).all.to_a
    
    direct_predictor_parent_ids = @assessment_factor_norms.collect{ |factor_norm| factor_norm.factor.direct_predictor_ids.present? ? factor_norm.factor_id : nil }.compact.uniq
    direct_predictor_norms = @assessment_factor_norms.select{ |factor_norm| direct_predictor_parent_ids.include? factor_norm.factor_id }.uniq
    lie_detector_norms = @assessment_factor_norms.select{ |factor_norm| factor_norm.factor.type == "Suitability::LieDetector" }.uniq
    alarm_factor_norms = @assessment_factor_norms.select{ |factor_norm| factor_norm.factor.type == "Suitability::AlarmFactor" }.uniq
    @assessment_factor_norms = @assessment_factor_norms - direct_predictor_norms - lie_detector_norms
    @other_norms = direct_predictor_norms
    @norm_buckets = Hash[Vger::Resources::Suitability::NormBucket.all.to_a.map{|norm_bucket| [norm_bucket.id,norm_bucket] }]
  end
  
  def send_test
    custom_assessment = Vger::Resources::Suitability::CustomAssessment.copy_standard_assessment(:company_id => @company.id, :standard_assessment_id => params[:id])
    redirect_to add_candidates_company_custom_assessment_path(:company_id => params[:company_id], :id => custom_assessment.id)
  end
  
  protected
  
  def get_company
    @company =  Vger::Resources::Company.find(params[:company_id])
  end  
end
