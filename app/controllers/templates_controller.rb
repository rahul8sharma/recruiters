class TemplatesController < MasterDataController
  before_filter :authenticate_user!
  before_filter :get_template_variables, :only => [:new, :create, :update, :edit]
  before_filter :get_categories, :only => [:new, :create, :update, :edit]
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
      :template_category_id,
      :from,
      :subject
    ]
  end
  
  def search_columns
    [
      :id,
      :name,
      :template_category_id
    ]
  end
  
  protected
  
  def select_category
    Vger::Resources::Template::TEMPLATE_CATEGORIES.sort
  end
  
  def get_template_variables
    @template_variables = Vger::Resources::TemplateVariable.all
  end
  
  def get_categories
    @template_categories = Vger::Resources::TemplateCategory.all
  end
  
  def set_params
    params[:template][:company_ids] = params[:template][:company_ids].to_s.split(",")
  end
end
