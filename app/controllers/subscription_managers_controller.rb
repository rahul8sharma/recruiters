class SubscriptionManagersController < ApplicationController
  layout 'companies'
  
  before_filter :authenticate_user!
  
  before_filter :get_companies, only: [:companies]
  before_filter :get_company, only: [:company_statistics]

  
  def companies
    if @companies.present?
      @remaining_invitations = Vger::Resources::Invitation.group_count(
        :query_options => {
          :company_id => @companies.map(&:id),
          :status => Vger::Resources::Invitation::Status::UNLOCKED
        },
        :group => [ :company_id ],
        :select => [ :company_id ]
      )
      @invitations = Vger::Resources::Invitation.group_count(
        :query_options => {
          :company_id => @companies.map(&:id)
        },
        :group => [ :company_id ],
        :select => [ :company_id ]
      )
      
      @used_invitations = Vger::Resources::Invitation.group_count(
        :query_options => {
          :company_id => @companies.map(&:id),
          :status => Vger::Resources::Invitation::Status::USED
        },
        :group => [ :company_id ],
        :select => [ :company_id ]
      )

      @subscriptions = Vger::Resources::Subscription.group_count(
        :query_options => {
          :company_id => @companies.map(&:id)
        },
        :group => [ :company_id ],
        :select => [ :company_id ]
      )
      @active_subscriptions = Vger::Resources::Subscription.group_count(
        :query_options => {
          :company_id => @companies.map(&:id)
        },
        :scopes => { :active => nil },
        :group => [ :company_id ],
        :select => [ :company_id ]
      )
    end      
  end
  
  def company
    @company = Vger::Resources::Company.find(params[:company_id],{
      methods: [
        :subscriptions_count, :unused_invitations_count, 
        :used_invitations_count, :assigned_invitations_count,
        :subscription_valid_to
      ]
    })
  end
  
  def add_subscription
    @company = Vger::Resources::Company.find(params[:company_id],{})
    if request.post?
      begin
        valid_to = Date.parse(params[:subsciption][:valid_to])
      rescue Exception => e
        flash[:error] = e.message
        render :action => :add_subscription
        return
      end
      if (valid_to - Date.today) > 0
        attributes = params[:subsciption]
        subscription_data = attributes.merge({
          company_id: @company.id,
          valid_from: Time.now.strftime("%d/%m/%Y"),
          added_by_user_id: current_user.id,
        })
        type = params[:type].present? ? "::#{params[:type]}" : ""
        klass = "Vger::Resources#{type}::Subscription".constantize
        job_id = klass.create(subscription_data)
        flash[:notice] = "Subscription is being added. You should receive an email when the subscription gets added to the system."
        redirect_to company_subscription_managers_path(@company)
      else
        flash[:error] = "Subscription should be valid for at least 1 day"
        render :action => :add_subscription
      end
    end
  end
  
  def edit_subscription
    @company = Vger::Resources::Company.find(params[:company_id],{})
  end
  
  def edit_company
    if request.put?
      @company = Vger::Resources::Company.save_existing(params[:company_id], params[:company])
      if @company.error_messages.blank?
        redirect_to company_subscription_managers_path(@company), notice: "Company details updated successfully!"
      else
        flash[:error] = @company.error_messages.join("<br/>").html_safe
        render :action => :edit_company
      end
    else
      @company = Vger::Resources::Company.find(params[:company_id],{})
    end
  end
  
  def company_statistics
    get_subscriptions
    render :template => "subscription_managers/#{params[:type]}_statistics"
  end
  
  protected

  def get_company
    methods = [
      :unlocked_invites_count,
      :unlocked_360_invites_count,
      :unlocked_oac_invites_count,
      "assessment_statistics_for_#{params[:type]}",
      "recent_usage_statistics_for_#{params[:type]}"
    ]
    @company = Vger::Resources::Company.find(params[:company_id], :methods => methods)
    @company.recent_usage_statistics = @company.send("recent_usage_statistics_for_#{params[:type]}")
    @company.assessment_statistics = @company.send("assessment_statistics_for_#{params[:type]}")
  end
  
  def get_subscriptions
    klass = case params[:type]
      when 'suitability'
        Vger::Resources::Subscription
      when '360'
        Vger::Resources::Mrf::Subscription
      when 'vac'
        Vger::Resources::Oac::Subscription
    end   
    @subscriptions = klass.where(
      query_options: {
        company_id: @company.id
      },
      scopes: {
      },
      :methods => [
        :assessments_sent,
        :assessments_completed,
        :unlocked_invites_count
      ],
      order: ["valid_to DESC, id desc"],
      page: params[:page],
      per: 5
    )
  end
  
  def get_companies
    methods = [
      :subscription_valid_to
    ]
    params[:search] ||= {}
    params[:search] = params[:search].select{|key,val| val.present? }
    order_by = params[:order_by] || "created_at"
    order_type = params[:order_type] || "DESC"
    params[:search].delete :account_type if params[:search][:account_type] == "All"
    search_params = params[:search].dup
    search_params[:account_type] = Vger::Resources::Company::AccountType::PAID
    name = search_params.delete :name
    conditions = {
      :query_options => search_params,
      :page => params[:page],
      :per => 15,
      :order => "#{order_by} #{order_type}",
      :include => [:subscription],
      :methods => methods,
      :select => ['id','name','created_at'],
      :scopes => [:parent_accounts]
    }
    conditions[:scopes] = { :name_like => name } if name

    @companies = Vger::Resources::Company.where(conditions)
  end
end
