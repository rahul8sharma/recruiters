class Jq::MultimediaAnswersController < MasterDataController
  before_action :authenticate_user!
  
  def api_resource
    Vger::Resources::Jq::MultimediaAnswer
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def show
    @resource = api_resource.find(params[:id], :methods => index_columns+[:original_attachment_url])
  end
  
  def create
    file = params[:jq_multimedia_answer][:attachment]
    if file
      key = "jq/multimedia_answers/#{params[:jq_multimedia_answer][:interview_question_id]}/#{params[:jq_multimedia_answer][:user_id]}/#{file.original_filename}"
      content_type = file.content_type
      obj = S3Utils.upload(key, file.read, content_type: content_type, acl: "public-read")
      url = obj.public_url({secure: false}).to_s
      params[:jq_multimedia_answer].delete :attachment
      params[:jq_multimedia_answer][:unprocessed_attachment_url] = url
    end
    @resource = api_resource.create(params[resource_name.singularize])
    if @resource.error_messages && @resource.error_messages.present?
      flash[:error] = @resource.error_messages.join("<br/>").html_safe
      render :action => :new
    else
      redirect_to self.send("#{resource_name.singularize}_path",@resource.id)
    end
  end
  
  def update
    file = params[:jq_multimedia_answer][:attachment]
    if file
      key = "jq/multimedia_answers/#{params[:jq_multimedia_answer][:interview_question_id]}/#{params[:jq_multimedia_answer][:user_id]}/#{file.original_filename}"
      content_type = file.content_type
      obj = S3Utils.upload(key, file.read, content_type: content_type, acl: "public-read")
      url = obj.public_url({secure: false}).to_s
      params[:jq_multimedia_answer].delete :attachment
      params[:jq_multimedia_answer][:unprocessed_attachment_url] = url
    end
    
    @resource = api_resource.save_existing(params[:id], params[resource_name.singularize])
    if @resource.error_messages && @resource.error_messages.present?
      flash[:error] = @resource.error_messages.join("<br/>").html_safe
      render :action => :edit
    else
      redirect_to self.send("#{resource_name.singularize}_path",@resource.id)
    end
  end
  
  def index_columns
    [
      :id,
      :user_id,
      :interview_question_id,
      :job_id,
      :company_id,
      :status
    ]
  end
  
  def search_columns
    [
      :id,
      :user_id,
      :interview_question_id,
      :job_id,
      :company_id,
      :status
    ]
  end
end
