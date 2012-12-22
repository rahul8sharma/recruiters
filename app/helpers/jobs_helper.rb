module JobsHelper
  # Enum for skill levels
  def skill_enum
    ["Beginner", "Average", "Good", "Very good"].each_with_index.collect{|level, index| [level, (index + 1) * 10]}
  end
  # Enum for skill-wise experience in years
  def skill_experience_enum
    (0..16).step(0.5).to_a
  end

  # Options for skill level
  def skill_level_options
    options_for_select(skill_enum)
  end
  # Options for skill-wise experience in years
  def skill_experience_options
    options_for_select(skill_experience_enum.map{ |exp| ["#{exp} years", exp] })
  end

  def skill_level_display(weight)
    case weight
    when 10
      "Beginner"
    when 20
      "Average"
    when 30
      "Good"
    when 40
      "Very good"
    end
  end

  def salary_enum
    (0..30).step(0.5).to_a
  end
  def salary_options
    options_for_select(salary_enum.map{ |sal| ["#{sal}", sal] })
  end

  def additional_info_enum
    {
      :involves_travel => "Involves Travel",
      :government_job => "Government Job",
      :own_vehicle => "Vehicle is required",
      :walkin => "This is a Walk in event"
    }
  end
  # Helper that returns struct with placeholder values for blank question
  # template for jobs
  # OpenStruct is used to create a temporary structure.
  # Ref: http://ruby-doc.org/stdlib-1.9.3/libdoc/ostruct/rdoc/OpenStruct.html
  def job_template_struct
    OpenStruct.new(
               :id => nil,
               :name => nil,
               :skills => [],
               :locations => [],
               :current => nil,
               :salary => nil,
               :companies => [],
               :designation => nil,
               :to => nil,
               :from => nil
           )
  end

  def preferred_job_industry_template_struct
    OpenStruct.new(
    	       :count => "{{ count }}",
               :id => "{{ id }}",
               :name => "{{ name }}"
               )
  end

  def preferred_job_category_template_struct
    OpenStruct.new(
    	       :count => "{{ count }}",
               :id => "{{ id }}",
               :name => "{{ name }}"
               )
  end
  def preferred_job_profile_template_struct
    OpenStruct.new(
               :count => "{{ count }}",
               :id => "{{ id }}",
               :name => "{{ name }}"
               )
  end
  def preferred_job_location_template_struct
    OpenStruct.new(
               :count => "{{ count }}",
               :id => "{{ id }}",
               :name => "{{ name }}"
               )
  end

  def skill_template_struct
    OpenStruct.new(
               id: "{{ id }}",
               name: "{{ name}}",
               experience: "{{ experience }}"
               )
  end
end
