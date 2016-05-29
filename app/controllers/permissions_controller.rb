class PermissionsController < MasterDataController
  before_filter :get_resources, only: [:new, :edit, :update, :index]
  
  def api_resource
    Vger::Resources::Permission
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :name,
      :action_name,
      :subject_class
    ]
  end
  
  def search_columns
    [
      :id,
      :name,
      :action_name,
      :subject_class
    ]
  end
  
  def select_subject_class
    @resources.sort
  end
  
  def get_resources
    @resources = api_resource.get_raw("/permissions/get_resources", params)[:response].body[:data]
  end
end
