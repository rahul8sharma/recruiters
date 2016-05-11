module Suitability
  module ReportsHelper
    def get_export_fields_for_report_summary(assessment)
      fields = YAML.load(
        File.read(
          "#{Rails.root}/config/exports/suitability/report_summary/fit.yml"
        )
      )
      begin
        fields.merge!(YAML.load(
          File.read(
            "#{Rails.root}/config/exports/suitability/report_summary/#{assessment.assessment_type}.yml"
          )
        ))
        
        file_name = assessment.brand_partner
        fields.merge!(YAML.load(
          File.read(
            "#{Rails.root}/config/exports/suitability/report_summary/#{file_name}.yml"
          )
        ))

      rescue Errno::ENOENT => e
        Rails.logger.debug "No report summary configuration found for #{assessment.brand_partner} or for #{assessment.assessment_type}"
      end    
      return fields
    end
    
    def get_ordered_guidelines(guidelines)
      norm_buckets = Hash[@norm_buckets.map{|x| [x.uid,x.weight] }]
      return guidelines.sort_by do |factor_name, guide|
        factor_score = @factor_scores[factor_name]
        scored_weight = norm_buckets[factor_score[:norm_bucket_uid]]
        from_weight = norm_buckets[factor_score[:scale][:from_norm_bucket_uid]]
        to_weight = norm_buckets[factor_score[:scale][:to_norm_bucket_uid]]
        closest_weight = [from_weight, to_weight].min_by { |weight| (scored_weight - weight).abs }
        (closest_weight - scored_weight).abs
      end.reverse
    end
  end
end
