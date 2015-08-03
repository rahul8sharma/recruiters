class Mrf::FeedbacksController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company

  layout 'mrf/mrf'
  
  def index
    params[:search] ||= {}
    search_params = params[:search].dup
    search_params[:company_id] = params[:company_id]
    scopes = {}
    scopes["candidate_name_like"] = search_params.delete :candidate_name
    scopes["candidate_email_like"] = search_params.delete :candidate_email
    scopes["stakeholder_name_like"] = search_params.delete :stakeholder_name
    scopes["stakeholder_email_like"] = search_params.delete :stakeholder_email
    scopes = scopes.select{|key,val| val.present? }
    conditions = {
      company_id: params[:company_id],
      query_options: search_params,
      scopes: scopes,
      joins: [:candidate, :stakeholder],
      include:  [:stakeholder_assessment, :candidate, :stakeholder, :assessment], 
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
