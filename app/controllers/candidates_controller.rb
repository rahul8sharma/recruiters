class CandidatesController < ApplicationController
  layout "candidates"
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Candidate
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to ENV['HTTP_REFERER'], notice: 'All records deleted'
  end
  
  def import
		Vger::Resources::Candidate.import(params[:file])
		redirect_to candidates_path, notice: "Candidates imported."
	end	
  
  def manage
  end
  
	def import_from_google_drive
    Vger::Resources::Candidate\
      .import_from_google_drive(params[:import])
    redirect_to company_candidates_path(:company_id => params[:company_id]), notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::Candidate\
      .export_to_google_drive(params[:export].merge(:columns => [:email, :authentication_token]))
    redirect_to company_candidates_path(:company_id => params[:company_id]), notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def index
    @candidates = Vger::Resources::Candidate.where(:page => params[:page], :per => 10)
  end

  def show
  end
  
  def upload_bulk
  end

  def upload_single
  end
end
