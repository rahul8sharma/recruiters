class SubscriptionsController < MasterDataController
  skip_before_filter :authenticate_user!, :only => [:payment_success]
  def api_resource
    Vger::Resources::Subscription
  end

  def import_from
    "import_from_google_drive"
  end



   def add_subscription

    #the post request to this route will come in via :
    # from the add subscription form on the subscription view

    #code to generate URL for the billing app
    #believed route to this action via line 36 of routes.rb
    #actual route to this action via line 199 of routes.rb
  end


  #for successful payments
  #def create_subscription
  def payment_success
    subscription_data ||= {}
    if request.post?
        subscription_data[:company_id] = params[:company_id]
        subscription_data[:assessments_purchased] = params[:number_of_assessments_purchased]
        subscription_data[:price] = params[:amount]
        subscription_data[:valid_from] = Time.now.strftime("%Y-%m-%d")
        subscription_data[:valid_to] = params[:subscription_expiry]
        subscription = Vger::Resources::Subscription.create(subscription_data)
    end
  end

  #for failed payments
  def payment_failure
    subscription_data[:company_id] = params[:company_id]
    subscription_data[:assessments_purchased] = params[:number_of_assessments_purchased]
    subscription_data[:price] = params[:amount]

    JombayNotify::Email.create_from_mail(SystemMailer.payment_failure_notice(subscription_data), "payment_failure_notice")
    render :status => :ok, :json => { }

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
