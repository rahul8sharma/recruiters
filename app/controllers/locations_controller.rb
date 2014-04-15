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
  
  def get_locations
    @locations = Vger::Resources::Location.where(:query_options => params[:search]).all.to_a
    respond_to do |format|
      format.json{ render :json => { :locations => @locations } }
    end
  end
end
