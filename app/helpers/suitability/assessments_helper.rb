module Suitability
  module AssessmentsHelper
    def get_export_fields_for_status_summary(assessment)
      fields = YAML.load(
        File.read(
          "#{Rails.root}/config/exports/suitability/status_summary/assessment_status_summary.yml"
        )
      )
      begin
        
        if assessment.brand_partner.present?
          fields.merge!(YAML.load(
            File.read(
              "#{Rails.root}/config/exports/suitability/status_summary/#{assessment.brand_partner}.yml"
            )
          ))
        end
      rescue Errno::ENOENT => e
        Rails.logger.debug "No status summary configuration found for #{assessment.brand_partner}"
      end 
      return fields
    end
    
    def trait_difficulty_levels
      return Vger::Resources::Suitability::Item::DIFFICULTY_LEVELS.sort
    end
  end
end
