class CompanyManagersController < ApplicationController
  layout "companies"
  
  def api_resource
    Vger::Resources::User
  end
  
  def select_company
    params[:search] ||= {}
    if current_user.company_ids && current_user.company_ids.size > 0
      params[:search] = params[:search].merge({ "companies.id" => current_user.company_ids })
      params[:search] = params[:search].select{|key,val| val.present? }
      order_by = params[:order_by] || "created_at"
      order_type = params[:order_type] || "DESC"
      @companies = Vger::Resources::Company.where(
        query_options: params[:search], 
        order: "#{order_by} #{order_type}", 
        select: [
          :id,
          :name,
          :created_at,
          :enable_suitability_reports_access
        ],
        page: params[:page], per: 10
      ).all
    else
      @companies = []
    end
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
end
