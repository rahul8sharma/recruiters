# Vger app credential configurations

Vger::Authentication.send(:include, Rails.application.routes.url_helpers)

Rails.application.config.vger.each_pair do |api, config|
  
  cred = config.extract!('app_name', 'password')
  
  if config["auth"]
    # do settings for penumbra devise wrappers and umbra
    # ActiveResource wrapper both
    
    cred.each_pair do |k, v|
      Vger::Authentication.send("#{k}=", v)
    end
    
    Vger::Authentication.url_mappings = {
                                    :register => {:method => :post, :uri => "/users.json"},
                                    :signin => {:method => :post, :uri => '/users/sign_in.json'},
                                    :oauth_passthru => {:method => :get, :uri => '/users/auth/:provider' },
                                    :forgot_password => {:method => :post, :uri => '/users/password'},
                                    :change_password => {:method => :put, :uri => '/users/password'},
                                    :confirmation => {:method => :get, :uri => '/users/confirmation.json'},
                                    :resend_confirmation => {:method => :post, :uri => '/users/resend_confirmation.json'},
                                    :change_password => {:method => :put, :uri => '/users/password'}
                                  }
    # setup the same credentials for Authentication ActiveResource wrapper
    Vger::YorenWrapper.setup(cred)

  else
    "Vger::#{api.capitalize}Wrapper".constantize.setup(cred)
  end
end

ActiveResource::Base.logger = Rails.logger
