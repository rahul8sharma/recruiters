class PagesController < ApplicationController
  before_filter :authenticate_user!
  layout 'admin'

  def home
  end

  def report_management
  end

  def report_generator
    @functional_areas = Hash[Vger::Resources::FunctionalArea.where(:query_options => {:active=>true},:order => "name ASC")\
                          .all.to_a.collect{|x| [x.id,x]}]
    @industries = Hash[Vger::Resources::Industry.where(:query_options => {:active=>true},:order => "name ASC")\
                        .all.to_a.collect{|x| [x.id,x]}]
    @job_experiences = Hash[Vger::Resources::JobExperience.active.all.to_a.collect{|x| [x.id,x]}]
  end


  def report_generator_scores
    if request.post?
      # Figure out from which flow has the user submitted the page
      # Via Existing Assessment flow OR
      # Via New Assessment flow
      if params[:assessment][:assessment_id].present? #user has come via existing assessment flow
        #load custom assessment_id
        @assessment = Vger::Resources::Suitability::CustomAssessment.find(params[:assessment][:assessment_id], :include => [:functional_area, :industry, :job_experience], :methods => [:competency_ids])
        # handle assessment not found scenario
        #load assessment_factor_norms
        @assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:include => { :factor => { :methods => [:type] } }).all.to_a
        if @assessment.assessment_type == Vger::Resources::Suitability::CustomAssessment::AssessmentType::COMPETENCY
          competency_ids = @assessment.competency_ids
          @competencies = Vger::Resources::Suitability::Competency.find(competency_ids)
        end
        @norm_buckets = Vger::Resources::Suitability::NormBucket.where(:order => "weight ASC").all
        @objective_items = Vger::Resources::ObjectiveItem.where(:query_options => { :active => true}, :include => [ :options ]).all.to_a
        objective_ids = @objective_items.map(&:id)
        # @objective_options = Vger::Resources::ObjectiveOption.where(:query_options => {:objective_item_ids => objective_ids})
        # @objective_options = @objective_options.group_by { |option| option.objective_item_id}
        @subjective_items = Vger::Resources::SubjectiveItem.active.all.to_a
        #Show candidate details
        @candidate_details = params[:report]
        #show flags
      else

        #Create New Custom Assessment
        #Figure out Competency Norms Assessment Norms Logic
        #show flags
        #Show candidate details
      end
    end
  end

  def generate_report
    Vger::Resources::Suitability::CustomAssessment.generate_report(params[:report])
  end

  def manage_report
    redirect_to manage_company_assessment_candidate_candidate_assessment_report_url(
      :id => params[:assessment][:report_id],
      :company_id => params[:assessment][:company_id],
      :candidate_id => params[:assessment][:candidate_id],
      :assessment_id => params[:assessment][:assessment_id]
    )
  end

  def modify_norms
    if params[:assessment][:assessment_id].present? && params[:assessment][:company_id].present?
	    assessment_id = params[:assessment][:assessment_id]
      company_id = params[:assessment][:company_id]
      assessment = Vger::Resources::Suitability::CustomAssessment.find(assessment_id)
      if assessment.assessment_type == "fit"
        redirect_to norms_company_assessment_path(:id => assessment_id, :company_id => company_id)
      else
        redirect_to competency_norms_company_assessment_path(:id => assessment_id, :company_id => company_id)
      end
    else
      redirect_to report_management_path, alert: "Please specify correct company id and assessment_id"
    end
  end
end
