class CompaniesController < ApplicationController
  def index
  end
  
  def manage
  end
  
	def import_from_google_drive
    Vger::Resources::Company\
      .import_from_google_drive(params[:import])
    redirect_to companies_url, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::Company\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name","company_code"]))
    redirect_to companies_url, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def show
  end
  
  def settings
  end
  
  def account
  end
  
  def company
  end
  
  def statistics
  end
end
