class Recruiters::JobsController < Recruiters::ApplicationController
  before_filter :redirect_if_not_logged_in!, :except => [:flush, :show]
  # before_filter :redirect_if_not_logged_in!, :except => [:show], :if => :html_format?
  before_filter :init_section, :only => [:edit, :update]
  before_filter :init_status, :only => [:status]
  before_filter :init_master_data, :only => [:edit, :update]
  before_filter :init_job, :only => [:edit, :preview,
                                     :update, :update_status, :flush]
  before_filter :ensure_flush_perms, :only => [:flush]
  
  layout "recruiters/jobs"
  
  PER_PAGE = 3

  def flush
    respond_to do |format|
      format.json{
        if @job
          @job.delete
          render :json => @job
        else
          render :nothing => true, :status => 404
        end
      }
    end
  end

  # GET /jobs/<id>
  def show

    respond_to do |format|
      format.json{
        if @job
          render :json => @job
        else
          render :nothing => true, :status => 404
        end
      }
      format.html{
        @job = Recruiters::Job.find(:uuid => params[:id]).first
        if @job.blank?
          @job = Vger::Spartan::Opus::Recommendation.find_by_reference_key(params[:id], :params => {:include_related => [:job_category, :company, :work_profile, :degree, :job, :location], :include => {:methods => [:required_skills,:industries,:job_posters,:job_perks,:weekly_offs,:time_slots,:job_types,:recruiters,:eligibility_criteria,:required_academic_qualifications,:eligibility_criteria_with_edge_properties]}})
          render :template => "recruiters/jobs/showleo"
        end
      }
    end
  end

  # GET /jobs/<id>/preview
  def preview
    @section = "preview"
  end

  # GET /<job-id>/edit/<section:(job_details | company_details | additional_details | hiring_preferences | job_requirements | logistics)>
  def edit
    if @job.present? && @job.status.present? && @job.status == Recruiters::Job::STATUSES::INCOMPLETE
      section_keys = Rails.application.config.recruiters[:job_posting_sections].keys
      next_section = section_keys[section_keys.index(params[:section].underscore) + 1]
      @prev_section = (section_keys[section_keys.index(params[:section].underscore) - 1]).dasherize
    else
     redirect_to recruiters_job_path(:id => params[:id])
    end
  end

  def update
    @job.update(params.to_hash)

    if params[:continue_later] == "true"
      redirect_to recruiters_root_path
    else
      section_keys = Rails.application.config.recruiters[:job_posting_sections].keys
      next_section = section_keys[section_keys.index(params[:section].underscore) + 1]

      @prev_section = (section_keys[section_keys.index(params[:section].underscore) - 1]).dasherize
      
      redirect_to (next_section.present? && next_section != "preview") ? recruiters_jobs_path(:id => @job.uuid, :section => next_section.dasherize) : preview_recruiters_job_path(:id => @job.uuid)
    end
  end

  # GET /<status:(open | pending | closed | incomplete)>
  def status
    status = Recruiters::Job::STATUSES[params[:status]]
    if status.present?
      @jobs = Recruiters::Job.find(:status => status, :posted_by => current_user.sid).paginate(:page => 1, :per_page => PER_PAGE)
    elsif params[:status] == "open"
      @jobs = Recruiters::Job.open(current_user.leonidas_resource, {:page => 1, :per_page => PER_PAGE})
    elsif params[:status] == "closed"
      @jobs = Recruiters::Job.closed(current_user.leonidas_resource, {:page => 1, :per_page => PER_PAGE})
    end
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

  def split_arr_by(arr, elem)
    idx = arr.index(elem)
    idx ? [arr[0..idx-1], arr[idx], arr[idx+1..-1]] : nil
  end

  def update_status
    @job.status = Recruiters::Job::STATUSES.const_get(params[:status].upcase)
    @job.save!

    if params[:status] == "pending"
      Vger::Herald::Notification.create(:event => "recruiters/jobpost_pending", :view_params => {:user_ids => [current_user.sid], :job_title => @job.name, :urls => {:post_job => job_posting_recruiters_dashboard_index_url}})
    end

    redirect_to recruiters_root_path
  end

  def duplicate
    @job = Recruiters::Job.find(:uuid => params[:id]).first
    @job.duplicate
  end

  def repost
    @job = Vger::Spartan::Opus::Recommendation.find(params[:id].to_i)
    @job.repost
  end

  private

  def ensure_flush_perms
    key = params[:key] || ''
    unless key == Digest::SHA256.hexdigest("JOMBAYDOTCOM")
      redirect_to recruiters_root_path
    end
  end
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
    send("init_#{ params[:section].underscore }_data")
  end

  def init_job_details_data
    @master_data.merge! :industries => Vger::Spartan::Opus::Recommendation.industries
    @master_data.merge! :job_categories => Vger::Spartan::Opus::JobCategory.find(:all)
    @master_data.merge! :job_profiles => Vger::Spartan::Opus::Recommendation.work_profiles
  end

  def init_job_requirements_data
    degree_diploma = Vger::Spartan::Opus::DegreeType.all.map { |degree|
      Vger::Spartan::Opus::DegreeType.find(degree.id,
                                           :params => {
                                             :methods => "apex_degrees"
                                           }).apex_degrees
    }.flatten.uniq
    
    @master_data.merge! :degree_diploma => degree_diploma
    @master_data.merge! :specializations => Vger::Spartan::Opus::Recommendation.all(:params => {:select => [:id, :name], :query_options => {:bucket_type => "Opus::Career"}})
    @master_data.merge! :skills => Vger::Spartan::Opus::Recommendation.all(:params => {:select => [:id, :name], :query_options => {:bucket_type => "Opus::Skill"}})
  end

  def init_hiring_preferences_data
    @master_data.merge! :industries => Vger::Spartan::Opus::Recommendation.all(:params => {:select => [:id, :name], :query_options => {:bucket_type => "Opus::Industry"}})
    @master_data.merge! :industries => Vger::Spartan::Opus::Recommendation.industries
    @master_data.merge! :traits => Vger::Spartan::Dilios::Trait.find(:all)
    @master_data.merge! :gender => Vger::Spartan::Dilios::Gender.all
    @master_data.merge! :marital_status => Vger::Spartan::Dilios::MaritalStatus.all
  end

  def init_logistics_data
    @master_data.merge! :kind_of_job => Vger::Spartan::Opus::KindOfJob.all
    @master_data.merge! :perks => Vger::Spartan::Opus::JobPerk.all
    @master_data.merge! :time_slots => Vger::Spartan::Opus::TimeSlot.all
    @master_data.merge! :weekdays => Vger::Spartan::WeekDay.all
  end

  def init_additional_details_data
  end

  def init_company_details_data
    @master_data.merge! :company_profile => current_user.leonidas_resource.company
  end

  def init_job
    @job = Recruiters::Job.find(:uuid => params[:id]).first
  end

  # def init_job_struct
  #   @job = OpenStruct.new

  #   @getjob = Recruiters::Job.find(:uuid => params[:id]).first
  #   if @getjob.present?
  #   else
  #     @getjob = Vger::Spartan::Opus::Recommendation.find(22469, :params => {:included_related => [:job_category, :company, :work_profile, :degree, :job, :location], :include => {:methods => [:required_skills,:industries,:job_posters,:job_perks,:weekly_offs,:time_slots,:job_types,:recruiters,:eligibility_criteria]}})
  #   end
  # end
end
