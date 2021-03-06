puts "Loading Her Configuration"
require 'faraday/response/raise_error'
require 'faraday/adapter/net_http'
require 'oauth2'

oauth_options ||= {
  callback: "",
  app_id: Rails.application.config.vger["api"]["app_id"],
  secret: Rails.application.config.vger["api"]["secret"],
  site: Rails.application.config.vger["api"]["url"]
}

$oauth_client = OAuth2::Client.new(oauth_options[:app_id], oauth_options[:secret], site: oauth_options[:site])


class TokenAuthentication < Faraday::Middleware
  def call(env)
    if RequestStore.store[:auth_token]
      env[:request_headers]["Authorization"] = "Bearer "+RequestStore.store[:auth_token]
    end
    @app.call(env)
  end
end

class PaginationParser  < Faraday::Response::Middleware
  def on_complete(env)
    pagination = nil
    if env[:response_headers]["x-pagination"]
      pagination = JSON.parse(env[:response_headers]["x-pagination"], :symbolize_names => true)
    end
    errors = env[:body].delete(:errors) || {}
    metadata = env[:body].delete(:metadata) || []
    env[:body] = {:data => env[:body][:data], :errors => errors, :metadata => metadata , :pagination => pagination}
  end
end

Vger::Config.configure({
  :url => Rails.application.config.vger["api"]["url"],
  :middlewares => [TokenAuthentication,Faraday::Response::RaiseError,PaginationParser]
})

