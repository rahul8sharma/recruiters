class CompaniesController < ApplicationController
  before_filter :authenticate_user!
  
  layout "companies" 
  
  def index
    @companies = Vger::Resources::Company.where(:page => params[:page], :per => 5)
  end
  
  def manage
  end
  
	def import_from_google_drive
    Vger::Resources::Company\
      .import_from_google_drive(params[:import])
    redirect_to companies_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::Company\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name","company_code"]))
    redirect_to companies_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def show
    @company = Vger::Resources::Company.find(params[:id])
  end
  
  def candidate
    @company = Vger::Resources::Company.find(params[:id])
  end
  
  def settings
    @company = Vger::Resources::Company.find(params[:id])
  end
  
  def account
    @company = Vger::Resources::Company.find(params[:id])
  end
  
  def company
    @company = Vger::Resources::Company.find(params[:id])
  end
  
  def statistics
    @company = Vger::Resources::Company.find(params[:id])
  end
end
