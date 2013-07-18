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
    begin
      html = render_to_string(template: 'assessment_reports/assessment_report.html.haml', :layout => "layouts/reports.html.haml", :handlers => [ :haml ])
      pdf = WickedPdf.new.pdf_from_string(html)
      
      pdf_file_id = "#{report.id}.pdf"
      html_file_id = "#{report.id}.html"
      pdf_save_path = Rails.root.join('reports',"#{pdf_file_id}")
      html_save_path = Rails.root.join('reports',"#{html_file_id}")
      
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
    rescue Exception => e
      Rails.logger.debug e.message
      tries = tries + 1
      if tries < 5
        retry
      else   
        Vger::Resources::Suitability::CandidateAssessmentReport.save_existing(report.id,  
          :status => Vger::Resources::Suitability::CandidateAssessmentReport::Status::FAILED
        )
        SystemMailer.delay.report_exception(e,"Report Uploader")
      end
    end  
  end
  
  def upload_pdf_to_s3(file_id,pdf)
    Rails.logger.debug "Uploading #{file_id} to s3 ........."
    AWS::S3::Base.establish_connection!(Rails.application.config.s3)
    s3_bucket_name = 'report_pdfs'
    s3_key = "#{file_id}"
    url = S3Utils.upload(s3_bucket_name, s3_key, pdf)
    Rails.logger.debug "Uploaded #{file_id} with url #{url} to s3"
    return { :bucket => s3_bucket_name, :key => s3_key }
  end
  
  def get_assessment(candidate_assessment)
    @assessment = Vger::Resources::Suitability::Assessment.find(candidate_assessment.assessment_id) 
    @candidate = Vger::Resources::Candidate.find(candidate_assessment.candidate_id)
    get_factors
    get_measured_factors
    get_page1_data
    get_page2_data
    get_page3_data
    get_page4_data
    get_page5_data
  end
  
  def get_factors
    @factors = Vger::Resources::Suitability::Factor.all.to_a
    @direct_predictors = Vger::Resources::Suitability::DirectPredictor.where(:methods => [:parent]).all.to_a
    @alarm_factors = Vger::Resources::Suitability::AlarmFactor.all.to_a
    @factors |= @direct_predictors 
    @factors |= @alarm_factors
    @factors_by_id = Hash[@factors.collect{|x| [x.id,x]}]
    @parent_factors = @direct_predictors.collect{|factor| @factors_by_id[factor.parent_id] }
  end
  
  def get_measured_factors
    @candidate_factor_scores = Hash[@candidate_assessment.candidate_factor_scores.where(:methods => [:norm_bucket]).to_a.each{|x| x.factor = @factors_by_id[x.factor_id]}.collect{|x| [x.factor_id,x]}]
    @measured_factors = Vger::Resources::Suitability::Factor.where(:query_options => { :id => @candidate_factor_scores.values.map(&:factor_id) })
    @measured_factors |= Vger::Resources::Suitability::DirectPredictor.where(:query_options => { :id => @candidate_factor_scores.values.map(&:factor_id) }) 
    @measured_factors |= Vger::Resources::Suitability::AlarmFactor.where(:query_options => { :id => @candidate_factor_scores.values.map(&:factor_id) }) 
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
  end
  
  def get_page3_data
    @factor_norm_bucket_descriptions_by_norm_bucket = Vger::Resources::Suitability::FactorNormBucketDescription.where(:query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{|x| x.factor_id}
    @factor_norm_bucket_descriptions_by_norm_bucket.each{|x,y| @factor_norm_bucket_descriptions_by_norm_bucket[x] = y.group_by{|z| z.norm_bucket_id}}
  end
  
  def get_page4_data
    @candidate_factor_scores_for_direct_predictors = @candidate_factor_scores.select{|factor_id,factor_score| factor_score.norm_bucket_id.nil? and factor_score.pass }
    
    alarm_factor_ids = @candidate_factor_scores.keys
    alarm_factors = Vger::Resources::Suitability::AlarmFactor.where(:query_options => { :id => alarm_factor_ids }) 
    
    @candidate_factor_scores_for_alarm_factors = @candidate_factor_scores.select{|factor_id,factor_score| alarm_factors.map(&:id).include?(factor_id) }.select{|factor_id,factor_score| ["above average", "high"].any?{|w| factor_score.norm_bucket.name.downcase =~ /#{w}/ } }    
    
    @factor_norm_bucket_descriptions = Vger::Resources::Suitability::FactorNormBucketDescription.where(:query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{|x| x.factor_id}
  end
  
  def get_page5_data
    @post_assessment_guidelines = Vger::Resources::Suitability::PostAssessmentGuideline.where(:query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{|x| x.factor_id}
    @post_assessment_guidelines.each{|x,y| @post_assessment_guidelines[x] = y.group_by{|z| z.norm_bucket_id}}
  end
end
