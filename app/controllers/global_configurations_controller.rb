class GlobalConfigurationsController < ConfigurationController

  def namespace
    :global_configuration
  end

  def update_fallback_strategy
    strategies = (params[:values] || {}).values

    strategies.map! do | strategy |
      strategy.reverse_merge!(industry_id: nil, functional_area_id: nil, job_experience_id: nil)
      strategy.reject!{| key, value| value.to_i == 1}
    end

    logger.debug strategies.inspect

    redis_server.set "#{namespace}:fallback_strategy", strategies.to_json

    redirect_to edit_global_configuration_path(:fallback_strategy)
  end
end
