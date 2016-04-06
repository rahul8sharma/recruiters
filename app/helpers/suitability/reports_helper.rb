module Suitability
  module ReportsHelper
    def get_export_fields_for_report_summary(assessment)
      fields = YAML.load(
        File.read(
          "#{Rails.root}/config/exports/suitability/report_summary/jombay.yml"
        )
      )
      if assessment.brand_partner.present?
        begin
          file_name = assessment.brand_partner
          fields.merge!(YAML.load(
            File.read(
              "#{Rails.root}/config/exports/suitability/report_summary/#{file_name}.yml"
            )
          ))
        rescue Errno::ENOENT => e
          Rails.logger.debug "No report summary configuration found for #{assessment.brand_partner}"
        end    
      end
      return fields
    end
  end
end
