class CandidatesController < ApplicationController
  layout "candidates"
  before_filter :authenticate_user!
  before_filter :check_superadmin
  before_filter :get_master_data, :only => [:edit]

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
  
  def export_candidate_reports
    Vger::Resources::Candidate\
      .export_candidate_reports(params[:candidate])
    redirect_to manage_candidates_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def export_candidate_report_urls
    Vger::Resources::Candidate\
      .export_candidate_report_urls(params[:candidate])
    redirect_to manage_candidates_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def index
    @candidates = Vger::Resources::Candidate.where(:page => params[:page], :per => 10)
    render :layout => "admin"
  end

  def show
    @candidate = Vger::Resources::Candidate.find(params[:id], methods: [:authentication_token], include: [:industry,:functional_area,:location,:degree])
  end
  
  def update
    @candidate = Vger::Resources::Candidate.save_existing(params[:id],params[:candidate])
    if @candidate.error_messages.present?
      render :action => :edit
    else
      redirect_to candidate_path(@candidate)
    end
  end
  
  def edit
    @candidate = Vger::Resources::Candidate.find(params[:id])
  end
  
  def assessment_link
    @candidate = Vger::Resources::Candidate.find(params[:id])
    @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(
      :assessment_id => params[:assessment_id],
      :query_options => {
        :candidate_id => params[:id]
      },
      :methods => [:url]
    ).all.first
    if @candidate_assessment
    else
      flash[:error] = "Candidate Assessment not found."
      redirect_to candidate_path(params[:id])
    end
  end
  
  def generate_assessment_link
    redirect_to assessment_link_candidate_path(params[:id],params[:assessment_id])
  end
  
  def deactivate_assessment_link
    @candidate = Vger::Resources::Candidate.find(params[:id])
    @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(
      :assessment_id => params[:assessment_id],
      :query_options => {
        :candidate_id => params[:id]
      },
      :methods => [:url]
    ).all.first
    if @candidate_assessment
      @invitation = Vger::Resources::Invitation.save_existing(@candidate_assessment.invitation_id, :status => Vger::Resources::Invitation::Status::EXPIRED)
      if @invitation.error_messages.present?
        flash[:error] = @invitation.error_messages.join("<br/>").html_safe
        redirect_to candidate_path(params[:id])
      else
        flash[:notice] = "Candidate Assessment Link deactivated successfully."
        redirect_to candidate_path(params[:id])
      end
    else
      flash[:error] = "Candidate Assessment not found."
      redirect_to candidate_path(params[:id])
    end
  end
  
  def update_candidate_stage
    @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(
      :assessment_id => params[:assessment_id],
      :query_options => {
        :candidate_id => params[:id]
      },
      :methods => [:url]
    ).all.first
    if @candidate_assessment
      @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.save_existing(@candidate_assessment.id, 
        :assessment_id => params[:assessment_id],
        :candidate_stage => params[:candidate_stage]
      )
      if @candidate_assessment.error_messages.present?
        flash[:error] = @candidate_assessment.error_messages.join("<br/>").html_safe
        redirect_to candidate_path(params[:id])
      else
        flash[:notice] = "Candidate type successfully updated to '#{params[:candidate_stage]}'."
        redirect_to candidate_path(params[:id])
      end
    else
      flash[:error] = "Candidate Assessment not found."
      redirect_to candidate_path(params[:id])
    end
  end

  protected
  
  def get_master_data
    @functional_areas = Hash[Vger::Resources::FunctionalArea.all.map{|functional_area| [functional_area.name,functional_area.id] }]
    @industries = Hash[Vger::Resources::Industry.all.map{|industry| [industry.name,industry.id] }]
    @locations = Hash[Vger::Resources::Location.where(:query_options => { :location_type => "city" }).all.map{|location| [location.name,location.id] }]
    @degrees = Hash[Vger::Resources::Degree.all.map{|degree| [degree.name,degree.id] }]
  end
end
