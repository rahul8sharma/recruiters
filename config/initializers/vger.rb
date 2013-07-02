puts "Loading Her Configuration"
require 'faraday/response/raise_error'
require 'faraday/adapter/net_http'
class TokenAuthentication < Faraday::Middleware
	def call(env)
		if RequestStore.store[:auth_token]
			env[:request_headers]["X-AuthToken"] = RequestStore.store[:auth_token]
		end
		@app.call(env)
	end
end

Vger::Config.configure({
	:url => Rails.application.config.vger["api"]["url"],
	:middlewares => [TokenAuthentication,Faraday::Response::RaiseError],
	:app_name => Rails.application.config.vger["api"]["app_name"],
	:password => Rails.application.config.vger["api"]["password"]
})
