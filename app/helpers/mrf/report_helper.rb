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

  def sort_perception_gap_section(competency_scores, perception_gap)
    new_hash = {}
    trait_scores_difference = {}
    competency_scores.each do |competency, competency_scores|
      competency_scores[:trait_scores].each do |trait_score|
        trait_scores_difference[trait_score[:trait][:name]] =  trait_score[:average_score_excluding_self][:points]
      end
    end
    negative_hash = {}
    perception_gap["negative_differences"].each do |trait|
       negative_hash[trait] = trait_scores_difference[trait]
    end
    negative_hash = Hash[negative_hash.sort_by { |key, value| value }]

    positive_hash = {}
    perception_gap["positive_differences"].each do |trait|
      positive_hash[trait] = trait_scores_difference[trait]
    end
    positive_hash = Hash[positive_hash.sort_by { |key, value| value }.reverse]

    aggrement_hash = {}
    perception_gap["aggrement"].each do |trait|
      aggrement_hash[trait] = trait_scores_difference[trait]
    end
    aggrement_hash = Hash[aggrement_hash.sort_by { |key, value| value }.reverse]

    new_hash[:aggrement] = aggrement_hash
    new_hash[:negative] = negative_hash
    new_hash[:positive] = positive_hash
    new_hash
  end

  def sorted_individual_scores(report_hash)
    max_per_page = 22
    competency_individual_scores = report_hash[:competency_individual_scores]
    competency_scores = report_hash[:competency_scores]
    
    all_user_scores = []
    all_scores = []
    
    competency_individual_scores.each do |competency, user_scores|
      group_average = competency_scores[competency][:average_score_including_self][:points]
      all_scores.push({
        user_id: "-",
        name: "-",
        competency_name: competency,
        is_competency_name: true,
        score: 1000
      })
      all_scores.push({
        user_id: "-",
        name: "-",
        competency_name: competency,
        is_group_average: true,
        group_average: group_average,
        score: 999
      })
      user_scores.each do |scores|
        user_score = {
          user_id: scores[:user_id],
          name: scores[:name],
          score: scores[:score].to_f,
          competency_name: competency 
        }
        all_user_scores.push(user_score)
        all_scores.push(user_score)
      end
    end
    
    final_array = []
    
    all_scores.each_slice(max_per_page) do |step_data|
      copy = step_data.dup
      if step_data[0][:is_competency_name]
      elsif step_data[0][:is_group_average]
        competency = step_data[0][:competency_name]
        copy.unshift({
          user_id: "-",
          name: "-",
          competency_name: competency,
          is_competency_name: true,
          score: 1000
        })  
      else
        competency = step_data[0][:competency_name]
        group_average = competency_scores[competency][:average_score_including_self][:points]
        copy.unshift({
          user_id: "-",
          name: "-",
          competency_name: competency,
          is_group_average: true,
          group_average: group_average,
          score: 999
        })
        copy.unshift({
          user_id: "-",
          name: "-",
          competency_name: competency,
          is_competency_name: true,
          score: 1000
        })  
      end
      final_array << copy
    end
    final_array.flatten!
    all_user_scores.sort_by!{|score| [score[:competency_name],1000-score[:score]] }
    competencies_per_page = final_array.each_slice(max_per_page).first.map{|x| x[:competency_name] }.uniq.size
    {
      user_scores: all_user_scores,
      step: (max_per_page - competencies_per_page*2)
    }
  end
end
