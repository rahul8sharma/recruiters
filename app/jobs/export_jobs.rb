require 'csv'

class ExportJobs
  @queue = :asap

  def self.perform
    valuators = {
      :name => :name,
      :description => :description,
      :eligibility => '',
      :job_categories => lambda{ |job|
        (job.categories || []).map { |category|
          Vger::Spartan::Opus::JobCategory.find(category).alias rescue nil
        }.compact.join(",")
      },
      :work_profiles => lambda{ |job|
        (job.profiles || []).map { |work_profile|
          Vger::Spartan::Opus::Recommendation.find(work_profile).name rescue nil
        }.compact.join(",")
      },
      :cities => lambda{ |job|
        (job.locations || []).map { |location|
          Vger::Penumbra::Geography.find(location).name rescue nil
        }.compact.join(",")
      },
      :company => lambda{ |job| (job.company.name rescue nil) || ''},
      :about_the_company => lambda{ |job| (job.company.description rescue nil) || ''} ,
      :company_website => lambda{ |job| (job.company.url rescue nil) || ''},
      :executive_name => lambda {|job| (job.contact_detail.name rescue nil) || ''},
      :email => lambda {|job| (job.contact_detail.email rescue nil) || ''},
      :phone_number => lambda { |job| (job.contact_detail.phone rescue nil) || ''},
      :posted_on => lambda { |job| ((job.posted_on || Date.today).strftime("%d/%m/%Y") rescue nil) || '' },
      :address => lambda { |job| (job.company.address rescue nil) || ''},
      :min_salary => lambda { |job|
        s = ((job.salary.min_range.to_f * 1e5) rescue 0)
        s > 0 ? s : ''
      },
      :max_salary => lambda { |job|
        s = ((job.salary.max_range.to_f * 1e5) rescue 0)
        s > 0 ? s : ''
      },
      :work_hours => lambda{ |job|
        (job.time_slot || []).map { |time_slot|
          Vger::Spartan::Opus::TimeSlot.find(time_slot).name rescue nil
        }.compact.join(",")
      },
      :openings => :total_openings,
      :disclose_salary => lambda{ |job| !((job.salary.show.to_s rescue '') == "true") },
      :site_url => '',
      :application_url => lambda{ |job| (job.contact_detail.application_url rescue nil) || ''},
      :application_instructions => lambda{ |job| (job.additional_detail.application_instruction rescue nil) || ''},
      :work_experiences => lambda{ |job|
        (job.skill.must.skill_id.zip(job.skill.must.experience) rescue []).map { |skill_id, experience|
          [
           (Vger::Spartan::Opus::Recommendation.find(skill_id).name rescue nil),
           experience.to_f
          ].compact.join(":")
        }.join(",")
      },
      :job_poster => '',
      :active => true,
      :min_work_experience => lambda{ |job| (job.work_experience.min_range rescue nil) || '' },
      :max_work_experience => lambda{ |job| (job.work_experience.max_range rescue nil) || '' },
      :internal_reference_number => lambda{ |job| (job.contact_detail.job_id rescue nil)  || ''},
      :kind_of_job => lambda{ |job|
        Vger::Spartan::Opus::KindOfJob.find(job.kind_of).name rescue nil
      },
      :job_industries => lambda{ |job|
        (job.industries || []).map { |industry|
          Vger::Spartan::Opus::Recommendation.find(industry).bucket.alias rescue nil
        }.compact.join(",")
      },
      :soft_skills => lambda{ |job|
        #TODO: fix this
        [
         "Spoken English:#{job.spoken_skill}",
         "Written English:#{job.written_skill}"
        ].join(",")
      },
      :academic_performance => '',
      :academic_qualifications => lambda{ |job|
        ((job.qualification.degree_diploma.zip(job.qualification.specialization) rescue nil) || []).map { |degree, career|
          [
           (Vger::Spartan::Opus::Recommendation.find(degree).name rescue ''),
           (Vger::Spartan::Opus::Recommendation.find(career).name rescue '')
          ].join(":")
        }.join(",")
      },
      :candidate_industries => lambda{ |job|
        ((job.candidate.industry.id rescue nil) || []).map { |industry|
          Vger::Spartan::Opus::Recommendation.find(industry).bucket.alias rescue nil
        }.compact.join(",")
      },
      :gender => lambda{ |job|
        (Vger::Spartan::Dilios::Gender.find(job.candidate.personal.gender).name rescue nil) || ''
      },
      :marital_status => lambda{ |job|
        (Vger::Spartan::Dilios::MaritalStatus.find(job.candidate.personal.marital_status).name rescue nil) || ''
      },
      :abilities => '',
      :traits => lambda{ |job|
        (job.trait || []).map { |trait|
          Vger::Spartan::Dilios::Trait.find(trait).name rescue nil
        }.compact.join(",")
      },
      :interests => '',
      :candidate_locations => lambda{ |job|
        (((job.candidate.location.id) rescue nil) || []).map { |location|
          Vger::Penumbra::Geography.find(location).name rescue nil
        }.compact.join(",")
      },
      :perks => lambda{ |job|
        (job.perk || []).map { |perk|
          Vger::Spartan::Opus::JobPerk.find(perk).name rescue nil
        }.compact.join(",")
      },
      :additional_perks => :additional_perk,
      :involves_travel => :involves_travel,
      :government_job => :government_job,
      :walkin => :walkin,
      :own_vehicle => :own_vehicle,
      :other_work_profile => '',
      :candidate_companies => lambda{ |job|
        (job.additional_detail.candidate.company_history rescue nil) || ''
      },
      :candidate_job_titles => lambda{ |job|
        (job.additional_detail.candidate.job_title rescue nil) || ''
      },
      :candidate_profile_keywords => lambda{ |job|
        (job.additional_detail.candidate.keyword rescue nil) || ''
      },
      :candidate_kind_blacklist => lambda{ |job|
        (job.additional_detail.candidate.undesired rescue nil) || ''
      },
      :optional_skills => lambda{ |job|
        ((job.skill.nice.skill_id rescue nil) || []).map { |skill_id|
          Vger::Spartan::Opus::Recommendation.find(skill_id).name rescue nil
        }.compact.join(",")
      },
      :weekly_offs => lambda{ |job|
        (job.offday || []).map { |day|
          Vger::Spartan::WeekDay.find(day).name rescue nil
        }.compact.join(",")
      },

      :reference_key => :uuid,
      :recruiter_sid => :posted_by,
      :created_date => :created_at
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

    file = "RecruiterPendingJobs_#{Date.today.strftime('%d%m%y')}_#{Time.now.strftime('%H_%M_%S')}.csv"
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
