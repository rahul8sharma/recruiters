class Jq::MultimediaAnswersController < MasterDataController
  before_filter :authenticate_user!
  
  def api_resource
    Vger::Resources::Jq::MultimediaAnswer
  end
  
  def import_from
    "import_from_google_drive"
  end
  
  def create
    file = params[:jq_multimedia_answer][:attachment]
    if file
      key = "multimedia_answers/attachments/#{file.original_filename}"
      content_type = file.content_type
      obj = S3Utils.upload(key, file.read, content_type: content_type, acl: "public-read")
      url = obj.public_url({secure: false}).to_s
      params[:jq_multimedia_answer][:attachment] = url
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
      key = "multimedia_answers/attachments/#{params[:id]}-#{file.original_filename}"
      content_type = file.content_type
      obj = S3Utils.upload(key, file.read, content_type: content_type, acl: "public-read")
      url = obj.public_url({secure: false}).to_s
      params[:jq_multimedia_answer][:attachment] = url
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
      :candidate_id,
      :interview_question_id,
      :job_id,
      :company_id
    ]
  end
  
  def search_columns
    [
      :id,
      :candidate_id,
      :interview_question_id,
      :job_id,
      :company_id
    ]
  end
end
