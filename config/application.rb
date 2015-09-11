require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Recruiters
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.eager_load_paths += %W(#{config.root}/lib)
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
    # config.active_record.whitelist_attributes = true
    config.validators = YAML.load(File.read(Rails.root.join("config/validation.yml")))
    # assets_precompile_enforcer module copied from https://github.com/ndbroadbent/assets_precompile_enforcer
    require "assets_precompile_enforcer/sprockets/helpers/rails_helper"
    config.assets.original_precompile = config.assets.precompile.dup
    config.to_prepare { load 'config/assets_precompile.rb' }
    config.watchable_files << 'config/assets_precompile.rb'
    config.assets.enforce_precompile = true

    config.domain = YAML::load(File.open("#{Rails.root.to_s}/config/domains.yml"))[Rails.env.to_s]

    config.languages = YAML::load(File.open("#{Rails.root.to_s}/config/languages.yml"))['languages']

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    config.vger = YAML::load(File.open("#{Rails.root.to_s}/config/vger.yml"))[Rails.env.to_s]
    config.payments = YAML::load(File.open("#{Rails.root.to_s}/config/payments.yml"))
    config.reports = YAML::load(File.open("#{Rails.root.to_s}/config/reports.yml"))
    config.brand_partners = YAML::load(File.open("#{Rails.root.to_s}/config/brand_partners.yml"))["brand_partners"]
    config.default_set = YAML::load(File.open("#{Rails.root.to_s}/config/default_set.yml"))["default_set"]
    config.sidekiq = YAML.load(File.read(Rails.root.join("config/sidekiq/#{Rails.env}.yml")))
    config.s3_buckets = YAML.load(File.read(Rails.root.join("config/s3_buckets.yml")))[Rails.env.to_s]
    config.signup = YAML.load(File.read(Rails.root.join("config/signup.yml"))).symbolize_keys
    config.emails = YAML.load(File.read(Rails.root.join("config/emails.yml"))).with_indifferent_access
    
    config.mrf_report_competency_sections = YAML::load(File.open("#{Rails.root.to_s}/config/mrf_report_competency_sections.yml")).with_indifferent_access




    config.action_controller.default_url_options = { :trailing_slash => true }
    config.time_zone = 'Mumbai'
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.delivery_method = :smtp

    hosts = YAML::load(File.open("#{Rails.root.to_s}/config/hosts.yml"))[Rails.env.to_s]
    config.hosts = hosts
    config.action_mailer.default_url_options = { :host => hosts['action_mailer']['host'], :only_path => false, :protocol => hosts['action_mailer']['protocol'] }
    config.action_controller.asset_host = "http://#{hosts['action_controller']['asset_host']}"

    config.statistics = YAML::load(File.open("#{Rails.root.to_s}/config/statistics.yml"))["statistics"].symbolize_keys

    # Temporary fix for Rails vulnerability
    ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
    config.s3 = YAML::load(File.open("#{Rails.root.to_s}/config/s3/#{Rails.env.to_s}.yml")).symbolize_keys

    # Redis configuration for redis driven app configuration
    redis_configuration = YAML::load(
                    File.open(
                        "#{Rails.root.to_s}/config/redis_driven_configuration.yml"
                            ))

    config.configuration_server = Redis.new host: redis_configuration['host'],
                                            port: redis_configuration['port'],
                                            db: redis_configuration['db'],
                                            driver: :celluloid
  end
end
