class Mrf::WalkinGroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_company
  
  before_filter :get_walkin_group, :except => [ :index, :create, :new ]
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
    @assessments = Vger::Resources::Mrf::Assessment.where(:query_options => { :company_id => @company.id }, select: ["name","id"]).all
    params[:walkin_group][:assessment_hash].reject!{|assessment_id, assessment_data| assessment_data["enabled"] != "true" }
    @walkin_group = Vger::Resources::Mrf::WalkinGroup.new(params[:walkin_group])
    if @walkin_group.assessment_hash.present? && @walkin_group.save
      redirect_to customize_company_mrf_walkin_group_path(@company, @walkin_group)
    else
      @walkin_group.error_messages ||= []
      @walkin_group.error_messages << "Please select at least one assessment." if !@walkin_group.assessment_hash.present?
      flash[:error] = @walkin_group.error_messages.join("<br/>")
      render :action => :new
    end
  end
  
  def customize
    if request.put?
      @walkin_group = Vger::Resources::Mrf::WalkinGroup.save_existing(@walkin_group.id, params[:walkin_group])
      redirect_to summary_company_mrf_walkin_group_path(@company, @walkin_group)
    else
      get_templates_for_candidates
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
    @assessments = Vger::Resources::Mrf::Assessment.where(
                    company_id: @company.id,   
                    query_options: { 
                      company_id: @company.id, 
                      id: @walkin_group.assessment_hash.keys
                    }, 
                    select: ["name","id"]
                   ).all.to_a
  end
  
  def get_templates_for_candidates
    query_options = {
      category: template_category::SEND_MRF_INVITATION_TO_CANDIDATE
    }
    @candidate_templates = Vger::Resources::Template\
                  .where(
                    query_options: query_options, 
                    scopes: { global_or_for_company_id: @company.id },
                  ).all.to_a
    @candidate_templates |= Vger::Resources::Template\
                  .where(
                    query_options: query_options, 
                    scopes: { global: nil }
                  ).all.to_a
    query_options = {
      category: [
        template_category::SEND_CLASSIC_MRF_INVITATION_TO_STAKEHOLDER_FROM_CANDIDATE,
        template_category::SEND_JOMBAY_MRF_INVITATION_TO_STAKEHOLDER_FROM_CANDIDATE,
      ]
    }              
    @stakeholder_templates = Vger::Resources::Template\
                  .where(
                    query_options: query_options, 
                    scopes: { global_or_for_company_id: @company.id }
                  ).all.to_a
    @stakeholder_templates |= Vger::Resources::Template\
                  .where(
                    query_options: query_options, 
                    scopes: { global: nil }
                  ).all.to_a              
  end
  
  def template_category
    Vger::Resources::Template::TemplateCategory
  end
end
