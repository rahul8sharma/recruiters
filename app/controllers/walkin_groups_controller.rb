class WalkinGroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_company
  
  before_filter :get_walkin_group, :except => [ :index, :create, :new ]
  
  layout "walk_ins"
  
  def index
    @walkin_groups = Vger::Resources::Suitability::WalkinGroup.where(:query_options => {  
                            company_id: @company.id
                          },
                          methods: [:url],
                          page: params[:page],
                          per: 10
                        ).all
  end
  
  def show
  end
  
  def new
    @assessments = Vger::Resources::Suitability::Assessment.where(:query_options => { :company_id => @company.id }, select: ["name","id"], order: ["created_at DESC"]).all
    @walkin_group = Vger::Resources::Suitability::WalkinGroup.new(:company_id => @company.id, :expires_on => Time.now + 24.hours)
  end
  
  def create
    @assessments = Vger::Resources::Suitability::Assessment.where(:query_options => { :company_id => @company.id }, select: ["name","id"]).all
    params[:walkin_group][:assessment_hash].reject!{|assessment_id, assessment_data| assessment_data["enabled"] != "true" }
    @walkin_group = Vger::Resources::Suitability::WalkinGroup.new(params[:walkin_group])
    if @walkin_group.assessment_hash.present? && @walkin_group.save
      redirect_to customize_company_walkin_group_path(@company, @walkin_group)
    else
      @walkin_group.error_messages ||= []
      @walkin_group.error_messages << "Please select at least one assessment." if !@walkin_group.assessment_hash.present?
      flash[:error] = @walkin_group.error_messages.join("<br/>")
      render :action => :new
    end
  end
  
  def customize
    if request.put?
      @walkin_group = Vger::Resources::Suitability::WalkinGroup.save_existing(@walkin_group.id, params[:walkin_group])
      redirect_to summary_company_walkin_group_path(@company, @walkin_group)
    else
    end               
  end
  
  def update
    @walkin_group = Vger::Resources::Suitability::WalkinGroup.save_existing(@walkin_group.id, params[:walkin_group])
    redirect_to company_walkin_group_path(@company, @walkin_group)
  end
  
  def summary
  end
  
  def expire
    @walkin_group = Vger::Resources::Suitability::WalkinGroup.save_existing(@walkin_group.id, {
      :expires_on => Time.now
    })
    redirect_to company_walkin_group_path(@company, @walkin_group), notice: "This Walk-In page is marked as expired now."
  end
  
  protected
  
  def get_company
    methods = []
    if ["show","index", "training_requirements"].include? params[:action]
      if Rails.application.config.statistics[:load_assessmentwise_statistics]
        methods << :assessmentwise_statistics
      end
    end
    @company = Vger::Resources::Company.find(params[:company_id], :methods => methods)
  end
  
  def get_walkin_group  
    @walkin_group = Vger::Resources::Suitability::WalkinGroup.find(params[:id], methods: [:url])
    @walkin_group.expires_on = DateTime.parse(@walkin_group.expires_on) if @walkin_group.expires_on.present?
    @assessments = Vger::Resources::Suitability::Assessment.where(:query_options => { 
                      company_id: @company.id, 
                      id: @walkin_group.assessment_hash.keys
                    }, 
                    select: ["name","id"]
                   ).all.to_a
  end
end
