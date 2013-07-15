class AssessmentReportsController < ApplicationController
  before_filter :get_assessment
  before_filter :get_factors, :only => [ :assessment_report, :page2, :page3, :page4, :page5 ]
  before_filter :get_measured_factors, :only => [ :assessment_report, :page2, :page3, :page4, :page5 ]
  
  def assessment_report
    @recommendation = Vger::Resources::Suitability::Recommendation.where(:query_options => { 
      :overall_fitment_grade_id => @candidate_assessment.overall_fitment_grade_id,
      :candidate_stage => @candidate_assessment.candidate_stage 
    }).all[0]
    @candidate_fit_scores = @candidate_assessment.candidate_fit_scores.where(:per => 10000, :methods => [:fitment_grade, :fit]).to_a
    
    @factors_by_fit = {}
    @fits = Vger::Resources::Suitability::Fit.all.to_a
    @fits.each do |fit|
      @factors_by_fit[fit] = (@factors - @direct_predictors - @alarm_factors - @parent_factors).select{|x| fit.factor_ids.include? x.id}
    end
    
    @factor_norm_bucket_descriptions_by_norm_bucket = Vger::Resources::Suitability::FactorNormBucketDescription.where(:per => 100, :query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{|x| x.factor_id}
    @factor_norm_bucket_descriptions_by_norm_bucket.each{|x,y| @factor_norm_bucket_descriptions_by_norm_bucket[x] = y.group_by{|z| z.norm_bucket_id}}
    
    @candidate_factor_scores_for_alarms = @candidate_factor_scores.select{|factor_id,factor_score| factor_score.norm_bucket_id.nil? and factor_score.pass }
    
    @alarm_factors = Vger::Resources::Suitability::AlarmFactor.where(:query_options => { :id => @candidate_factor_scores_for_alarms.values.map(&:factor_id) }) 
    
    @factor_norm_bucket_descriptions = Vger::Resources::Suitability::FactorNormBucketDescription.where(:per => 100, :query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{|x| x.factor_id}
    
    @post_assessment_guidelines = Vger::Resources::Suitability::PostAssessmentGuideline.where(:per => 100, :query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{|x| x.factor_id}
    @post_assessment_guidelines.each{|x,y| @post_assessment_guidelines[x] = y.group_by{|z| z.norm_bucket_id}}
    
    respond_to do |format|
      format.html { render :layout => "reports" }
      format.pdf { render :pdf => "report", :layout => "reports.html.haml", :handlers => [ :haml ], :template => "assessment_reports/assessment_report.html.haml" }
    end
  end
  
  def page1
    @recommendation = Vger::Resources::Suitability::Recommendation.where(:query_options => { 
      :overall_fitment_grade_id => @candidate_assessment.overall_fitment_grade_id,
      :candidate_stage => @candidate_assessment.candidate_stage 
    }).all[0]
    @candidate_fit_scores = @candidate_assessment.candidate_fit_scores.where(:per => 10000, :methods => [:fitment_grade, :fit]).to_a
    respond_to do |format|
      format.html { render :layout => "reports" }
      format.pdf { render :pdf => "report", :layout => "reports.html.haml", :handlers => [ :haml ], :template => "assessment_reports/page1.html.haml" }
    end
  end  
  
  def page2
    @factors_by_fit = {}
    @fits = Vger::Resources::Suitability::Fit.all.to_a
    @fits.each do |fit|
      @factors_by_fit[fit] = (@factors - @direct_predictors - @alarm_factors - @parent_factors).select{|x| fit.factor_ids.include? x.id}
    end
    respond_to do |format|
      format.html { render :layout => "reports" }
      format.pdf { render :pdf => "report", :layout => "reports.html.haml", :template => "assessment_reports/page2.html.haml" }
    end
  end  
  
  def page3
    @factor_norm_bucket_descriptions_by_norm_bucket = Vger::Resources::Suitability::FactorNormBucketDescription.where(:per => 100, :query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{|x| x.factor_id}
    @factor_norm_bucket_descriptions_by_norm_bucket.each{|x,y| @factor_norm_bucket_descriptions_by_norm_bucket[x] = y.group_by{|z| z.norm_bucket_id}}
    respond_to do |format|
      format.html { render :layout => "reports" }
      format.pdf { render :pdf => "report", :layout => "reports.html.haml", :template => "assessment_reports/page3.html.haml" }
    end
  end  
  
  def page4
    @candidate_factor_scores_for_alarms = @candidate_factor_scores.select{|factor_id,factor_score| factor_score.norm_bucket_id.nil? and factor_score.pass }
    
    @alarm_factors = Vger::Resources::Suitability::AlarmFactor.where(:query_options => { :id => @candidate_factor_scores_for_alarms.values.map(&:factor_id) }) 
    
    @factor_norm_bucket_descriptions = Vger::Resources::Suitability::FactorNormBucketDescription.where(:per => 100, :query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{|x| x.factor_id}
    respond_to do |format|
      format.html { render :layout => "reports" }
      format.pdf { render :pdf => "report", :layout => "reports.html.haml", :handlers => [ :haml ], :template => "assessment_reports/page4.html.haml" }
    end
  end  
  
  def page5
    @post_assessment_guidelines = Vger::Resources::Suitability::PostAssessmentGuideline.where(:per => 100, :query_options => { :factor_id => @measured_factors_ids }).to_a.group_by{|x| x.factor_id}
    @post_assessment_guidelines.each{|x,y| @post_assessment_guidelines[x] = y.group_by{|z| z.norm_bucket_id}}
    respond_to do |format|
      format.html { render :layout => "reports" }
      format.pdf { render :pdf => "report", :layout => "reports.html.haml", :template => "assessment_reports/page5.html.haml" }
    end
  end  
  
  protected
  
  def get_assessment
    @assessment = Vger::Resources::Suitability::Assessment.find(params[:id]) 
    @candidate = Vger::Resources::Candidate.find(params[:candidate_id])
    @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(
      :assessment_id => params[:id], 
      :query_options => {
        :candidate_id => @candidate.id
      }
    ).all[0]
  end
  
  def get_factors
    @factors = Vger::Resources::Suitability::Factor.where(:per => 100).all.to_a
    @direct_predictors = Vger::Resources::Suitability::DirectPredictor.where(:methods => [:parent], :per => 100).all.to_a
    @alarm_factors = Vger::Resources::Suitability::AlarmFactor.where(:per => 100).all.to_a
    @factors |= @direct_predictors 
    @factors |= @alarm_factors
    @factors_by_id = Hash[@factors.collect{|x| [x.id,x]}]
    @parent_factors = @direct_predictors.collect{|factor| @factors_by_id[factor.parent_id] }
  end
  
  def get_measured_factors
    @candidate_factor_scores = Hash[@candidate_assessment.candidate_factor_scores.where(:per => 10000).to_a.each{|x| x.factor = @factors_by_id[x.factor_id]}.collect{|x| [x.factor_id,x]}]
    @measured_factors = Vger::Resources::Suitability::Factor.where(:query_options => { :id => @candidate_factor_scores.values.map(&:factor_id) })
    @measured_factors |= Vger::Resources::Suitability::DirectPredictor.where(:query_options => { :id => @candidate_factor_scores.values.map(&:factor_id) }) 
    @measured_factors |= Vger::Resources::Suitability::AlarmFactor.where(:query_options => { :id => @candidate_factor_scores.values.map(&:factor_id) }) 
    @measured_factors_ids = @measured_factors.map(&:id).compact
  end
end
