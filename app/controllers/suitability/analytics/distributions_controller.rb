class Suitability::Analytics::DistributionsController < ApplicationController
  layout "users"
  before_filter :authenticate_user!
  before_filter :check_superuser

  def score_distributions_report
    if request.get?
    else
      flash[:notice] = "Score Distributions Report will be generated and emailed to #{current_user.email} shortly"
      Vger::Resources::User\
        .post(
          "/sidekiq/post-job?job_klass=Suitability::Analytics::ScoreDistributionsReportGenerator",
          params[:score_distributions].merge({
            user_id: current_user.id
          })
        )
    end
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
