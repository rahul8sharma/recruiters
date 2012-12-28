class Recruiters::CandidatesController < Recruiters::ApplicationController
  before_filter :init_job, :only => [:index, :show]

  caches_action :show, {
    :tags => [:candidates_show],
    :cache_path => Proc.new {
      application = Vger::Spartan::Opus::Jobs::Application\
        .find(params[:id], :params => {
                :select => [:id, :updated_at]
              })
      
      [
       :recruiters,
       :candidates_show,
       application.id,
       application.updated_at.to_i,
      ].join("/")
    }, :layout => false
  }
  
  PER_PAGE = 10
  # GET /jobs/<id>/candidates
  def index
    @applications = Vger::Spartan::Opus::Jobs::Application.paginate(
                                                                    :all,
                                                                    :params => {
                                                                      :job => @job.id,
                                                                      :min_rating => params[:starred] == true.to_s ? 1 : 0
                                                                    },
                                                                    :page => params[:page],
                                                                    :per_page => PER_PAGE
                                                                    )
  end
  
  # GET /jobs/<job_id>/candidates/<candidate_id>
  def show
    @application = Vger::Spartan::Opus::Jobs::Application.find(
                                                               params[:id],
                                                               :params => {
                                                                 :user_profile_info_aliases => ["preferred_locations", "bb81cffd", "preferred_job_categories", "2c795204", "1aae6648", "62f71862", "current_location", "c539c70c"],
                                                                 :methods => ["categorywise_skills_information", "preferred_locations", "rejected_locations", "user_information"]
                                                               }
                                                               )
  end

  helper_method :link_to_jobseeker_app
  
  # This is HACK to generate links outside Recruiters app,
  # as we don't have helper to access jombay.com urls
  def  link_to_jobseeker_app(suffix="")
    request.protocol + request.host_with_port.split(".").reject{ |x| x=="recruiters"}.join(".") + "/" + suffix.to_s
  end

  # Saves rating for the application
  def rate
    @application = Vger::Spartan::Opus::Jobs::Application.find(params[:id])

    respond_to do |format|
      if @application.update_attributes({:employer_rating => params[:employer_rating]})
        format.json{ head :no_content }
      else
        format.json{ render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  def resume
    @application = Vger::Spartan::Opus::Jobs::Application.find(params[:id])

    resume = @application.download_resume_and_notify_user(
                                                          :urls => {
                                                            :fresher_jobs => link_to_jobseeker_app("jobs"),
                                                            :job => params[:job_url]
                                                          }
                                                          )

    redirect_to resume["resume"]["url"]
  end

  protected

  # Initialise job from token
  def init_job
    @job = Vger::Spartan::Opus::Recommendation.find_by_reference_key(params[:job_id])
  end

end
