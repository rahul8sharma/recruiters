class Mrf::WalkinGroupsController < ApplicationController
  include TemplatesHelper
  before_action :authenticate_user!
  before_action :get_company
  
  before_action :get_walkin_group, :except => [ :index, :create, :new ]
  before_action :get_templates_for_users, :only => [:edit]
  layout "walk_ins"
  
  def index
    order_by = params[:order_by] || "created_at"
    params[:order_by] ||= order_by
    order_type = params[:order_type] || "DESC"
    @walkin_groups = Vger::Resources::Mrf::WalkinGroup.where(:query_options => {  
                            company_id: @company.id
                          },
                          methods: [:url],
                          order: "#{order_by} #{order_type}",
                          page: params[:page],
                          per: 10
                        ).all
  end
  
  def show
  end
  
  def new
    @assessments = Vger::Resources::Mrf::Assessment.where(
                      :company_id => @company.id,     
                      :query_options => { 
                        :company_id => @company.id 
                      }, 
                      select: ["name","id"], 
                      order: ["created_at DESC"]
                    ).all
    @walkin_group = Vger::Resources::Mrf::WalkinGroup.new(:company_id => @company.id, :expires_on => Time.now + 24.hours)
  end
  
  def create
    @walkin_group = Vger::Resources::Mrf::WalkinGroup.new(params[:walkin_group])
    if @walkin_group.save
      redirect_to customize_company_mrf_walkin_group_path(@company, @walkin_group)
    else
      @assessments = Vger::Resources::Mrf::Assessment.where(
        :company_id => @company.id,
        :query_options => { :company_id => @company.id }, select: ["name","id"]
      ).all
      @walkin_group.error_messages ||= []
      @walkin_group.error_messages << "Please select at least one assessment." if !@walkin_group.assessment_id.present?
      flash[:error] = @walkin_group.error_messages.join("<br/>")
      render :action => :new
    end
  end
  
  def customize
    if request.put?
      @walkin_group = Vger::Resources::Mrf::WalkinGroup.save_existing(@walkin_group.id, params[:walkin_group])
      redirect_to summary_company_mrf_walkin_group_path(@company, @walkin_group)
    else
      get_templates_for_users
    end               
  end
  
  def update
    @walkin_group = Vger::Resources::Mrf::WalkinGroup.save_existing(@walkin_group.id, params[:walkin_group])
    redirect_to company_mrf_walkin_group_path(@company, @walkin_group)
  end
  
  def summary
  end
  
  def expire
    @walkin_group = Vger::Resources::Mrf::WalkinGroup.save_existing(@walkin_group.id, {
      :expires_on => Time.now
    })
    redirect_to company_mrf_walkin_group_path(@company, @walkin_group), notice: "This Walk-In page is marked as expired now."
  end
  
  protected
  
  def get_company
    methods = []
    @company = Vger::Resources::Company.find(params[:company_id], :methods => methods)
  end
  
  def get_walkin_group  
    @walkin_group = Vger::Resources::Mrf::WalkinGroup.find(params[:id], methods: [:url])
    @walkin_group.expires_on = DateTime.parse(@walkin_group.expires_on) if @walkin_group.expires_on.present?
    @assessment = Vger::Resources::Mrf::Assessment.find(
                    @walkin_group.assessment_id, {
                      company_id: @company.id,   
                      select: ["name","id"]
                    }
                   )
  end
  
  def get_templates_for_users
    query_options = {
      "template_categories.name" => template_category::SEND_MRF_INVITATION_TO_CANDIDATE
    }
    @user_templates = get_templates_for_company(query_options, @company.id)
    @user_templates |= get_global_templates(query_options)
    query_options = {
      "template_categories.name" => [
        template_category::SEND_CLASSIC_MRF_INVITATION_TO_STAKEHOLDER_FROM_CANDIDATE,
        template_category::SEND_JOMBAY_MRF_INVITATION_TO_STAKEHOLDER_FROM_CANDIDATE,
      ]
    }              
    @stakeholder_templates = get_templates_for_company(query_options, @company.id)
    @stakeholder_templates |= get_global_templates(query_options)            
  end
  
  def template_category
    Vger::Resources::Template::TemplateCategory
  end
end
