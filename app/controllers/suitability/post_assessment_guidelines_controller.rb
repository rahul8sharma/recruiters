class Suitability::PostAssessmentGuidelinesController < ApplicationController
  before_filter :authenticate_user!

  layout "admin"

  def api_resource
    Vger::Resources::Suitability::PostAssessmentGuideline
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def manage
    @functional_areas = Hash[Vger::Resources::FunctionalArea.all.to_a.collect{|functional_area| [functional_area.id,functional_area.name] }]
    @industries = Hash[Vger::Resources::Industry.all.to_a.collect{|industry| [industry.id,industry.name] }]
    @job_experiences = Hash[Vger::Resources::JobExperience.all.to_a.collect{|job_exp| [job_exp.id,job_exp.display_text] }]
  end

  def import_from_google_drive
    Vger::Resources::Suitability::PostAssessmentGuideline\
      .import_from_google_drive(params[:import])
    redirect_to suitability_post_assessment_guidelines_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end
  
  def import_via_s3
    s3_bucket_name = 'master_data'
    s3_key = 'suitability_post_assessment_guidelines.csv.zip'
    
    unless params[:import][:file]
      flash[:notice] = "Please select a zip file."
      redirect_to manage_suitability_post_assessment_guidelines_path and return
    end
    data = params[:import][:file].read
    S3Utils.upload(s3_bucket_name, s3_key, data)

    Vger::Resources::Suitability::PostAssessmentGuideline\
      .import_from_s3(:file => {
                        :bucket => s3_bucket_name,
                        :key => s3_key
                      }, :email => params[:import][:email])
    redirect_to manage_suitability_post_assessment_guidelines_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    params[:export][:filters] ||= {}
    params[:export][:filters][:functional_area_id] ||= nil
    params[:export][:filters][:job_experience_id] ||= nil
    Vger::Resources::Suitability::PostAssessmentGuideline\
      .export_to_google_drive(params[:export])
    redirect_to manage_suitability_post_assessment_guidelines_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @post_assessment_guidelines = Vger::Resources::Suitability::PostAssessmentGuideline.where(:page => params[:page], :per => 50, :methods => [:factor]).all
  end
end
