class UsersManagementController < ApplicationController
  layout "users"
  before_filter :authenticate_user!
  before_filter :check_superuser
  before_filter :get_master_data, :only => [:edit]

  def manage
    render :layout => "admin"
  end

  def import
    Vger::Resources::User\
      .import_from_google_drive(params[:import])
    redirect_to manage_users_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export
    Vger::Resources::User\
      .export_to_google_drive(params[:export].merge(:columns => [:email, :authentication_token]))
    redirect_to manage_users_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def export_validation_progress
    Vger::Resources::User\
      .export_validation_progress(params[:user])
    redirect_to manage_users_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def export_user_responses
    Vger::Resources::User\
      .export_user_responses(params[:user])
    redirect_to manage_users_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def export_user_reports
    Vger::Resources::User\
      .export_user_reports(params[:user])
    redirect_to manage_users_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def export_user_report_urls
    Vger::Resources::User\
      .export_user_report_urls(params[:user])
    redirect_to manage_users_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def download_pdf_reports
    params[:user][:args][:user_id] = current_user.id
    if params[:user][:args][:file]
      flash[:notice] = "Please select a file."
      data = params[:user][:args][:file].read
      now = Time.now
      s3_key = "report_urls/#{now.strftime('%d_%m_%Y_%H_%I')}"
      obj = S3Utils.upload(s3_key, data)
      params[:user][:args].merge!({
                :file => {
                        :bucket => obj.bucket.name,
                        :key => obj.key
                      }})

    end
    Vger::Resources::User\
      .download_pdf_reports(params[:user])

    redirect_to manage_users_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def send_360_invitations_to_users
    Vger::Resources::Mrf::Assessment.resend_invitations(
        company_id: params[:user][:args][:company_id],
        id: params[:user][:args][:mrf_assessment_id],
        )
    Vger::Resources::Mrf::Assessment.send_invitations(
      company_id: params[:user][:args][:company_id],
      id: params[:user][:args][:mrf_assessment_id])

    redirect_to manage_users_path, notice: "Invitation Emails have been queued."
  end

  def export_assessments_factor_scores
    if params[:user][:args][:folder][:url].blank?
      flash[:error] = "Please enter required details"
      redirect_to request.env['HTTP_REFERER'] and return
    end
    args = params[:user][:args].merge!({
      user_id: current_user.id
    })
    Vger::Resources::User\
      .export_user_responses(params[:user])
    redirect_to manage_users_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def import_assessments_factor_scores
    unless params[:import][:file]
      flash[:notice] = "Please select a zip file."
      redirect_to request.env['HTTP_REFERER'] and return
    end
    data = params[:import][:file].read
    now = Time.now
    s3_key = "assessments_factor_scores/#{now.strftime('%d_%m_%Y_%H_%I')}"
    obj = S3Utils.upload(s3_key, data)

    Vger::Resources::User\
      .export_user_responses(
                      params[:user].merge({
                        :args => {
                          :file => {
                            :bucket => obj.bucket.name,
                            :key => obj.key
                          }, 
                          :user_id => current_user.id,
                          :override_overall_scores => params[:import][:override_overall_scores].present?,
                          :override_competency_scores => params[:import][:override_competency_scores].present?,
                          :email => params[:import][:email]
                        }
                      })
                    )
    redirect_to manage_users_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end
  
  def import_user_scores
    unless params[:import][:file]
      flash[:notice] = "Please select a zip file."
      redirect_to request.env['HTTP_REFERER'] and return
    end
    data = params[:import][:file].read
    now = Time.now
    s3_key = "user_scores/#{now.strftime('%d_%m_%Y_%H_%I')}"
    obj = S3Utils.upload(s3_key, data)

    Vger::Resources::User\
      .import_user_scores(
                      :file => {
                        :bucket => obj.bucket.name,
                        :key => obj.key
                      }, 
                      :user_id => current_user.id,
                      :assessment_id => params[:import][:assessment_id], 
                      :override_overall_scores => params[:import][:override_overall_scores].present?,
                      :override_competency_scores => params[:import][:override_competency_scores].present?,
                      :email => params[:import][:email]
                    )
    redirect_to manage_users_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def assessment_link
    @user = Vger::Resources::User.find(params[:id])
    @user_assessment = Vger::Resources::Suitability::UserAssessment.where(
      :assessment_id => params[:assessment_id],
      :query_options => {
        :user_id => params[:id]
      },
      :methods => [:url]
    ).all.first
    if @user_assessment
    else
      flash[:error] = "User Assessment not found."
      redirect_to user_path(params[:id])
    end
  end

  def generate_assessment_link
    redirect_to assessment_link_user_path(params[:id],params[:assessment_id])
  end

  def deactivate_assessment_link
    @user = Vger::Resources::User.find(params[:id])
    @user_assessment = Vger::Resources::Suitability::UserAssessment.where(
      :assessment_id => params[:assessment_id],
      :query_options => {
        :user_id => params[:id]
      },
      :methods => [:url]
    ).all.first
    if @user_assessment
      @invitation = Vger::Resources::Invitation.save_existing(@user_assessment.invitation_id, :status => Vger::Resources::Invitation::Status::EXPIRED)
      if @invitation.error_messages.present?
        flash[:error] = @invitation.error_messages.join("<br/>").html_safe
        redirect_to user_path(params[:id])
      else
        flash[:notice] = "User Assessment Link deactivated successfully."
        redirect_to user_path(params[:id])
      end
    else
      flash[:error] = "User Assessment not found."
      redirect_to user_path(params[:id])
    end
  end

  def update_user_stage
    @user_assessment = Vger::Resources::Suitability::UserAssessment.where(
      :assessment_id => params[:assessment_id],
      :query_options => {
        :user_id => params[:id]
      },
      :methods => [:url]
    ).all.first
    if @user_assessment
      @user_assessment = Vger::Resources::Suitability::UserAssessment.save_existing(@user_assessment.id,
        :assessment_id => params[:assessment_id],
        :candidate_stage => params[:candidate_stage]
      )
      if @user_assessment.error_messages.present?
        flash[:error] = @user_assessment.error_messages.join("<br/>").html_safe
        redirect_to user_path(params[:id])
      else
        flash[:notice] = "User type successfully updated to '#{params[:candidate_stage]}'."
        redirect_to user_path(params[:id])
      end
    else
      flash[:error] = "User Assessment not found."
      redirect_to user_path(params[:id])
    end
  end

  def update_user_assessments
    if params[:assessment_id].blank?
      flash[:error] = "Please select proper Assessment ID"
      redirect_to manage_users_path() and return
    end
    Vger::Resources::Suitability::UserAssessment.update_all(:assessment_id => params[:assessment_id], :query_options => {:assessment_id => params[:assessment_id]}, :update_attributes => {:candidate_stage => params[:candidate_stage]})
    flash[:notice] = "Updated user type to '#{params[:candidate_stage]}' for assessment with id '#{params[:assessment_id]}'"
    redirect_to manage_users_path()
  end

  protected

  def get_master_data
    @functional_areas = Hash[Vger::Resources::FunctionalArea.all.map{|functional_area| [functional_area.name,functional_area.id] }]
    @industries = Hash[Vger::Resources::Industry.all.map{|industry| [industry.name,industry.id] }]
    @locations = Hash[Vger::Resources::Location.where(:query_options => { :location_type => "city" }).all.map{|location| [location.name,location.id] }]
    @degrees = Hash[Vger::Resources::Degree.all.map{|degree| [degree.name,degree.id] }]
  end
end
