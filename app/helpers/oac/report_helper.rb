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
  end
end
