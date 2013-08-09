module S3Utils
  def self.s3
    @@s3 ||= AWS::S3.new(Rails.application.config.s3)
  end
  
  def self.ensure_bucket(bucket_name)
    bucket = s3.buckets[bucket_name]
    unless bucket.exists?
      bucket = s3.buckets.create(bucket_name)
    end
    bucket
  end
  
  def self.find(bucket_name,key)
    s3.buckets[bucket_name].objects[key]
  end
  
  def self.get_url(bucket_name,key)
    obj = S3Utils.find(bucket_name,key)
    obj.url_for("get").to_s rescue nil
  end

  def self.upload(bucket_name, key, data)
    bucket = S3Utils.ensure_bucket(bucket_name)
    obj = bucket.objects.create(key, data)
  end
end
