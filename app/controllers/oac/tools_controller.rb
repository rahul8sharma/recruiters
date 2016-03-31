class Oac::ToolsController < MasterDataController
  def api_resource
    Vger::Resources::Oac::Tool
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :name, :display_name, :host, :logo,:tutorial_link,:practice_link]
  end
  
  def form_fields
    [
      :name, 
      :display_name,
      :host, 
      :assessment_class, 
      :assessment_type, 
      :user_exercise_type, 
      :report_type, 
      :logo, 
      :description,
      :is_jombay_tool,
      :tutorial_link,
      :practice_link,
      :time_required
    ]
  end
end
