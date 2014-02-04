class WalkinGroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_company
  
  before_filter :get_assessment_group, :except => [ :index, :create, :new ]
  
  layout "walk_ins"
  
  def index
    @assessment_groups = Vger::Resources::Suitability::WalkinGroup.where(:query_options => {  
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
    @assessment_group = Vger::Resources::Suitability::WalkinGroup.new(:company_id => @company.id, :expires_on => Time.now + 24.hours)
  end
  
  def create
    @assessments = Vger::Resources::Suitability::Assessment.where(:query_options => { :company_id => @company.id }, select: ["name","id"]).all
    params[:assessment_group][:assessment_hash].reject!{|assessment_id, assessment_data| assessment_data["enabled"] != "true" }
    @assessment_group = Vger::Resources::Suitability::WalkinGroup.new(params[:assessment_group])
    if @assessment_group.assessment_hash.present? && @assessment_group.save
      redirect_to customize_company_assessment_group_path(@company, @assessment_group)
    else
      @assessment_group.error_messages ||= []
      @assessment_group.error_messages << "Please select at least one assessment." if !@assessment_group.assessment_hash.present?
      flash[:error] = @assessment_group.error_messages.join("<br/>")
      render :action => :new
    end
  end
  
  def customize
    if request.put?
      @assessment_group = Vger::Resources::Suitability::WalkinGroup.save_existing(@assessment_group.id, params[:assessment_group])
      redirect_to summary_company_assessment_group_path(@company, @assessment_group)
    else
    end               
  end
  
  def update
    @assessment_group = Vger::Resources::Suitability::WalkinGroup.save_existing(@assessment_group.id, params[:assessment_group])
    redirect_to company_assessment_group_path(@company, @assessment_group)
  end
  
  def summary
  end
  
  def expire
    @assessment_group = Vger::Resources::Suitability::WalkinGroup.save_existing(@assessment_group.id, {
      :expires_on => Time.now
    })
    redirect_to company_assessment_group_path(@company, @assessment_group), notice: "This Walk-In page is marked as expired now."
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
  
  def get_assessment_group  
    @assessment_group = Vger::Resources::Suitability::WalkinGroup.find(params[:id], methods: [:url])
    @assessment_group.expires_on = DateTime.parse(@assessment_group.expires_on) if @assessment_group.expires_on.present?
    @assessments = Vger::Resources::Suitability::Assessment.where(:query_options => { 
                      company_id: @company.id, 
                      id: @assessment_group.assessment_hash.keys
                    }, 
                    select: ["name","id"]
                   ).all.to_a
  end
end
