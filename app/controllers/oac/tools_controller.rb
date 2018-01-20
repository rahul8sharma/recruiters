class Oac::ToolsController < MasterDataController
  def api_resource
    Vger::Resources::Oac::Tool
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :name, :display_name,:tutorial_link,:practice_link]
  end
  
  def form_fields
    [
      :name, 
      :display_name,
      :host, 
      :api_assessment_class,
      :api_user_assessment_class,
      :assessment_names,
      :assessment_class, 
      :assessment_type, 
      :user_exercise_type, 
      :report_type, 
      :logo,
      :company_name,
      :about_company, 
      :description,
      :is_jombay_tool,
      :tutorial_link,
      :practice_link,
      :time_required
    ]
  end
end
