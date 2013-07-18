class Suitability::OptionsController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def import
    Vger::Resources::Suitability::Option.import(params[:file])
    redirect_to options_path, notice: "Suitability Options imported."
  end  

  # GET /options
  def index
    @options = Vger::Resources::Suitability::Option.where(:page => params[:page], :per => 10)
  end

  # GET /options/new
  # GET /options/new.json
  def new
    @option = Vger::Resources::Suitability::Option.new
    respond_to do |format|
      format.html
    end
  end
  
  # GET /options/:id
  # GET /options/:id.json
  def show
    @option = Vger::Resources::Suitability::Option.find(params[:id], :factor_id => params[:factor_id], :item_id => params[:item_id], :methods => [:option_type])
    respond_to do |format|
      format.html
    end
  end

  # GET /options/:id/edit
  # GET /options/:id/edit.json
  def edit
    @option = Vger::Resources::Suitability::Option.find(params[:id], :factor_id => params[:factor_id], :item_id => params[:item_id], :methods => [:option_type])
    respond_to do |format|
      format.html
    end
  end

  # POST /options
  # POST /options.json
  def create
    @option = "Vger::Resources::#{params[:option][:option_type]}".constantize.new(params[:option])
    respond_to do |format|
      if @option.save
        format.html { redirect_to suitability_factor_item_option_path(params[:factor_id],params[:item_id], @option), notice: 'Suitability Option was successfully created.' }
        format.js
        format.json { render json: @option, status: :created, location: @option }
      else
        format.html { render action: "new" }
        format.js
        format.json { render json: @option.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PUT /items/:id
  # PUT /items/:id.json
  def update
    @option = "Vger::Resources::#{params[:option][:option_type]}".constantize.find(params[:id], :factor_id => params[:factor_id], :item_id => params[:item_id])
    respond_to do |format|
      if @option.class.save_existing(params[:id], params[:option])
        format.html { redirect_to suitability_factor_item_option_path(params[:factor_id], params[:item_id], params[:id]), notice: 'Suitability Option was successfully updated.' }
        format.js
        format.json { render json: @option, status: :created, location: @option }
      else
        format.html { render action: "edit" }
        format.js
        format.json { render json: @option.errors, status: :unprocessable_entity }
      end
    end
  end
end
