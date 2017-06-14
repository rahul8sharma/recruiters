class Oac::Analytics::PerformanceReportsController < ApplicationController
  layout "users"
  before_filter :authenticate_user!
  before_filter :check_superuser

  def performance_report
    if request.get?
    else
      flash[:notice] = "Performace Report will be generated and emailed to #{current_user.email} shortly"
      Vger::Resources::User\
        .post(
          "/sidekiq/post-job?job_klass=Oac::Analytics::PerformanceReportGenerator",
          params[:performance_report].merge({
            user_id: current_user.id
          })
        )
    end
  end
end
