class Suitability::Job::FactorNormsController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def index
    @job_factor_norms = Vger::Resources::Suitability::Job::FactorNorm\
                        .all(:methods => [:factor,
                                          :industry,
                                          :functional_area,
                                          :job_experience
                                          ], :page => params[:page], :per => 10)

    respond_to do | format |
      format.html
      format.csv { render :layout => false }
    end
  end

  def edit
  end

  def import
    Vger::Resources::Suitability::Job::FactorNorm.import(params[:file])
    redirect_to suitability_job_factor_norms_path,
                notice: "Suitability Job Factor Norms imported."
  end
  
  def manage
    @functional_areas = Hash[Vger::Resources::FunctionalArea.all.to_a.collect{|functional_area| [functional_area.id,functional_area.name] }]
    @industries = Hash[Vger::Resources::Industry.all.to_a.collect{|industry| [industry.id,industry.name] }]
    @job_experiences = Hash[Vger::Resources::JobExperience.all.to_a.collect{|job_exp| [job_exp.id,job_exp.display_text] }]
  end
  
  def import_via_s3
    AWS::S3::Base.establish_connection!(Rails.configuration.s3)

    s3_bucket_name = 'master_data'
    s3_key = 'factor_norms.csv.zip'
    
    S3Utils.upload(s3_bucket_name, s3_key, params[:import][:file])
    
    Vger::Resources::Suitability::Job::FactorNorm\
      .import_from_s3(:file => {
                        :bucket => s3_bucket_name,
                        :key => s3_key
                      })
    redirect_to manage_suitability_job_factor_norms_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    if params[:export][:filters].blank? || params[:export][:filters][:industry_id].blank?
      flash[:notice] = "Please select at least one industry"
      redirect_to manage_suitability_job_factor_norms_path and return
    end
    Vger::Resources::Suitability::Job::FactorNorm\
      .export_to_google_drive(params[:export])
    redirect_to manage_suitability_job_factor_norms_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
end
