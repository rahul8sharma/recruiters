class Recruiters::CandidatesController < Recruiters::ApplicationController
  before_filter :validate_token
  before_filter :init_job, :only => [:dashboard, :application]
  
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
                                                          params[:app_id],
                                                          :params => {
                                                                 :user_profile_info_aliases => ["preferred_locations", "bb81cffd", "preferred_job_categories", "2c795204", "1aae6648", "62f71862", "current_location", "c539c70c"],
                                                                 :methods => ["categorywise_skills_information", "preferred_locations", "rejected_locations", "user_information"]
                                                               }
                                                          )
  end

  protected

  # Validate presence of token
  def validate_token
    unless params[:token]
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  # Initialise job from token
  def init_job
    @job = Vger::Spartan::Opus::Recommendation.find(params[:id], :from => :bucket_index, :params => {:bucket_type => "Opus::Job"})
    #@job = Vger::Spartan::Opus::Recommendation.find_by_access_token(params[:token], :from => :bucket_index, :params => {:bucket_type => "Opus::Job"})
  end

end
