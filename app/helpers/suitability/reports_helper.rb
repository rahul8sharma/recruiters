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
      fail_guidelines = guidelines.select{|factor_name, guide| !guide[:pass] }
      pass_guidelines = guidelines.select{|factor_name, guide| guide[:pass] }
      fail_guidelines = Hash[fail_guidelines.sort_by do |factor_name, guide|
        factor_score = @factor_scores[factor_name]
        scored_weight = norm_buckets[factor_score[:norm_bucket_uid]]
        from_weight = norm_buckets[factor_score[:scale][:from_norm_bucket_uid]]
        to_weight = norm_buckets[factor_score[:scale][:to_norm_bucket_uid]]
        closest_weight = [from_weight, to_weight].min_by { |weight| (scored_weight - weight).abs }
        (closest_weight - scored_weight).abs
      end.reverse]
      return fail_guidelines.merge(pass_guidelines).to_a
    end
    
    def get_areas_of_improvements(report)
      norm_buckets = Hash[@norm_buckets.map{|x| [x.uid,x.weight] }]
      factors = report.report_data[:competency_scores].reduce({}) do |_hash, (name,competency_data)|
        _hash.merge!(competency_data['factor_scores'])
      end
      fail_factors = factors.select{|factor_name, data| !data[:pass] }
      fail_factors = Hash[fail_factors.sort_by do |factor_name, factor_score|
        scored_weight = norm_buckets[factor_score[:norm_bucket_uid]]
        from_weight = norm_buckets[factor_score[:scale][:from_norm_bucket_uid]]
        to_weight = norm_buckets[factor_score[:scale][:to_norm_bucket_uid]]
        closest_weight = [from_weight, to_weight].min_by { |weight| (scored_weight - weight).abs }
        (closest_weight - scored_weight).abs
      end.reverse]
      Rails.logger.ap fail_factors
      fail_factors
    end
    
    def get_strengths(report)
      factors = report.report_data[:competency_scores].reduce({}) do |_hash, (name,competency_data)|
        _hash.merge!(competency_data['factor_scores'])
      end
      pass_factors = factors.select{|factor_name, data| data[:pass] }
      pass_factors
    end
  end
end
