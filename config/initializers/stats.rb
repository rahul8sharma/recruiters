Stats::Collector.setup(Rails.application.config.stats)

ActiveSupport::Notifications.subscribe /request.active_resource/ do |*args|
  Stats::Collector.collect(:active_resource,
                           ActiveSupport::Notifications::Event.new(*args))
end

ActiveSupport::Notifications.subscribe /sql.active_record/ do |*args|
  Stats::Collector.collect(:active_record,
                           ActiveSupport::Notifications::Event.new(*args))
end

ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args|
  Stats::Collector.collect(:action,
                           ActiveSupport::Notifications::Event.new(*args))
end
