module UploadHelper
  def upload_file_to_s3(s3_key,file_path)
    File.open(file_path,"r") do |file|
      Rails.logger.debug "Uploading #{s3_key} to s3 ........."
      s3_bucket_name = Rails.application.config.s3_buckets["bucket_name"]
      url = S3Utils.upload(s3_bucket_name, s3_key, file)
      Rails.logger.debug "Uploaded #{s3_key} with url #{url} to s3"
      return { :bucket => s3_bucket_name, :key => s3_key }
    end
  end
end

