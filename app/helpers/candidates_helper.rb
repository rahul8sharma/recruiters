module CandidatesHelper
    def step3_data
    [
      {
        name: "mohit gupta",
        city: "Pune"
      }, {
        name: "nivedita kulkarni",
        city: "Mumbai"
      }, {
        name: "swati rajhans",
        city: "Lonavala"
      }
    ]
  end

  # Helper to return applications grouped by date
  def group_by_date(applications)
    applications.group_by{|application| application.created_at.to_date }
  end

  # Helper to return details for section
  def get_application_details(application, details_for)
    details = {
      :dashboard => {
        :user_profile_info_aliases => ["1aae6648", "62f71862", "current_location", "c539c70c"],
        :methods => ["skills_information", "user_information"]
      }
    }

    Vger::Spartan::Opus::Jobs::Application.find(application.id, :params => details[details_for])
  end

  # Helper to return count of remaining items based on count of items
  # to be shown
  def remaining_count(items, shown_count)
    items.count - shown_count
  end

  # Helper to return answers from user_profile_information array based
  # on question hex
  def answers_by_hex(user_prof_infos, hex)
    user_prof_infos.detect{|user_prof_info| user_prof_info.hexref == hex}.answers
  end

  # Helper to extract acedemic performance
  def extract_academic_performance(user_prof_infos)
    prof_info = answers_by_hex(user_prof_infos, "1aae6648")
    if prof_info.present?
      prof_info.first.description
    end
  end

  # Helper to extract course
  def extract_course(user_prof_infos)
    prof_info = answers_by_hex(user_prof_infos, "62f71862")
    if prof_info.present?
      prof_info.detect{|recommendations| recommendations.bucket_type == "Opus::Degree"}.name
    end
  end

  # Helper to extract preferred location
  def extract_preferred_location(user_prof_infos)
    prof_info = answers_by_hex(user_prof_infos, "preferred_locations")
    if prof_info.present?
      prof_info.first.name
    end
  end

  # Helper to extract job category
  def extract_preferred_job_category(user_prof_infos)
    prof_info = answers_by_hex(user_prof_infos, "preferred_job_categories")
    if prof_info.present?
      prof_info.first.name
    end
  end

  # Helper to extract strengths
  def extract_strengths(user_prof_infos)
    prof_info = answers_by_hex(user_prof_infos, "2c795204")
    if prof_info.present?
      prof_info
    end
  end

  # Helper to extract kind of job preference
  def extract_kind_of_job(user_prof_infos)
    prof_info = answers_by_hex(user_prof_infos, "bb81cffd")
    if prof_info.present?
      prof_info.first.description
    end
  end

  # Helper to extract current location
  def extract_current_location(user_prof_infos)
    prof_info = answers_by_hex(user_prof_infos, "current_location")
    if prof_info.present?
      prof_info.first.name
    end
  end

  # Helper to extract language fluency
  def extract_language_fluency(user_prof_infos)
    prof_info = answers_by_hex(user_prof_infos, "c539c70c")
    if prof_info.present?
      prof_info.first.short_text
    end
  end

  # Helper to generate user bio string
  def user_bio(user_prof_infos)
    academic_performance = extract_academic_performance(user_prof_infos)
    course = extract_course(user_prof_infos)
    location = extract_current_location(user_prof_infos)
    language_fluency = extract_language_fluency(user_prof_infos)

    [
      ("#{academic_performance} in" if academic_performance and course),
      ("#{course}" if course),
      ("from #{location}" if location),
      ("with #{language_fluency}" if language_fluency),
    ].compact.join(" ")
  end

  # Helper to return skill display based on value
  def skill_display(value)
    Hash[skill_enum].invert[value.to_i]
  end
end
