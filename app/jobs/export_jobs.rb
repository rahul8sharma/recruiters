require 'csv'

class ExportJobs
  @queue = :asap
  
  def self.perform
    valuators = {
      :name => :name,
      :description => :description,
      :eligibility => '',
      :job_categories => lambda{ |j|
        j.categories.map { |c|
          Vger::Spartan::Opus::JobCategory.find(c).alias
        }.join(",")
      },
      :work_profiles => lambda{ |j|
        j.profiles.map { |p|
          Vger::Spartan::Opus::Recommendation.find(p).name
        }.join(",")
      },
      :cities => lambda{ |j|
        j.locations.map { |l|
          Vger::Penumbra::Geography.find(l).name
        }.join(",")
      },
      :company => lambda{ |j| j.company.name},
      :about_the_company => lambda{ |j| j.company.description},
      :company_website => lambda{ |j| j.company.url },
      :executive_name => lambda {|j| j.contact_detail.name},
      :email => lambda {|j| j.contact_detail.email || ''},
      :phone_number => lambda { |j| j.contact_detail.phone },
      :posted_on => lambda { |j| (j.posted_on || Date.today).strftime("%d/%m/%Y") },
      :address => lambda { |j| j.company.address },
      :min_salary => lambda { |j|
        s = j.salary.min_range.to_f * 1e5
        s > 0 ? s : ''
      }, #TODO FIXTHIS
      :max_salary => lambda { |j|
        s = (j.salary.max_range || 0).to_f * 1e5
        s > 0 ? s : ''
      },
      :work_hours => lambda{ |j|
        j.time_slot.map { |t|
          Vger::Spartan::Opus::TimeSlot.find(t).name
        }.join(",")
      },
      :openings => :total_openings,
      :disclose_salary => lambda{ |j| j.salary.show.to_s == "true" },
      :site_url => '',
      :application_url => lambda{ |j| j.contact_detail.application_url},
      :application_instructions => lambda{ |j| j.additional_detail.application_instruction},
      :work_experiences => lambda{ |j|
        j.skill.must.skill_id.zip(j.skill.must.experience).map { |skill_id, exp|
          [
           Vger::Spartan::Opus::Recommendation.find(skill_id).name,
           exp.to_f
          ].join(":")
        }.join(",")
      },
      :job_poster => '',
      :active => true,        
      :min_work_experience => lambda{ |j| j.work_experience.min_range || '' },
      :max_work_experience => lambda{ |j| j.work_experience.max_range || '' },
      :internal_reference_number => lambda{ |j| j.contact_detail.job_id },
      :kind_of_job => lambda{ |j|
        Vger::Spartan::Opus::KindOfJob.find(j.kind_of).name
      },
      :job_industries => lambda{ |j|
        j.industries.map { |i|
          Vger::Spartan::Opus::Recommendation.find(i).bucket.alias
        }.join(",")
      },
      :soft_skills => lambda{ |j|
        #TODO: fix this
        [
         "Spoken English:#{j.spoken_skill}",
         "Written English:#{j.written_skill}"
        ].join(",")
      },
      :academic_performance => '',
      :academic_qualifications => lambda{ |j|
        j.qualification.degree_diploma.zip(j.qualification.specialization).map { |degree, career|
          [
           Vger::Spartan::Opus::Recommendation.find(degree).name,
           (Vger::Spartan::Opus::Recommendation.find(career).name rescue '')
          ].join(":")
        }.join(",")
      },
      :candidate_industries => lambda{ |j|
        j.candidate.industry.id.map { |i|
          Vger::Spartan::Opus::Recommendation.find(i).bucket.alias
        }.join(",")
      },
      :gender => lambda{ |j|
        Vger::Spartan::Dilios::Gender.find(j.candidate.personal.gender).name
      },
      :marital_status => lambda{ |j|
        Vger::Spartan::Dilios::MaritalStatus.find(j.candidate.personal.marital_status).name
      },
      :abilities => '',
      :traits => lambda{ |j|
        j.trait.map { |t|
          Vger::Spartan::Dilios::Trait.find(t).name
        }.join(",")
      },
      :interests => '',
      :candidate_locations => lambda{ |j|
        j.candidate.location.id.map { |l|
          Vger::Penumbra::Geography.find(l).name
        }.join(",")
      },
      :perks => lambda{ |j|
        (j.perk || []).map { |p|
          Vger::Spartan::Opus::JobPerk.find(p).name
        }.join(",")
      },
      :additional_perks => :additional_perk,
      :involves_travel => :involves_travel,
      :government_job => :government_job,
      :walkin => :walkin,
      :own_vehicle => :own_vehicle,
      :other_work_profile => '',
      :candidate_companies => lambda{ |j|
        j.additional_detail.candidate.company_history
      },
      :candidate_job_titles => lambda{ |j|
        j.additional_detail.candidate.job_title
      },
      :candidate_profile_keywords => lambda{ |j|
        j.additional_detail.candidate.keyword
      },
      :candidate_kind_blacklist => lambda{ |j|
        j.additional_detail.candidate.undesired || ''
      },
      :optional_skills => lambda{ |j|
        j.skill.nice.skill_id.map { |skill_id|
          Vger::Spartan::Opus::Recommendation.find(skill_id).name
        }.join(",")
      },
      :weekly_offs => lambda{ |j|
        j.offday.map { |d|
          Vger::Spartan::WeekDay.find(d).name
        }.join(",")
      },
      
      :reference_key => :uuid,
      :recruiter_sid => :posted_by,
    }

    
    pending_jobs = Recruiters::Job.with_status(:pending)

    rows = pending_jobs.map do |job|
      row = valuators.reduce({}) do |row, (column, valuator)|
        print "."
        row.update(column => (if valuator.kind_of?(Proc)
                                valuator.call(job)
                              elsif valuator.kind_of?(Symbol)
                                job.send(valuator)
                              else
                                valuator
                              end))
        
      end
    end

    base = "public/system/pending_jobs"

    relative_dir = "#{base}/#{Date.today.strftime('%Y-%m-%d')}"
    relative_dir_prev = "#{base}/#{(Date.today-2.days).strftime('%Y-%m-%d')}"
    
    absolute_dir = "#{Rails.root.to_s}/#{relative_dir}"
    absolute_dir_prev = "#{Rails.root.to_s}/#{relative_dir_prev}"
    
    FileUtils.mkdir_p(absolute_dir)

    file = "#{Time.now.strftime('%H_%M_%S')}.csv"
    relative_file = "#{relative_dir}/#{file}"
    absolute_file = "#{absolute_dir}/#{file}"

    url_path = relative_file.split("/")[1..-1].join("/")

    host = Rails.application.config.action_mailer.default_url_options[:host]

    url = "http://#{host}/#{url_path}"

    csv = CSV.open(absolute_file, "wb")
    csv << valuators.keys
    rows.each do |row|
      csv << row.values
    end
    csv.close

    FileUtils.rm_rf(absolute_dir_prev)
    
    recipient_emails = ["hardik@jombay.com"]
    
    data = {
      :success => [ "Pending jobs as of #{Time.now.strftime('%Y/%m/%d %H:%M:%S')}: #{url}" ],
      :error_msgs => [],
      :emails => recipient_emails
    }

    Vger::Herald::Notification.create :view_params => data, :event => "system/admin"
  end
end
