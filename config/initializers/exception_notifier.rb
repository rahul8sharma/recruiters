# Exception notifier for Rails application
Rails.application.config.middleware.use ::ExceptionNotifier,
    :email_prefix => "[recruiters-#{Rails.env}] ",
    :sender_address => "Application Error <errors@jombay.com>",
    :exception_recipients => Vger::EmailGroupsHelper.engineering,
    :normalize_subject => true


