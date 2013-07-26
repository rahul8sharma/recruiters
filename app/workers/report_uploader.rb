class ReportUploader < AbstractController::Base
  include Sidekiq::Worker
  
  include AbstractController::Rendering
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include Rails.application.routes.url_helpers
  helper ApplicationHelper
  self.view_paths = "app/views"
  
  def perform(report_id, auth_token)
    RequestStore.store[:auth_token] = auth_token
    
    report = Vger::Resources::Suitability::CandidateAssessmentReport.find(report_id, :methods => [ :candidate_assessment ])
    
    @candidate_assessment = report.candidate_assessment
    get_assessment(@candidate_assessment)
    tries = 0
    report_status = {
      :errors => [],
      :message => "",
      :status => "success"
    }
    begin
      html = render_to_string(template: 'assessment_reports/assessment_report.html.haml', :layout => "layouts/reports.html.haml", :handlers => [ :haml ])
      pdf = WickedPdf.new.pdf_from_string(html)
      
      FileUtils.mkdir_p(Rails.root.join("tmp"))
      pdf_file_id = "report_#{report.id}.pdf"
      html_file_id = "report_#{report.id}.html"
      pdf_save_path = Rails.root.join('tmp',"#{pdf_file_id}")
      html_save_path = Rails.root.join('tmp',"#{html_file_id}")
      
      Vger::Resources::Suitability::CandidateAssessmentReport.save_existing(report.id,  
        :status => Vger::Resources::Suitability::CandidateAssessmentReport::Status::UPLOADING
      )
      File.open(html_save_path, 'wb') do |file|
        file << html
      end
      File.open(pdf_save_path, 'wb') do |file|
        file << pdf
      end
      pdf_s3 = upload_pdf_to_s3(pdf_file_id,File.open(pdf_save_path,"r"))
      html_s3 = upload_pdf_to_s3(html_file_id,File.open(html_save_path,"r"))
      Vger::Resources::Suitability::CandidateAssessmentReport.save_existing(report.id,  
        :s3_keys => { :pdf => pdf_s3, :html => html_s3 },
        :status => Vger::Resources::Suitability::CandidateAssessmentReport::Status::UPLOADED
      )
      File.delete(pdf_save_path)
      File.delete(html_save_path)
      
      SystemMailer.delay.notify_report_status("Report Uploader","Upload report #{report.id}",{
        :report => {
          :status => "Success"
        }
      })
    rescue Exception => e
      Rails.logger.debug e.message
      tries = tries + 1
      if tries < 5
        retry
      else   
        Vger::Resources::Suitability::CandidateAssessmentReport.save_existing(report.id,  
          :status => Vger::Resources::Suitability::CandidateAssessmentReport::Status::FAILED
        )
      end
      SystemMailer.delay.notify_report_status("Report Uploader","Failed to upload report #{report.id}",{
        :errors => {
          :backtrace => [e.message] + e.backtrace[0..20]
        } 
      })
    end  
    
  end
  
  def upload_pdf_to_s3(file_id,pdf)
    Rails.logger.debug "Uploading #{file_id} to s3 ........."
    AWS::S3::Base.establish_connection!(Rails.application.config.s3)
    s3_bucket_name = Rails.application.config.s3_buckets[Rails.env.to_s]["bucket_name"]
    s3_key = "#{file_id}"
    url = S3Utils.upload(s3_bucket_name, s3_key, pdf)
    Rails.logger.debug "Uploaded #{file_id} with url #{url} to s3"
    return { :bucket => s3_bucket_name, :key => s3_key }
  end
  
  def get_assessment(candidate_assessment)
    @assessment = Vger::Resources::Suitability::Assessment.find(candidate_assessment.assessment_id) 
    @candidate = Vger::Resources::Candidate.find(candidate_assessment.candidate_id)
   @assessment_factor_norms = Hash[@assessment.job_assessment_factor_norms.where(:methods => [ :from_norm_bucket, :to_norm_bucket ]).all.to_a.collect{|x| [x.factor_id,x]}]
    get_factors
    get_measured_factors
    get_page1_data
    get_page2_data
    get_page3_data
    get_page4_data
    get_page5_data
  end
  
  def get_factors
    @factors = Vger::Resources::Suitability::Factor.where(:methods => [:type]).all.to_a
    @direct_predictors = Vger::Resources::Suitability::DirectPredictor.where(:methods => [:parent,:type]).all.to_a
    @alarm_factors = Vger::Resources::Suitability::AlarmFactor.where(:methods => [:type]).all.to_a
    @factors |= @direct_predictors 
    @factors |= @alarm_factors
    @factors_by_id = Hash[@factors.collect{|x| [x.id,x]}]
    @parent_factors = @direct_predictors.collect{|factor| @factors_by_id[factor.parent_id] }
  end
  
  def get_measured_factors
    @candidate_factor_scores = Hash[@candidate_assessment.candidate_factor_scores.where(:methods => [:norm_bucket]).to_a.each{|x| x.factor = @factors_by_id[x.factor_id]}.collect{|x| [x.factor_id,x]}]
    @measured_factors = Vger::Resources::Suitability::Factor.where(:query_options => { :type => "Suitability::Factor",  :id => @candidate_factor_scores.values.map(&:factor_id) })
    #@measured_factors |= Vger::Resources::Suitability::DirectPredictor.where(:query_options => { :id => @candidate_factor_scores.values.map(&:factor_id) }) 
    #@measured_factors |= Vger::Resources::Suitability::AlarmFactor.where(:query_options => { :id => @candidate_factor_scores.values.map(&:factor_id) }) 
    @measured_factors_ids = @measured_factors.map(&:id).compact
  end
  
  def get_page1_data
    @recommendation = Vger::Resources::Suitability::Recommendation.where(:query_options => { 
      :overall_fitment_grade_id => @candidate_assessment.overall_fitment_grade_id,
      :candidate_stage => @candidate_assessment.candidate_stage 
    }).all[0]
    @candidate_fit_scores = @candidate_assessment.candidate_fit_scores.where(:methods => [:fitment_grade, :fit]).to_a
  end
  
  def get_page2_data
    @factors_by_fit = {}
    @fits = Vger::Resources::Suitability::Fit.all.to_a
    @fits.each do |fit|
      @factors_by_fit[fit] = (@factors - @direct_predictors - @alarm_factors - @parent_factors).select{|x| fit.factor_ids.include? x.id}
    end
    @candidate_fit_scores = @candidate_assessment.candidate_fit_scores.where(:methods => [:fitment_grade, :fit]).to_a
    
    @job_fit = get_job_fit(@fits)
    @company_fit = get_company_fit(@fits)
    @team_fit = get_team_fit(@fits)

    @job_fit_grade = get_job_fit_grade(@candidate_fit_scores)
    @company_fit_grade = get_company_fit_grade(@candidate_fit_scores)
    @team_fit_grade = get_team_fit_grade(@candidate_fit_scores)
  end
  
  def get_page3_data
    @factor_norm_bucket_descriptions_by_norm_bucket = Vger::Resources::Suitability::FactorNormBucketDescription.where(:query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{|x| x.factor_id}
    @factor_norm_bucket_descriptions_by_norm_bucket.each{|x,y| @factor_norm_bucket_descriptions_by_norm_bucket[x] = y.group_by{|z| z.norm_bucket_id}}
  end
  
  def get_page4_data
    @candidate_factor_scores_for_direct_predictors = @candidate_factor_scores.select do |factor_id,factor_score| 
      factor_score.factor.type == "Suitability::DirectPredictor" and factor_score.pass
    end
    
    alarm_factor_ids = @candidate_factor_scores.keys
    alarm_factors = Vger::Resources::Suitability::AlarmFactor.where(:query_options => { :id => alarm_factor_ids }) 
    
    @candidate_factor_scores_for_alarm_factors = @candidate_factor_scores.select{|factor_id,factor_score| alarm_factors.map(&:id).include?(factor_id) }.select{|factor_id,factor_score| ["above average", "high"].any?{|w| factor_score.norm_bucket.name.downcase =~ /#{w}/ } }    
    
    @factor_norm_bucket_descriptions = Vger::Resources::Suitability::FactorNormBucketDescription.where(:query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{|x| x.factor_id}
  end
  
  def get_page5_data
    @post_assessment_guidelines = Vger::Resources::Suitability::PostAssessmentGuideline.where( :methods => [ :factor ], :query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{ |x| x.factor_id }
  end
  
  def get_job_fit_grade(candidate_fit_scores)
    candidate_fit_scores.select{ |fit_score| ["job","role"].any?{|fit_name| fit_score.fit.name.downcase =~ /#{fit_name}/ } }.first.fitment_grade.name
  end
  
  def get_company_fit_grade(candidate_fit_scores)
    candidate_fit_scores.select{ |fit_score| ["organization","company"].any?{|fit_name| fit_score.fit.name.downcase =~ /#{fit_name}/ } }.first.fitment_grade.name
  end
  
  def get_team_fit_grade(candidate_fit_scores)
    candidate_fit_scores.select{ |fit_score| ["team","people"].any?{|fit_name| fit_score.fit.name.downcase =~ /#{fit_name}/ } }.first.fitment_grade.name
  end
  
  def get_job_fit(fits)
    fits.select{|fit| ["job","role"].any?{|fit_name| fit.name.downcase =~ /#{fit_name}/ }  }.first
  end
  
  def get_company_fit(fits)
    fits.select{|fit| ["organization","company"].any?{|fit_name| fit.name.downcase =~ /#{fit_name}/ }  }.first
  end
  
  def get_team_fit(fits)
    fits.select{|fit| ["team","people"].any?{|fit_name| fit.name.downcase =~ /#{fit_name}/ }  }.first
  end
end
