module JobsHelper
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
  # Helper that returns struct with placeholder values for handlebar template
  # for preferred job category
  # OpenStruct is used to create a temporary structure.
  # Ref: http://ruby-doc.org/stdlib-1.9.3/libdoc/ostruct/rdoc/OpenStruct.html
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
end
