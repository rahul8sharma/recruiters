class FormBuilder::DefinedFormsController < MasterDataController
  before_action :set_params, :only => [:create, :update]
  
  def replicate
    Vger::Resources::FormBuilder::DefinedForm\
      .replicate(
        :company_id => params[:company_id],
        :defined_form_id => params[:defined_form_id]
      )
    redirect_to manage_form_builder_defined_forms_path, 
      notice: "Replica of the specified form id will be created. Email notification should arrive as soon as the replication is complete."
  end
  
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
    {
      :id => { 
        column: :id
      },
      :name => { 
        column: :name 
      },
      :company_id => { 
        column: "companies.id",
        joins: :companies
      },
      :active => { 
        column: :active 
      }
    }
  end
  
  
  def show
    @resource = api_resource.find(params[:id], :methods => form_fields)
    @container = params[:container]
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  protected
  
  def set_params
    params[:form_builder_defined_form][:company_ids] = params[:form_builder_defined_form][:company_ids].to_s.split(",")
  end
end
