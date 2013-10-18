class CandidatesController < ApplicationController
  layout "candidates"
  before_filter :authenticate_user!
  before_filter :check_superadmin, :except => [:show]

  def api_resource
    Vger::Resources::Candidate
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def manage
    render :layout => "admin"
  end
  
  def import
    Vger::Resources::Candidate\
      .import_from_google_drive(params[:import])
    redirect_to manage_candidates_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end
  
  def export
    Vger::Resources::Candidate\
      .export_to_google_drive(params[:export].merge(:columns => [:email, :authentication_token]))
    redirect_to manage_candidates_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def export_validation_progress
    Vger::Resources::Candidate\
      .export_validation_progress(params[:candidate])
    redirect_to manage_candidates_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def export_candidate_responses
    Vger::Resources::Candidate\
      .export_candidate_responses(params[:candidate])
    redirect_to manage_candidates_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def index
    @candidates = Vger::Resources::Candidate.where(:page => params[:page], :per => 10)
    render :layout => "admin"
  end

  def show
  end

  def upload_bulk
  end

  def upload_single
  end
end
