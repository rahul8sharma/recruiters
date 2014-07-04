module GlobalConfigurationsHelper
  def get_strategy_tuple strategy
    strategy_tuple = {industry_id: 1, functional_area_id: 1, job_experience_id: 1}
    strategy_tuple.merge!(strategy.symbolize_keys) unless strategy.blank?
    strategy_tuple
  end
end
