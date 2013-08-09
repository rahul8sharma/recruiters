class Suitability::DefaultFactorNormRangesController < ApplicationController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Suitability::DefaultFactorNormRange
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  layout "admin"

  def manage
    @functional_areas = Hash[Vger::Resources::FunctionalArea.all.to_a.collect{|functional_area| [functional_area.id,functional_area.name] }]
    @industries = Hash[Vger::Resources::Industry.all.to_a.collect{|industry| [industry.id,industry.name] }]
    @job_experiences = Hash[Vger::Resources::JobExperience.all.to_a.collect{|job_exp| [job_exp.id,job_exp.display_text] }]
  end

  def import_via_s3
    s3_bucket_name = 'master_data'
    s3_key = 'default_factor_norm_ranges.csv.zip'

    S3Utils.upload(s3_bucket_name, s3_key, params[:import][:file])

    Vger::Resources::Suitability::DefaultFactorNormRange\
      .import_from_s3(:file => {
                        :bucket => s3_bucket_name,
                        :key => s3_key
                      })
    redirect_to manage_suitability_default_factor_norm_ranges_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    if params[:export][:filters].blank? || params[:export][:filters][:industry_id].blank?
      flash[:error] = "Please select at least one industry"
      redirect_to manage_suitability_default_factor_norm_ranges_path and return
    end
    Vger::Resources::Suitability::DefaultFactorNormRange\
      .export_to_google_drive(params[:export])
    redirect_to manage_suitability_default_factor_norm_ranges_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @default_factor_norm_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.where(:methods => [:factor, :functional_area, :industry, :from_norm_bucket, :to_norm_bucket, :job_experience], :page => params[:page], :per => 50).all
  end
end
