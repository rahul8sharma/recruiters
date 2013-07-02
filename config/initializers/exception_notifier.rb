unless Rails.env.development?
  Rails.application.config.middleware.use ::ExceptionNotifier,
  :email_prefix => "[Jombay-#{Rails.env}] ",
  :sender_address => "Application Error <errors@jombay.com>",
  :exception_recipients => %w(nikhil@jombay.com manoj@jombay.com akash@jombay.com prashant@jombay.com ankush@jombay.com chandrakant@jombay.com)
end
