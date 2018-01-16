class PartnerFieldMappingsController < MasterDataController
  def api_resource
    Vger::Resources::PartnerFieldMapping
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    return [:id, :field_name,:partner_field_name, :partner_name]
  end
  
  def search_columns
    [
      :id,
      :field_name,
      :partner_field_name, 
      :partner_name
    ]
  end
end
