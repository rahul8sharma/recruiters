module UploadHelper
  def upload_file_to_s3(s3_key,file_path)
    File.open(file_path,"r") do |file|
      Rails.logger.debug "Uploading #{s3_key} to s3 ........."
      obj = S3Utils.upload(s3_key, file)
      Rails.logger.debug "Uploaded #{s3_key} to s3"
      return { :bucket => obj.bucket.name, :key => obj.key }
    end
  end
  
  def upload_failed(exception)
    set_report_status_to_failed
    JombayNotify::Email.create_from_mail(
      SystemMailer.notify_report_status(
        self.class.name,
        error_email_subject,
        {
          :report => @report_attributes,
          :errors => {
            :backtrace => [exception.message] + exception.backtrace
          }
        }
      ), 
      "notify_report_status"
    )
  end
  
  def safe_name(name)
    name.underscore.gsub('/','-').gsub(' ','-').gsub('_','-')
  end
end

