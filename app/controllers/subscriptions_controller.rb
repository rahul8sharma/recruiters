class SubscriptionsController < MasterDataController
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
    #do we need to redirect to that URL?

    #what is the route to this method? right now it is line 36 of routes.rb under resources :companies
    #move the relevant view under subscriptions
  end

  #for subscription upgrades
  def update_subscription
    if request.put?
      subscription = Vger::Resources::Subscription.where(:query_options => { :company_id => params[:company_id] }).all[0]
        #how do I find which subscription of a particular company is getting upgraded, considering companies has_many :subscriptions?
          #this might be just a Rails thing probably
        #assuming, I divine which subscription is getting updated
      subscription_data[:company_id] = params[:company_id]
      subscription_data[:assessments_purchased] = params[:number_of_assessments_purchased]
      subscription_data[:price] = params[:amount]
      subscription_data[:valid_to] = params[:subscription_expiry]
      subscription = Vger::Resources::Subscription.update(subscription_data)

      #code to trigger an email
      #no flash "Success"
    end
  end

  #for new subscriptions
  def create_subscription

    if request.post?
        subscription_data[:company_id] = params[:company_id]
        subscription_data[:assessments_purchased] = params[:number_of_assessments_purchased]
        subscription_data[:price] = params[:amount]
        subscription_data[:valid_from] = Time.now
        subscription_data[:valid_to] = params[:subscription_expiry]
        subscription = Vger::Resources::Subscription.create(subscription_data)

        #code to trigger an email
        #no flash "Success"
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
