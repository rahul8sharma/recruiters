class Suitability::Job::FactorNormsController < ApplicationController
	before_filter :authenticate_user!
	
  layout "admin"
  
  def index
    @job_factor_norms = Vger::Resources::Suitability::Job::FactorNorm\
                        .all(:methods => [:suitability_factor,
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
		redirect_to suitability_job_factor_norms_url,
                notice: "Suitability Job Factor Norms imported."
  end
  
  def manage
  end
  
	def import_from_google_drive
    Vger::Resources::Suitability::Job::FactorNorm\
      .import_from_google_drive(params[:import])
    redirect_to suitability_job_factor_norms_url, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::Suitability::Job::FactorNorm\
      .export_to_google_drive(params[:export].merge(:columns => ["id","factor_id","functional_area_id","industry_id","job_experience_id","norm_value","std_dev"]))
    redirect_to suitability_job_factor_norms_url, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
end
