class PlansController < MasterDataController
  skip_before_filter :authenticate_user!
  
  def api_resource
    Vger::Resources::Plan
  end

  def import_from
    "import_from_google_drive"
  end

  def import_from_google_drive
    Vger::Resources::Plan\
      .import_from_google_drive(params[:import])
    redirect_to manage_plans_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Plan\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name","no_of_assessments", "description", "price", "validity_in_months"]))
    redirect_to manage_plans_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
end
