class LocationsController < MasterDataController
  def api_resource
    Vger::Resources::Location
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :name,
      :location_type,
      :parent_id
    ]
  end
  
  def search_columns
    [
      :id,
      :name,
      :location_type,
      :parent_id
    ]
  end
  
  def select_location_type
    Vger::Resources::Location::LOCATION_TYPES
  end
  
  def get_locations
    @locations = Vger::Resources::Location.where(:order => [:name],:query_options => params[:search]).all.to_a
    respond_to do |format|
      format.json{ render :json => { :locations => @locations } }
    end
  end
end
