class TemplateVariablesController < MasterDataController
  before_filter :get_template_categories, only: [:edit, :new]
  before_filter :set_params, only: [:create, :update]
  
  def api_resource
    Vger::Resources::TemplateVariable
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def index_columns
    [
      :id,
      :name,
      :template_category_ids,
      :value
    ]
  end
  
  def search_columns
    [
      :id,
      :name
    ]
  end
  
  def new
    @resource = api_resource.new
    @resource.template_category_ids = []
  end
  
  protected
  
  def get_template_categories
    @template_categories = Vger::Resources::TemplateCategory.all.to_a
  end
  
  def set_params
    params[:template_variable][:template_category_ids] =
            params[:template_variable][:template_category_ids]\
                                                          .split(",")\
                                                          .select(&:present?)\
                                                          .compact\
                                                          .map(&:to_i)
  end
end
