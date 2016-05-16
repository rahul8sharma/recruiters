module Suitability
  module AssessmentsHelper
    def get_export_fields_for_status_summary(assessment)
      fields = YAML.load(
        File.read(
          "#{Rails.root}/config/exports/suitability/assessment_status_summary.yml"
        )
      )
      return fields
    end
    
    def trait_difficulty_levels
      return Vger::Resources::Suitability::Item::DIFFICULTY_LEVELS.sort
    end
  end
end
