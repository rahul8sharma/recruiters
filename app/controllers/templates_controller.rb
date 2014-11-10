class TemplatesController < MasterDataController
  before_filter :authenticate_user!
  before_filter :get_template_variables, :only => [:new, :create, :update, :edit]
  
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
      :company_id,
      :category,
      :from,
      :subject,
      :body
    ]
  end
  
  def search_columns
    [
      :id,
      :company_id,
      :name,
      :category
    ]
  end
  
  protected
  
  def get_template_variables
    @template_variables = Vger::Resources::TemplateVariable.all
  end
end
