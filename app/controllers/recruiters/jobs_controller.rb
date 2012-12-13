class Recruiters::JobsController < Recruiters::ApplicationController
  before_filter :init_section, :only => [:edit, :update]
  before_filter :init_status, :only => [:status]
  before_filter :init_master_data, :only => [:edit, :update]

  layout "recruiters/jobs"

  # GET /jobs/<id>
  def show
  end

  # GET /jobs/<id>/preview
  def previews
  end

  # GET /<job-id>/edit/<section:(job_details | company_details | additional_details | hiring_preferences | job_requirements | logistics)>
  def edit
  end

  # GET /<status:(open | pending | closed | incomplete)>
  def status
  end

  private

  # Extract status from url
  def init_status
    @status = params[:status]
  end

  # Extract section name from url
  def init_section
    @section = params[:section].underscore
  end

  def init_master_data
    @master_data = {}
    @master_data.merge! :industries => Vger::Spartan::Opus::Recommendation.industries
    @master_data.merge! :job_categories => Vger::Spartan::Opus::JobCategory.find(:all)
    @master_data.merge! :work_profiles => Vger::Spartan::Opus::Recommendation.work_profiles
  end
end
