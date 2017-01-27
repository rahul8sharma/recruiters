class CompanyManagersController < MasterDataController
  def api_resource
    Vger::Resources::User
  end

  def email_usage_stats
    params[:export] ||= {}
    params[:export][:company_ids] = params[:export][:company_ids].to_s.split(',')
     options = {
      :account_usage_stats => {
        :job_klass => "AccountUsageStatsExporter",
        :args => {
          :user_id => current_user.id
        }.merge(params[:export])
      }
    }
    Vger::Resources::User.find(current_user.id)\
      .export_usage_stats(options)
    redirect_to request.env['HTTP_REFERER'], notice: "Overall Usage Summary will be generated and emailed to #{current_user.email}."
  end
  
  def email_reports_summary
    params[:export] ||= {}
    params[:export][:company_ids] = params[:export][:company_ids].to_s.split(',')
    options = {
      :assessment_stats => {
        :job_klass => "Suitability::Assessment::AccountReportsSummaryExporter",
        :args => {
          :user_id => current_user.id,
        }.merge(params[:export])
      }
    }
    Vger::Resources::User.find(current_user.id)\
      .export_assessment_stats(options)
    redirect_to request.env['HTTP_REFERER'], notice: "Reports Summary will be generated and emailed to #{current_user.email}."
  end
  
  def email_assessment_stats
    params[:export] ||= {}
    params[:export][:company_ids] = params[:export][:company_ids].to_s.split(',')
    options = {
      :assessment_stats => {
        :job_klass => "Suitability::Assessment::AccountAssessmentStatusExporter",
        :args => {
          :user_id => current_user.id
        }.merge(params[:export])
      }
    }
    Vger::Resources::User.find(current_user.id)\
      .export_assessment_stats(options)
    redirect_to request.env['HTTP_REFERER'], notice: "Assessment Status Summary will be generated and emailed to #{current_user.email}."
  end


  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [
      :id,
      :name,
      :email,
      :reset_password_token
    ]
  end

  def search_columns
    [
      :id,
      :name,
      :email
    ]
  end
end
