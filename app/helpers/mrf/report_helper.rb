module Mrf::ReportHelper
  def get_response_distribution(report)
   items = report.report_data[:competency_scores].values.map do |x| 
        x[:trait_scores]
      end.flatten.map do |x| 
        other_responses = x["items"]["other_responses"]
        other_responses.each do |item|
          item["trait_name"] = x[:trait][:name]
          item["role"]  = "other"
        end
        self_responses = x["items"]["self_responses"] 
        self_responses.each do |item|
          item["trait_name"] = x[:trait][:name]
          item["role"]  = "self"
        end
        other_responses + self_responses
    end.flatten 
    items
  end

  def get_traits_under_competencies(report)
    all_trait_scores = []
    report.report_data[:competency_scores].map do |competency, competency_scores|
      competency_scores[:trait_scores].map do |trait_scores|  
        new_trait_scores = trait_scores.dup
        new_trait_scores[:competency_name] = competency
        all_trait_scores.push new_trait_scores
      end
    end
    all_trait_scores
  end

  def get_role_wise_comments(report)
    all_comments = []
    report.report_data[:competency_scores].map do |competency, competency_scores|
      competency_scores[:trait_scores].map do |trait_scores|  
        trait_comments = trait_scores["comments"]
        if trait_comments
          trait_comments.each do |role, comments|
            all_comments.push({
              role: role,
              competency_name: competency,
              comment: comments.map{|comment| comment[:comment] }.compact.join("<br/>").html_safe
            })
          end
        end
      end
    end
    all_comments.select{|comment| comment[:comment].present? }
  end

  def get_subjective_response(report, stakeholder_type)
    all_responses = []
    stakeholder_type.map do |subjective_response_key, subjective_response_value|
      subjective_response_value[:role_wise_subjective_responses].map do |role, role_wise_responses|
        if role_wise_responses.present?
          all_responses.push({
            question: subjective_response_value[:body],
            role: role,
            response: role_wise_responses.compact.join("<br/>").html_safe
          })
        end  
      end
    end
    all_responses.select{|comment| comment[:response].present? }
  end

  def get_user_wise_competency_scores(hash)
    new_hash = {}
    hash.each do |competency_name,data|
      data.each do |user_data|
        new_hash[user_data["name"]] ||= {}
        new_hash[user_data["name"]][competency_name] = {
          score: user_data["score"].to_f,
        }
      end
    end
    new_hash 
  end

end
