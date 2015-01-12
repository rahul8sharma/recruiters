class TeamsController < MasterDataController
  def api_resource
    Vger::Resources::Team
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [
      :id,
      :name,
      :uid,
      :company_id
    ]
  end

end
