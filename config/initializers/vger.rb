# Vger app credential configurations

Vger::Authentication.send(:include, Rails.application.routes.url_helpers)

Rails.application.config.vger.each_pair do |api, config|
  if config.delete('auth')
    config.each_pair do |key, value|
      Vger::Authentication.send("#{key}=", value)
    end
  end
  "Vger::#{api.capitalize}Wrapper".constantize.setup(config)
end

ActiveResource::Base.logger = Rails.logger
