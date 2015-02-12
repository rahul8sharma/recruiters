module S3Utils
  def self.s3
    @@s3 ||= AWS::S3.new(Rails.application.config.s3)
  end
  
  def self.bucket_name
    Rails.application.config.s3_buckets["bucket_name"]
  end
  
  def self.ensure_bucket(bucket_name)
    bucket = s3.buckets[bucket_name]
    unless bucket.exists?
      bucket = s3.buckets.create(bucket_name)
    end
    bucket
  end
  
  def self.s3_bucket
    @@s3_bucket ||= self.ensure_bucket(self.bucket_name)
  end
  
  def self.find(bucket_name,key)
    bucket = self.ensure_bucket(bucket_name)
    bucket.objects[key]
  end
  
  def self.get_url(bucket_name, key)
    obj = S3Utils.find(bucket_name, key)
    obj.url_for("get").to_s
  end

  def self.upload(key, data, options={})
    obj = self.s3_bucket.objects.create(key, data, options)
  end
end
