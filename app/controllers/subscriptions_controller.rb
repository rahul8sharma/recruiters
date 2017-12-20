class SubscriptionsController < MasterDataController
  skip_before_filter :authenticate_user!, only: [:payment_status]
  def api_resource
    Vger::Resources::Subscription
  end
  
  def invitation_klass
    Vger::Resources::Invitation
  end
  
  def redirect_path
    manage_subscriptions_path
  end
  
  def export
    export_hash = {
      args: params[:export].merge({
        user_id: current_user.id,
      }),
      job_klass: "SubscriptionsExporter"
    }
    Vger::Resources::User.get("/sidekiq/queue-job?#{export_hash.to_param}")
    flash[:notice] = "Export is triggered. An email will be sent to #{current_user.email}"
    redirect_to manage_subscriptions_path
  end
  
  # Expires a subscription prematurely
  # Sets status of all invitations under a subscription to 'expired'
  def expire_subscription
    if params[:subscription_id].blank?  
      flash[:error] = "Please provide a valid Subscription ID."
      redirect_to manage_subscriptions_path and return
    end
    now = Time.now
    subscription = api_resource.save_existing(params[:subscription_id], :valid_to => now)
    if subscription.error_messages.present?
      flash[:error] = subscription.error_messages.join("<br/>").html_safe
      redirect_to redirect_path
    else
      invitation_klass.update_all(:query_options => {:company_id => params[:company_id],:subscription_id => params[:subscription_id], :status => invitation_klass::Status::UNLOCKED}, :update_attributes => {:status => invitation_klass::Status::EXPIRED, :expiry => now})
      flash[:notice] = "Subscription with id '#{params[:subscription_id]}' expired successfully."
      redirect_to redirect_path
    end
  end

  #for successful payments
  #def create_subscription
  def payment_status
    payment_data = Crypto::AES.decrypt(
                                        params[:data],
                                        Rails.application.config.payments['encryption_key']
                                      )
    payment_data = JSON.parse(payment_data)
    subscription_data = {}
    if payment_data["TxStatus"] == "SUCCESS"
      # Retrieve the plan from custom parameter planID
      plan = Vger::Resources::Plan.find(payment_data["planID"])

      subscription_data[:company_id] = payment_data["companyID"]
      subscription_data[:assessments_purchased] = plan.no_of_assessments
      subscription_data[:price] = payment_data["amount"]
      subscription_data[:valid_from] = Time.now.strftime("%Y-%m-%d")
      subscription_data[:valid_to] = (Date.today + plan.validity_in_months.months)
      subscription_data[:order_id] = payment_data["TxId"]
      job_id = Vger::Resources::Subscription.create(subscription_data)
      render :status => :ok, :json => { :job_id => job_id }
    else
      job_id = JombayNotify::Email.create_from_mail(SystemMailer.payment_failure_notice(payment_data), "payment_failure_notice")
      render :status => :ok, :json => { :job_id => job_id }
    end
  end

  def index_columns
    [
      :id,
      :company_id,
      :assessments_purchased,
      :valid_from,
      :valid_to
    ]
  end
  
  def search_columns
    [
      :id,
      :assessments_purchased,
      :company_id
    ]
  end
end
