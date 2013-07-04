module Suitability::Job::FactorNormsHelper
  require 'csv'

  # Generates a CSV out of a collection of
  # Suitability Job Factor Norms
  def generate_csv job_factor_norms
    CSV.generate(:quote_char => "\"", :col_sep => ',') do | csv |
      csv << ['id',
              'factor_id', 'Ref:factor_name',
              'industry_id', 'Ref:industry_name',
              'functional_area_id', 'Ref:functional_area_name',
              'job_experience_id', 'Ref:job_experience_min', 'Ref:job_experience_max',
              'norm_value', 'std_dev'
              ]
      job_factor_norms.each do | job_factor_norm |
        csv << [
                 job_factor_norm.id,
                 # Suitability Factor
                 job_factor_norm.factor_id,
                 job_factor_norm.suitability_factor[:factor][:name],
                 # Industry
                 job_factor_norm.industry_id,
                 job_factor_norm.industry[:industry][:name],
                 # Functional Area
                 job_factor_norm.functional_area_id,
                 job_factor_norm.functional_area[:functional_area][:name],
                 # Job Experience
                 job_factor_norm.job_experience_id,
                 job_factor_norm.job_experience[:job_experience][:min],
                 job_factor_norm.job_experience[:job_experience][:max],
                 # Norm value and Standard Deviation
                 job_factor_norm.norm_value,
                 job_factor_norm.std_dev
                ]
      end
    end
  end
end
