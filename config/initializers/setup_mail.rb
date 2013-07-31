# Suppress mailers if environment is development

require 'development_mail_interceptor'

# Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
Mail.register_interceptor(StagingMailInterceptor) if Rails.env.staging_steve? or Rails.env.staging_dennis? 

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address => 'email-smtp.us-east-1.amazonaws.com',
  :port => 587,
  :domain => 'jombay.com',
  :authentication => :plain,
  :user_name => 'AKIAJ2UUJWJ2UDZ6EQIA',
  :password => 'Age+Vsj60JdS33pOi5rctHD3A48xJf4SAJWbSqti0qB+',
}
