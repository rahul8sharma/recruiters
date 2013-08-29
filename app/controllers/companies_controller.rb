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

  before_filter :get_company, :except => [ :index, :manage, :import_from_google_drive, :import_to_google_drive]

  def index
    @companies = Vger::Resources::Company.where(:page => params[:page], :per => 5, :methods => [ :subscription, :assessmentwise_statistics ])
  end

  def manage
    render :layout => "admin"
  end

	def import_from_google_drive
    Vger::Resources::Company\
      .import_from_google_drive(params[:import])
    redirect_to manage_companies_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::Company\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name","company_code", "website", "hq_address"]))
    redirect_to manage_companies_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def show
    if @company.hq_location_id
      @hq_location = Vger::Resources::Location.find(@company.hq_location_id, :methods => [ :address ])
    end
  end

  def candidate
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:id], :methods => [ :subscription, :assessment_statistics ])
  end
end

