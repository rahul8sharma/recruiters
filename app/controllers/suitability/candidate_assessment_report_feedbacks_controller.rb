class Suitability::CandidateAssessmentReportFeedbacksController < ApplicationController 
  def create
    factor_feedback_scores_attributes = []
    params[:feedback][:factor_feedback].each do |id,score|
      factor_feedback_scores_attributes << {
        :candidate_factor_score_id => id,
        :score => score
      }
    end
    @feedback = Vger::Resources::Suitability::CandidateAssessmentReportFeedback.new(:email => params[:feedback][:email],:candidate_assessment_id => params[:feedback][:candidate_assessment_id], :factor_feedback_scores_attributes => factor_feedback_scores_attributes)
    @feedback.save
    redirect_to company_assessment_candidate_candidate_assessment_report_url(
      :company_id => params[:feedback][:company_id],
      :assessment_id => params[:feedback][:assessment_id],
      :candidate_id => params[:feedback][:candidate_id],
      :id => params[:feedback][:candidate_assessment_report_id],
      :view_mode => "html"
    )
  end
end
