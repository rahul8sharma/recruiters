class Exit::ItemGroupsController < MasterDataController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Exit::ItemGroup
  end
  
  def index_columns
    [:id, :body, :active]
  end

  def import_with_options_from_google_drive
    errors = Vger::Resources::Exit::ItemGroup.import_with_options_from_google_drive(params[:item_group])
    redirect_to manage_exit_item_groups_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def import_from
    "import_from_google_drive"
  end
end
