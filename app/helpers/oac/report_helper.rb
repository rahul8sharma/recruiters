module Oac
  module ReportHelper
    def get_top_competencies(report)
      scores = report.report_data[:super_competency_scores].map do |id, data|
        [id, data]
      end
      return scores.sort_by do |score|
        score.second[:score][:score]
      end.reverse[0..1]
    end
    
    def get_bottom_competencies(report)
      scores = report.report_data[:super_competency_scores].map do |id, data|
        [id, data]
      end
      return scores.sort_by do |score|
        score.second[:score][:score]
      end[0..1]
    end
    
    def get_sorted_super_competency_scores(report)
      report.report_data[:super_competency_scores].sort_by{|k,v| v['score']['score']}.reverse
    end
    
    def get_sorted_competency_scores(report)
      hash = {}
      report.report_data[:super_competency_scores].each do |id, data|
        data[:competency_scores].each do |competency_id, competency_data|
          hash[competency_id] = competency_data
        end
      end
      hash.sort_by{|k,v| v['score']['score']}.reverse
    end
  end
end
