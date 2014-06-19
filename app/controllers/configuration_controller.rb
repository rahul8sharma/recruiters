# Redis driven configuration
# Boiler plate code to facilitate basic actions and dependency injection
#
# To start a new configuration management controller:
# 1. Inherit a controller class from ConfigurationController
# 2. Override 'namespace' method to define a custom namespace.
# 3. All scaffolding views and actions are present in configuration engine
# 4. Override specific views in respective view paths
class ConfigurationController < ApplicationController
  before_filter :authenticate_user!
  layout "admin"
  require 'celluloid/redis'
  require 'json'

  def index
    keys = redis_server.keys "#{namespace}:*"
    @configuration = keys.map do | key |
      {key.gsub("#{namespace}:", '') => redis_server.get(key)}
    end.inject({}){| hash, injected| hash.merge! injected}
  end

  def new
  end

  def create
    redis_server.set "#{namespace}:#{params[:key]}", params[:value]

    redirect_to( send controller_name.singularize+'_url', params[:key] )
  end

  # Regular show page for a configuration
  # Can also render a specific show page for a particular configuration key
  # E.g. Add <controller_view_path>/show_name.html.haml for custom UI/UX to support
  # rendering a specific configuration under key 'name'
  def show
    @value = redis_server.get "#{namespace}:#{params[:id]}"

    if template_exists?("show_#{params[:id]}", controller_name)
      render "show_#{params[:id]}"
    end
  end

  # Regular edit page for a configuration
  # Can also render a specific edit page for a particular configuration key
  # E.g. Add <controller_view_path>/edit_name.html.haml for custom UI/UX to support
  # editing a specific configuration under key 'name'
  def edit
    @value = redis_server.get "#{namespace}:#{params[:id]}"

    if template_exists?("edit_#{params[:id]}", controller_name)
      render "edit_#{params[:id]}"
    end
  end

  protected
  def namespace
    raise NotImplementedError.new(
      "Please define 'namespace' method in #{controller_name.camelize+'Controller'}"
    )
  end

  def redis_server
    Rails.application.config.configuration_server
  end
end
