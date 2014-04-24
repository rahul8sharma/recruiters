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
    payment_data = Crypto::AES.decrypt(
                                        params[:data],
                                        Rails.application.config.payments['encryption_key']
                                      )
    payment_data = payment_data.split('&').map do |key_value|
                            key_value.split('=')
                          end.inject({}) do | hash, injected |
                            hash.merge!(injected[0].to_sym => injected[1])
                          end

    subscription_data = {}
    if payment_data[:order_status] == "Success"
      # Retrieve the plan from merchant_param1
      plan = Vger::Resources::Plan.find(payment_data[:merchant_param1])

      subscription_data[:company_id] = payment_data[:merchant_param3]
      subscription_data[:assessments_purchased] = plan.no_of_assessments
      subscription_data[:price] = payment_data[:amount]
      subscription_data[:valid_from] = Time.now.strftime("%Y-%m-%d")
      subscription_data[:valid_to] = (Date.today + plan.validity_in_months.months)
      subscription_data[:order_id] = payment_data[:order_id]
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
end
