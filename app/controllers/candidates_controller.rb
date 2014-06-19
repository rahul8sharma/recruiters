class CandidatesController < ApplicationController
  layout "candidates"
  before_filter :authenticate_user!
  before_filter :check_superadmin
  before_filter :get_master_data, :only => [:edit]

  def api_resource
    Vger::Resources::Candidate
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def index
    params[:order_by] ||= "id"
    params[:order_type] ||= "ASC"
    params[:search] ||= {}
    params[:search] = params[:search].select{|key,val| val.present? }
    @candidates = Vger::Resources::Candidate.where(:page => params[:page], :per => 10, :query_options => params[:search], :order => "#{params[:order_by]} #{params[:order_type]}")
    render :layout => "admin"
  end

  def show
    @candidate = Vger::Resources::Candidate.find(params[:id], methods: [:authentication_token], include: [:industry,:functional_area,:location,:degree])
  end
  
  def update
    @candidate = Vger::Resources::Candidate.save_existing(params[:id],params[:candidate])
    if @candidate.error_messages.present?
      render :action => :edit
    else
      redirect_to candidate_path(@candidate)
    end
  end
  
  def edit
    @candidate = Vger::Resources::Candidate.find(params[:id])
  end
  
  protected
  
  def get_master_data
    @functional_areas = Hash[Vger::Resources::FunctionalArea.all.map{|functional_area| [functional_area.name,functional_area.id] }]
    @industries = Hash[Vger::Resources::Industry.all.map{|industry| [industry.name,industry.id] }]
    @locations = Hash[Vger::Resources::Location.where(:query_options => { :location_type => "city" }).all.map{|location| [location.name,location.id] }]
    @degrees = Hash[Vger::Resources::Degree.all.map{|degree| [degree.name,degree.id] }]
  end
end
