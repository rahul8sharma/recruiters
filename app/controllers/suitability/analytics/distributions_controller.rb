class Suitability::Analytics::DistributionsController < ApplicationController
  layout "users"
  before_action :authenticate_user!
  before_action :check_superuser

  def score_distributions_report
    if request.get?
    else
      flash[:notice] = "Score Distributions Report will be generated and emailed to #{current_user.email} shortly"
      args = {
        user_id: current_user.id
      }
      if params[:score_distributions][:file].present?
        s3_obj = S3Utils.upload(
          "stack_ranking_report_#{params[:score_distributions][:assessment_ids].split(',').join('_')}",
          params[:score_distributions][:file].read
        )
        s3_key, s3_bucket = s3_obj.key, s3_obj.bucket.name
        args.merge!({
          file: {
            s3_bucket: s3_bucket,
            s3_key: s3_key
          }
        })
      end
      Vger::Resources::User\
        .post(
          "/sidekiq/post-job?job_klass=Suitability::Analytics::ScoreDistributionsReportGenerator",
          params[:score_distributions].merge(args)
        )
    end
  end
  
  def download_candidates_score_distributions_report
    flash[:notice] = "Candidates for Score Distribution Report will be emailed to #{current_user.email} shortly"
    Vger::Resources::User\
      .post(
        "/sidekiq/post-job?job_klass=Suitability::Analytics::ScoreDistributionsReportCandidatesGenerator",
        params[:score_distributions].merge({
          user_id: current_user.id
        })
      )
    redirect_to suitability_analytics_score_distributions_report_path
  end
  
  def factual_data_distributions_report
    if request.get?
    else
      flash[:notice] = "Factual Data Distributions Report will be generated and emailed to #{current_user.email} shortly"
      Vger::Resources::User\
        .post(
          "/sidekiq/post-job?job_klass=Suitability::Analytics::FactualDataDistributionsReportGenerator",
          params[:factual_data_distributions].merge({
            user_id: current_user.id
          })
        )
    end
  end
end
