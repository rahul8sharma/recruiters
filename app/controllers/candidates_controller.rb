class CandidatesController < ApplicationController
  def import
		Vger::Resources::Candidate.import(params[:file])
		redirect_to candidates_url, notice: "Candidates imported."
	end	
  
  def manage
  end
  
	def import_from_google_drive
    Vger::Resources::Candidate\
      .import_from_google_drive(params[:import])
    redirect_to company_candidates_url(:company_id => params[:company_id]), notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::Candidate\
      .export_to_google_drive(params[:export].merge(:columns => [:email, :authentication_token]))
    redirect_to company_candidates_url(:company_id => params[:company_id]), notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def index
    @candidates = Vger::Resources::Candidate.where(:page => params[:page], :per => params[:per] ||= 2)
  end

  def show
  end
  
  def send_reminder
  end
  
  def add
  end

  def upload_bulk
  end

  def upload_single
  end

  def send_test_to_candidates
  end
  
  def send_test_to_employees
  end
  
  def assessment_report
    respond_to do |format|
      format.html { render :layout => "reports" }
      format.pdf { render :pdf => "report", :layout => "reports.html.haml", :template => "candidates/assessment_report.pdf.haml" }
    end
  end
end
