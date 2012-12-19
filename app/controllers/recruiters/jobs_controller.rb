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
    @job = Recruiters::Job.find(:uuid => params[:id]).first
  end

  def update
    @job = Recruiters::Job.find(:uuid => params[:id]).first
    @job.update(params.to_hash)
    Rails.logger.ap params.to_hash

    section_keys = Rails.application.config.recruiters[:job_posting_sections].keys
    next_section = section_keys[section_keys.index(params[:section]) + 1]

    # redirect_to recruiters_jobs_path(:id => @job.uuid, :section => next_section)

    redirect_to next_section.present? ? recruiters_jobs_path(:id => @job.uuid, :section => next_section) : preview_recruiters_job(:id => @job.uuid)
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
    @master_data.merge! :skills => Vger::Spartan::Opus::Recommendation.all(:params => {:select => [:id, :name], :query_options => {:bucket_type => "Opus::Skill"}})
    @master_data.merge! :traits => Vger::Spartan::Dilios::Trait.find(:all)
    @master_data.merge! :weekdays => Vger::Spartan::WeekDay.all
    @master_data.merge! :time_slots => Vger::Spartan::Opus::TimeSlot.all
    @master_data.merge! :perks => Vger::Spartan::Opus::JobPerk.all
    @master_data.merge! :kind_of_job => Vger::Spartan::Opus::KindOfJob.all

    degree_diploma = []
    Vger::Spartan::Opus::DegreeType.all.each do |degree|
      degree_diploma.push(Vger::Spartan::Opus::DegreeType.find(degree.id,:params => {:methods => "apex_degrees"}).apex_degrees)
    end
    degree_diploma.flatten!.uniq!

    specializations = []
    degree_diploma.each do |degree|
      specializations.push(Vger::Spartan::Opus::Recommendation.find(degree.id, params: {bucket_methods: [:careers]}).bucket.careers)
    end
    specializations.flatten!.uniq!

    @master_data.merge! :degree_diploma => degree_diploma
    @master_data.merge! :specializations => specializations
  end
end
