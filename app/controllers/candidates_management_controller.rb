class CandidatesManagementController < ApplicationController
  layout "candidates"
  before_filter :authenticate_user!
  before_filter :check_superadmin
  before_filter :get_master_data, :only => [:edit]

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

  def send_360_invitations_to_candidates
    Vger::Resources::Mrf::Assessment.resend_invitations(
        company_id: params[:candidate][:args][:company_id],
        id: params[:candidate][:args][:mrf_assessment_id],
        )
    Vger::Resources::Mrf::Assessment.send_invitations(
      company_id: params[:candidate][:args][:company_id],
      id: params[:candidate][:args][:mrf_assessment_id])

    redirect_to manage_candidates_path, notice: "Invitation Emails have been queued."
  end


  def import_candidate_scores
    unless params[:import][:file]
      flash[:notice] = "Please select a zip file."
      redirect_to request.env['HTTP_REFERER'] and return
    end
    data = params[:import][:file].read
    now = Time.now
    s3_key = "candidate_scores/#{now.strftime('%d_%m_%Y_%H_%I')}"
    obj = S3Utils.upload(s3_key, data)

    Vger::Resources::Candidate\
      .import_candidate_scores(
                      :file => {
                        :bucket => obj.bucket.name,
                        :key => obj.key
                      }, 
                      :assessment_id => params[:import][:assessment_id], 
                      :override_overall_scores => params[:import][:override_overall_scores].present?,
                      :override_competency_scores => params[:import][:override_competency_scores].present?,
                      :email => params[:import][:email]
                    )
    redirect_to manage_candidates_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
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

  def update_candidate_assessments
    if params[:assessment_id].blank?
      flash[:error] = "Please select proper Assessment ID"
      redirect_to manage_candidates_path() and return
    end
    Vger::Resources::Suitability::CandidateAssessment.update_all(:assessment_id => params[:assessment_id], :query_options => {:assessment_id => params[:assessment_id]}, :update_attributes => {:candidate_stage => params[:candidate_stage]})
    flash[:notice] = "Updated candidate type to '#{params[:candidate_stage]}' for assessment with id '#{params[:assessment_id]}'"
    redirect_to manage_candidates_path()
  end

  protected

  def get_master_data
    @functional_areas = Hash[Vger::Resources::FunctionalArea.all.map{|functional_area| [functional_area.name,functional_area.id] }]
    @industries = Hash[Vger::Resources::Industry.all.map{|industry| [industry.name,industry.id] }]
    @locations = Hash[Vger::Resources::Location.where(:query_options => { :location_type => "city" }).all.map{|location| [location.name,location.id] }]
    @degrees = Hash[Vger::Resources::Degree.all.map{|degree| [degree.name,degree.id] }]
  end
end
