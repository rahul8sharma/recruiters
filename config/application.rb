require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Recruiters
  class Application < Rails::Application

    config.top_lists = HashWithIndifferentAccess.new(YAML::load_file Rails.root.join("config", "top_lists.yml"))
    config.recruiters = {
      :job_posting_sections => {
        "job_details" => "Job Details",
        "job_requirements" => "Job Requirements",
        "hiring_preferences" => "Hiring Preferences",
        "logistics" => "Compensation & Logistics",
        "additional_details" => "Additional Details",
        "company_details" => "Company Details",
        "preview" => "Preview"
      }
    }
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.corporate_name = "Jombay"
    config.copyright_year = DateTime::now.year

    config.facebook = YAML::load(File.open("#{Rails.root.to_s}/config/facebook.yml"))[Rails.env.to_s]

    config.vger = YAML::load(File.open("#{Rails.root.to_s}/config/vger.yml"))[Rails.env.to_s]

    config.buckets = YAML::load(File.open("#{Rails.root.to_s}/config/sparta/buckets.yml"))
    
    config.autoload_paths += Dir[Gem::Specification.find_by_name("vger").gem_dir+"/**"]

    config.assets.paths << "#{Rails.root}/app/assets/font"

    config.assets.precompile += [
                                 '*.js',
                                 'recruiters/shared/*',
                                 'recruiters.css',
                                 'recruiters/jobs.css',
                                 'recruiters/header.css',
                                 'recruiters/landing.css',
                                 'recruiters/layout.css',
                                 'recruiters/candidates.css',
                                 'recruiters/candidates/rating_star.css',
                                 'sparta/rupee.css',
                                 'lib/awesome-font.css'
                                ]
    
    config.assets.precompile << Proc.new { |path|
      precompile = false
      
      if path =~ /\.css/
        full_path = Rails.application.assets.resolve(path).to_path
        if full_path =~ /\.css/
          precompile = true
        end
      end
      
      if precompile
        puts "Compiling '#{path}' "
      end
      precompile
    }
           
    config.middleware.use ::ExceptionNotifier,
    :email_prefix => "[recruiters-#{Rails.env}] ",
    :sender_address => "Application Error <errors@jombay.com>",
    :exception_recipients => %w(nikhil@jombay.com manoj@jombay.com saurabh@jombay.com),
    :normalize_subject => true

    config.stats = YAML::load(File.open(Rails.root.join("config", "stats", "#{Rails.env}.yml")))
  end
end
