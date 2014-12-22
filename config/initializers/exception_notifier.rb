unless Rails.env.development?
  Rails.application.config.middleware.use ::ExceptionNotifier,
  :email_prefix => "[Recruiters-#{Rails.env}] ",
  :sender_address => "Application Error <errors@jombay.com>",
  :exception_recipients => %w(nikhil@jombay.com prashant@jombay.com chandrakant@jombay.com
            vatsala@jombay.com abhishek.verma@jombay.com)
end
