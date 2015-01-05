class FormBuilder::DefinedFormsController < MasterDataController
  def api_resource
    Vger::Resources::FormBuilder::DefinedForm
  end

  def index_columns
    [:id, :name, :company_id, :active]
  end

  def import_from
    "import_from_google_drive"
  end

  def search_columns
    [:id, :name, :company_id, :active]
  end
end
