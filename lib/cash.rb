module Cash
  extend self
  
  module Keys

    extend self

    def strkey(*args)
      args.join('/')
    end
    
    def cache_keys_for_cache_tag(tag)
      strkey([:cache_keys_for_cache_tag, tag])
    end
  end
  
  def flush_cache_tag(tag)
    cache_keys_for_cache_tag(tag).each do |key|
      Rails.cache.delete(key)
    end
    Rails.cache.delete(Keys::cache_keys_for_cache_tag(tag))
  end

  def record_cache_key_for_cache_tag(tag, key)
    keys = cache_keys_for_cache_tag(tag)
    if keys.add? key
      Rails.cache.write(Keys::cache_keys_for_cache_tag(tag), keys)
    end
  end

  def record_cache_key_for_cache_tags(tags, key)
    tags.each do |tag|
      record_cache_key_for_cache_tag(tag, key)
    end
  end

  def cache_keys_for_cache_tag(tag)
    Rails.cache.fetch(Keys::cache_keys_for_cache_tag(tag)) { Set.new } 
  end
end
