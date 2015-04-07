class CompanyManagersController < MasterDataController
  def api_resource
    Vger::Resources::CompanyManager
  end

  def email_usage_stats
     options = {
      :account_usage_stats => {
        :job_klass => "AccountUsageStatsExporter",
        :args => {
          :user_id => current_user.id
        }
      }
    }
    Vger::Resources::CompanyManager.find(current_user.id)\
      .export_usage_stats(options)
    redirect_to request.env['HTTP_REFERER'], notice: "Overall Usage Summary will be generated and emailed to #{current_user.email}."
  end
  
  def email_assessment_stats
     options = {
      :assessment_stats => {
        :job_klass => "Suitability::Assessment::CompanyManagerAssessmentStatusExporter",
        :args => {
          :user_id => current_user.id,
          :company_id => params[:company_id]
        }
      }
    }
    Vger::Resources::CompanyManager.find(current_user.id)\
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
