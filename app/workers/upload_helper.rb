module UploadHelper
  def upload_file_to_s3(s3_key,file_path)
    File.open(file_path,"r") do |file|
      Rails.logger.debug "Uploading #{s3_key} to s3 ........."
      obj = S3Utils.upload(s3_key, file)
      Rails.logger.debug "Uploaded #{s3_key} to s3"
      return { :bucket => obj.bucket.name, :key => obj.key }
    end
  end
end

