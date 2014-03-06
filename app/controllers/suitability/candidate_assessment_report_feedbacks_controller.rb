class Suitability::CandidateAssessmentReportFeedbacksController < ApplicationController 
  def thank_you
    
  end
  
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
    render :action => :thank_you, :layout => "feedback_reports"
  end
end
