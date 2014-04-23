class SubscriptionsController < MasterDataController
  skip_before_filter :authenticate_user!
  def api_resource
    Vger::Resources::Subscription
  end

  def import_from
    "import_from_google_drive"
  end

  #for successful payments
  #def create_subscription
  def payment_status
    subscription_data = {}
    if params[:order_status] == "Success"
      # Retrieve the plan from merchant_param1
      plan = Vger::Resources::Plan.find(params[:merchant_param1])

      subscription_data[:company_id] = params[:merchant_param3]
      subscription_data[:assessments_purchased] = plan.no_of_assessments
      subscription_data[:price] = params[:amount]
      subscription_data[:valid_from] = Time.now.strftime("%Y-%m-%d")
      subscription_data[:valid_to] = (Date.today + plan.validity_in_months.months)
      subscription_data[:order_id] = params[:order_id]
      job_id = Vger::Resources::Subscription.create(subscription_data)
      render :status => :ok, :json => { :job_id => job_id }
    else
      job_id = JombayNotify::Email.create_from_mail(SystemMailer.payment_failure_notice(params), "payment_failure_notice")
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
end
