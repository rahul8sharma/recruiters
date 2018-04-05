class Mrf::FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action { authorize_user!(params[:company_id]) }
  before_action :get_company

  layout 'mrf/mrf'
  
  def index
    params[:search] ||= {}
    search_params = params[:search].to_h
    search_params[:company_id] = params[:company_id]
    scopes = {}
    scopes["user_name_like"] = search_params.delete :user_name
    scopes["user_email_like"] = search_params.delete :user_email
    scopes["stakeholder_name_like"] = search_params.delete :stakeholder_name
    scopes["stakeholder_email_like"] = search_params.delete :stakeholder_email
    scopes = scopes.select{|key,val| val.present? }
    search_params = search_params.select{|key,val| val.present? }
    conditions = {
      company_id: params[:company_id],
      query_options: search_params,
      scopes: scopes,
      joins: [:user, :stakeholder],
      include:  [:stakeholder_assessment, :user, :stakeholder, :assessment], 
      page: params[:page],
      per: 10
    }
    @feedbacks = Vger::Resources::Companies::Mrf::Feedback.where(conditions)
  end
  
  private
  
  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end
end
