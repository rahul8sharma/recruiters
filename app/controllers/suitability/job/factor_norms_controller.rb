class Suitability::Job::FactorNormsController < ApplicationController
  before_filter :authenticate_user!

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def api_resource
    Vger::Resources::Suitability::Job::FactorNorm
  end

  layout "admin"

  def index
    @job_factor_norms = Vger::Resources::Suitability::Job::FactorNorm\
                        .where(:include => [:factor,
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
    s3_bucket_name = 'master_data'
    s3_key = 'factor_norms.csv.zip'
    
    unless params[:import][:file]
      flash[:notice] = "Please select a zip file."
      redirect_to manage_suitability_job_factor_norms_path and return
    end
    data = params[:import][:file].read
    S3Utils.upload(s3_bucket_name, s3_key, data)

    Vger::Resources::Suitability::Job::FactorNorm\
      .import_from_s3(:file => {
                        :bucket => s3_bucket_name,
                        :key => s3_key
                      }, :email => params[:import][:email])
    redirect_to manage_suitability_job_factor_norms_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    #if params[:export][:filters].blank? || params[:export][:filters][:industry_id].blank?
    #  flash[:error] = "Please select at least one industry"
    #  redirect_to manage_suitability_job_factor_norms_path and return
    #end
    params[:export][:filters] ||= {}
    params[:export][:filters][:industry_id] ||= nil
    params[:export][:filters][:functional_area_id] ||= nil
    params[:export][:filters][:job_experience_id] ||= nil
    Vger::Resources::Suitability::Job::FactorNorm\
      .export_to_google_drive(params[:export])
    redirect_to manage_suitability_job_factor_norms_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
end
