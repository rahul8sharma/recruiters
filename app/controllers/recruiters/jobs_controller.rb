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

  # GET /recommendations/traversable_from/:id
  # Used in edit profile pages to fetch skills/job profiles for a job category
  def traversable_from
    source_node_id = "Vger::Spartan::#{params[:source_class]}".constantize\
      .find(params[:id]).node_id
    
    recommendations = Vger::Spartan::Opus::Recommendation\
      .traverse({
                  :source_nodes => [
                                    {
                                      "id" => source_node_id,
                                      "relationship" => params[:relation]
                                    }
                                   ],
                  :options => {
                    "bucket_type" => params[:bucket_type]
                  },
                  :order => "name ASC",
                  :without_cache => true,
                  :plain_fetch => true
                })

    respond_to do |format|
      format.json { render json: recommendations }
    end
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
    @master_data.merge! :job_profiles => Vger::Spartan::Opus::Recommendation.work_profiles
    @master_data.merge! :gender => Vger::Spartan::Dilios::Gender.all
    @master_data.merge! :marital_status => Vger::Spartan::Dilios::MaritalStatus.all
    # @master_data.merge! :skills => ["beginner", "average", "good", "very good"]
  end
end
