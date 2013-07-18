class Suitability::DefaultFactorNormRangesController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def manage
  end

  def import_via_s3
    AWS::S3::Base.establish_connection!(Rails.configuration.s3)

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
    Vger::Resources::Suitability::DefaultFactorNormRange\
      .export_to_google_drive(params[:export])
    redirect_to manage_suitability_default_factor_norm_ranges_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  # GET /factors
  def index
    @default_factor_norm_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.where(:page => params[:page], :per => 50).all
  end
end
