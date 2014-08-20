class Mrf::OptionsController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  # GET /options
  def index
    @options = Vger::Resources::Mrf::Option.where(:page => params[:page], :per => 10)
  end

  # GET /options/new
  # GET /options/new.json
  def new
    @option = Vger::Resources::Mrf::Option.new
    respond_to do |format|
      format.html
    end
  end
  
  # GET /options/:id
  # GET /options/:id.json
  def show
    @option = Vger::Resources::Mrf::Option.find(params[:id], :item_id => params[:item_id])
    respond_to do |format|
      format.html
    end
  end

  # GET /options/:id/edit
  # GET /options/:id/edit.json
  def edit
    @option = Vger::Resources::Mrf::Option.find(params[:id], :item_id => params[:item_id])
    respond_to do |format|
      format.html
    end
  end

  # PUT /items/:id
  # PUT /items/:id.json
  def update
    @option = Vger::Resources::Mrf::Option.find(params[:id], :item_id => params[:item_id])
    respond_to do |format|
      if @option.class.save_existing(params[:id], params[:option])
        format.html { redirect_to mrf_item_option_path(params[:trait_id], params[:item_id], params[:id]), notice: 'Mrf Option was successfully updated.' }
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
