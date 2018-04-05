module S3Utils
  require 'aws-sdk'

  def self.s3
    access_key_id = Rails.application.config.s3[:access_key_id]
    secret_access_key = Rails.application.config.s3[:secret_access_key]
    Aws.config.update({
      region: Rails.application.config.s3[:region],
      credentials: Aws::Credentials.new(access_key_id, secret_access_key)
    })
    @@s3 = Aws::S3::Resource.new
    # @@s3 ||= Aws::S3.new(Rails.application.config.s3)
  end
  
  def self.bucket_name
    Rails.application.config.s3_buckets["bucket_name"]
  end
  
  def self.ensure_bucket(bucket_name)
    bucket = s3.bucket(bucket_name)
    unless bucket.exists?
      bucket = s3.create_bucket(bucket: bucket_name)
    end
    bucket
  end
  
  def self.s3_bucket
    @@s3_bucket ||= self.ensure_bucket(self.bucket_name)
  end
  
  def self.find(bucket_name,key)
    bucket = self.ensure_bucket(bucket_name)
    bucket.object(key)
  end
  
  def self.get_url(bucket_name, key)
    obj = S3Utils.find(bucket_name, key)
    
    # obj.url_for("get").to _s
    obj.presigned_url(:get).to_s
  end

  def self.upload(key, data, options={})
    bucket = S3Utils.ensure_bucket(bucket_name)

    # data  = IO.read(data) if data.is_a?(File)
    obj = bucket.put_object(key: key, body: data)
  end 
end

  