class JobExperiencesController < MasterDataController
  def api_resource
    Vger::Resources::JobExperience
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :active,
      :display_text,
      :min,
      :max
    ]
  end

end
