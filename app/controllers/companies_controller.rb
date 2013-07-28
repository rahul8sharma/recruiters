class CompaniesController < ApplicationController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Company
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  layout "companies"

  before_filter :get_company, :only => [ :show, :candidate, :settings, :account, :company, :statistics]

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

  end

  def candidate
  end

  def settings
  end

  def account
  end

  def company
  end

  def statistics
  end


  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:id])
  end
end

