class Suitability::ItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_factors, :only => [ :new, :create, :update, :edit ]
  
  layout "admin"
  
  # GET /items
  def index
    @items = Vger::Resources::Suitability::Item.where(:page => params[:page], :per => 10)
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @item = "Vger::Resources::#{params[:item_type]}".constantize.new(params[:item])
    respond_to do |format|
      format.html
    end
  end
  
  def add_option
    @option = "Vger::Resources::#{params[:option_type]}".constantize.new
    respond_to do |format|
      format.js
    end
  end
  
  # GET /items/:id
  # GET /items/:id.json
  def show
    @item = Vger::Resources::Suitability::Item.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  # GET /items/:id
  # GET /items/:id.json
  def edit
    @item = Vger::Resources::Suitability::Item.find(params[:id], :methods => [:item_type])
    respond_to do |format|
      format.html
    end
  end

  # POST /items
  # POST /items.json
  def create
    @item = "Vger::Resources::#{params[:item][:item_type]}".constantize.new(params[:item])
    respond_to do |format|
      if @item.save
        format.html { redirect_to suitability_item_path(@item), notice: 'Suitability Item was successfully created.' }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PUT /items/:id
  # PUT /items/:id.json
  def update
    @item = "Vger::Resources::#{params[:item][:item_type]}".constantize.find(params[:id])
    respond_to do |format|
      if @item.class.save_existing(params[:id], params[:item])
        format.html { redirect_to suitability_item_path(params[:id]), notice: 'Suitability Item was successfully updated.' }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end
  
  protected
  
  def get_factors
    factors = Vger::Resources::Suitability::Factor.all.to_a.collect{|x| [x.name, x.id]}  
    factors |= Vger::Resources::Suitability::AlarmFactor.all.to_a.collect{|x| [x.name, x.id]}
    factors |= Vger::Resources::Suitability::DirectPredictor.all.to_a.collect{|x| [x.name, x.id]}
    @factors = Hash[factors.compact]
    @item_groups = Vger::Resources::Suitability::ItemGroup.all.to_a.collect{|x| [x.body, x.id]}  
  end
end
