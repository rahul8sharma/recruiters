class Suitability::Analytics::ProjectionsController < ApplicationController
  layout "users"
  before_filter :authenticate_user!
  before_filter :check_superuser

  def projection_report
    if request.get?
      if params[:assessment]
        get_assessment_details
      end
    else
      flash[:notice] = "Projection Report will be generated and emailed to #{current_user.email} shortly"
      Vger::Resources::User\
        .post(
          "/sidekiq/post-job?job_klass=Suitability::Analytics::ProjectionReportGenerator",
          params[:projection].merge({
            user_id: current_user.id
          })
        )
    end
  end
  
  def stack_ranking_report
    if request.get?
      if params[:assessment]
        get_assessment_details
      end
    else
      flash[:notice] = "Stack Ranking Report will be generated and emailed to #{current_user.email} shortly"
      Vger::Resources::User\
        .post(
          "/sidekiq/post-job?job_klass=Suitability::Analytics::StackRankingReportGenerator",
          params[:projection].merge({
            user_id: current_user.id
          })
        )
    end
  end
  
  protected
  
  def get_assessment_details
    @assessment = Vger::Resources::Suitability::CustomAssessment.find(
      params[:assessment][:assessment_id],
      methods: [:competency_score_ratings]
    )
    @factor_norms = Hash[Vger::Resources::Suitability::Job::AssessmentFactorNorm.where(
      custom_assessment_id: @assessment.id,
      query_options: {
        assessment_id: @assessment.id
      }
    ).all.to_a.map do |factor_norm|
      [factor_norm.factor_id, factor_norm]
    end]
    @competencies = {}
    if @assessment.competency_order.present?
      @competencies = Hash[Vger::Resources::Suitability::Competency.where(
        query_options: {
          id: @assessment.competency_order
        }
      ).all.to_a.map do |competency|
        [competency.id, competency]
      end]
      @factors = Hash[Vger::Resources::Suitability::Factor.where(
        query_options: {
          id: @competencies.values.map(&:factor_ids).flatten
        },
        root: 'factor'
      ).all.to_a.map do |factor|
        [factor.id, factor]
      end]
    else
      @factors = Hash[Vger::Resources::Suitability::Factor.where(
        query_options: {
          id: @factor_norms.keys
        },
        root: 'factor'
      ).all.to_a.map do |factor|
        [factor.id, factor]
      end]
    end  
    @assessment_competency_weights = Vger::Resources::Suitability::AssessmentCompetencyWeight.where(
      query_options: {
        assessment_id: @assessment.id
      }
    )
    @assessment_factor_weights = Vger::Resources::Suitability::AssessmentFactorWeight.where(
      query_options: {
        assessment_id: @assessment.id
      }
    )
    @norm_buckets = Vger::Resources::Suitability::NormBucket.all.to_a.sort_by(&:weight)
  end
end
