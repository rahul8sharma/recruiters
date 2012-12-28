if Rails.application.config.action_controller.perform_caching
  ActiveSupport::Cache::Store.instrument = true

  cache_write_events = [
                        "write_fragment.action_controller",
                        "write_page.action_controller",
                        "cache_write.active_support"
                       ]

  cache_write_events.each do |event_name|
    ActiveSupport::Notifications.subscribe(event_name) do |*args|
      payload = ActiveSupport::Notifications::Event.new(*args).payload
      if payload[:tags]
        Cash::record_cache_key_for_cache_tags(payload[:tags],
                                              payload[:key])
      end
    end
  end
end


