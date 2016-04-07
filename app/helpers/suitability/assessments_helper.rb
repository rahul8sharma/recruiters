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
  end
end
