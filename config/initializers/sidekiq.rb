require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["sidekiqadmin", "mig33g0thic"]
end

Sidekiq.configure_server do |config|
  config.redis = Rails.configuration.sidekiq[:redis]
  config.poll_interval = 1
end

# Workers running in the Sidekiq server can themselves push new jobs
# to Sidekiq, thus acting as clients. Hence the config below.
Sidekiq.configure_client do |config|
  config.redis = Rails.configuration.sidekiq[:redis]
end
