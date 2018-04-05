class Suitability::Analytics::ProjectionsController < ApplicationController
  layout "users"
  before_action :authenticate_user!
  before_action :check_superuser

  def projection_report
    if request.get?
      if params[:projection]
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
      if params[:projection]
        get_assessment_details
      end
    else
      args = {
        user_id: current_user.id
      }
      if params[:projection][:file].present?
        s3_obj = S3Utils.upload(
          "stack_ranking_report_#{params[:projection][:assessment_ids].split(',').join('_')}",
          params[:projection][:file].read
        )
        s3_key, s3_bucket = s3_obj.key, s3_obj.bucket.name
        args.merge!({
          file: {
            s3_bucket: s3_bucket,
            s3_key: s3_key
          }
        })
      end
      flash[:notice] = "Stack Ranking Report will be generated and emailed to #{current_user.email} shortly"
      Vger::Resources::User\
        .post(
          "/sidekiq/post-job?job_klass=Suitability::Analytics::StackRankingReportGenerator",
          params[:projection].merge(args)
        )
    end
  end
  
  def download_candidates_stack_ranking_report
    flash[:notice] = "Candidates for Stack Ranking Report will be emailed to #{current_user.email} shortly"
    Vger::Resources::User\
      .post(
        "/sidekiq/post-job?job_klass=Suitability::Analytics::StackRankingReportCandidatesGenerator",
        params[:projection].merge({
          user_id: current_user.id
        })
      )
    redirect_to suitability_analytics_stack_ranking_report_path        
  end
  
  protected
  
  def get_assessment_details
    @assessment_ids = params[:projection][:assessment_ids].split(",").map(&:to_i)
    @assessments = Vger::Resources::Suitability::CustomAssessment.where(
      query_options: {
        id: @assessment_ids,
      },
      methods: [:competency_score_ratings]
    )
    @factor_norms = {}
    @assessment_ids.each do |assessment_id|
      @factor_norms.merge!(Hash[
        Vger::Resources::Suitability::Job::AssessmentFactorNorm.where(
          custom_assessment_id: assessment_id,
          query_options: {
            assessment_id: assessment_id
          }
        ).all.to_a.map do |factor_norm|
          [factor_norm.factor_id, factor_norm]
        end
      ])
    end
    @competencies = {}
    if @assessments.map(&:competency_order).flatten.uniq.present?
      @competencies = Hash[Vger::Resources::Suitability::Competency.where(
        query_options: {
          id: @assessments.map(&:competency_order).flatten.uniq
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
        assessment_id: @assessment_ids
      }
    )
    @assessment_factor_weights = Vger::Resources::Suitability::AssessmentFactorWeight.where(
      query_options: {
        assessment_id: @assessment_ids
      }
    )
    @norm_buckets = Vger::Resources::Suitability::NormBucket.all.to_a.sort_by(&:weight)
  end
end
