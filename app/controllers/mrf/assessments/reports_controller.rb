class Mrf::Assessments::ReportsController < ApplicationController
  
  layout "reports_360"
  
  def report
    @norm_buckets = Vger::Resources::Suitability::NormBucket.all
    @report = Vger::Resources::Mrf::Report.where(:query_options =>{:candidate_id => params[:candidate_id], :assessment_id => params[:id]}).all.to_a.first
    Rails.logger.debug(@report.report_data)
  end

end