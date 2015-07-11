class FormBuilder::DefinedFormsController < MasterDataController
  before_filter :set_params, :only => [:create, :update]
  
  def api_resource
    Vger::Resources::FormBuilder::DefinedForm
  end

  def index_columns
    [:id, :name, :company_ids, :active]
  end

  def import_from
    "import_from_google_drive"
  end

  def search_columns
    [:id, :name, :active]
  end
  
  protected
  
  def set_params
    params[:form_builder_defined_form][:company_ids] = params[:form_builder_defined_form][:company_ids].to_s.split(",")
  end
end
