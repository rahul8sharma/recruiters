class MultimediaProfilesController < MasterDataController
  before_filter :authenticate_user!
  
  def api_resource
    Vger::Resources::MultimediaProfile
  end
  
  def index_columns
    [
      :id,
      :candidate_id
    ]
  end
  
  def search_columns
    [
      :id,
      :candidate_id
    ]
  end
  
  def show
    @resource = api_resource.find(params[:id], :methods => index_columns+[:original_attachment_url])
  end
  
  def create
    file = params[:multimedia_profile][:attachment]
    if file
      key = "candidates/multimedia_profiles/#{params[:multimedia_profile][:candidate_id]}-#{file.original_filename}"
      content_type = file.content_type
      obj = S3Utils.upload(key, file.read, content_type: content_type, acl: "public-read")
      url = obj.public_url({secure: false}).to_s
      params[:multimedia_profile].delete :attachment
      params[:multimedia_profile][:unprocessed_attachment_url] = url
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
    file = params[:multimedia_profile][:attachment]
    if file
      key = "candidates/multimedia_profiles/#{params[:multimedia_profile][:candidate_id]}-#{file.original_filename}"
      content_type = file.content_type
      obj = S3Utils.upload(key, file.read, content_type: content_type, acl: "public-read")
      url = obj.public_url({secure: false}).to_s
      params[:multimedia_profile].delete :attachment
      params[:multimedia_profile][:unprocessed_attachment_url] = url
    end
    @resource = Vger::Resources::MultimediaProfile.save_existing(params[:id], params[:multimedia_profile])
    if @resource.error_messages.blank?
      #obj.delete if file
      redirect_to multimedia_profile_path(@resource), notice: "Profile updated successfully!"
    else
      render :action => :edit
    end
  end
end
