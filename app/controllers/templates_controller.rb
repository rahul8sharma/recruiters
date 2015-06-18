class TemplatesController < MasterDataController
  before_filter :authenticate_user!
  before_filter :get_template_variables, :only => [:new, :create, :update, :edit]
  before_filter :set_params, :only => [:create, :update]
  
  def api_resource
    Vger::Resources::Template
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :name,
      :company_ids,
      :category,
      :from,
      :subject,
      :body
    ]
  end
  
  def search_columns
    [
      :id,
      :company_ids,
      :name,
      :category
    ]
  end
  
  protected
  
  def get_template_variables
    @template_variables = Vger::Resources::TemplateVariable.all
  end
  
  def set_params
    params[:template][:company_ids] = params[:template][:company_ids].to_s.split(",")
  end
end
