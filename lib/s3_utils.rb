module S3Utils
  def self.ensure_bucket(bucket_name)
    begin
      AWS::S3::Bucket.find(bucket_name, :access => :private)
    rescue AWS::S3::NoSuchBucket => e
      AWS::S3::Bucket.create(bucket_name)
    end
  end

  def self.upload(bucket_name, key, data)
    S3Utils.ensure_bucket(bucket_name)

    AWS::S3::S3Object.store(key,
                            data,
                            bucket_name)
  end
end
