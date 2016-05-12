class Suitability::ItemsController < MasterDataController
  include Suitability::AssessmentsHelper
  
  before_filter :authenticate_user!
  before_filter :get_factors, :only => [ :new, :create, :update, :edit ]
  
  def api_resource
    return Vger::Resources::Suitability::Item
  end
  
  def index_columns
    [:id, :factor_id, :body, :item_order]
  end
  
  def search_columns
    [
      :id,
      :difficulty_level,
      :active,
      :factor_id,
      :body
    ]
  end
  
  def select_difficulty_level
    trait_difficulty_levels
  end
  
  def select_factor_id
    Hash[Vger::Resources::Suitability::Factor.all.map{|factor| [factor.name,factor.id] }]
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  # GET /items/new
  # GET /items/new.json
  def new
    params[:item] ||= {}
    @item = "Vger::Resources::#{params[:item_type]}".constantize.new(params[:item].merge(:active => true))
    respond_to do |format|
      format.html
    end
  end
  
  def add_option
    @option = "Vger::Resources::#{params[:option_type]}".constantize.new(:active => true)
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
    factors |= Vger::Resources::Suitability::LieDetector.all.to_a.collect{|x| [x.name, x.id]}
    @factors = Hash[factors.compact]
  end
end
