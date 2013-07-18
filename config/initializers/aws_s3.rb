if defined?(AWS::S3)
  class Module
    # aws-s3 overrides const_missing with its own implementation
    # so that *any* class that ends with Bucket is auto created and
    # inherits from AWS::S3::Bucket(WTF!!!)
    
    # Reverting the damage done by aws-s3 below
    alias_method :const_missing, :const_missing_not_from_s3_library
  end
end
