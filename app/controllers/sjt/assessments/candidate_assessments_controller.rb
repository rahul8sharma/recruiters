class Sjt::Assessments::CandidateAssessmentsController < Suitability::CustomAssessments::CandidateAssessmentsController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company

  layout 'sjt/sjt'

  def candidate
  end
  
  def candidates
  end

  def competencies_measured
  end

  def reports
  end
  
  def add_candidates
    params[:candidates] ||= {}
    params[:candidates].reject!{|key,data| data[:email].blank? && data[:name].blank?}
    params[:upload_method] ||= "manual"
    @errors = {}
    @functional_areas = Vger::Resources::FunctionalArea.active.all.to_a
    assessment_factor_norms = @assessment.job_assessment_factor_norms.all.to_a
    functional_assessment_traits = @assessment.functional_assessment_traits.all.to_a
    add_candidates_allow = assessment_factor_norms.size >= 1 || functional_assessment_traits.size >= 1
    if request.put?
      if params[:candidate_stage].empty?
        flash[:error] = "Please select the purpose of assessing these Assessment Takers before proceeding!"
        render :action => :add_candidates and return
      else
        candidates = {}
        if params[:candidates].empty?
          flash[:error] = "Please add at least 1 Assessment Taker to send the assessment. You may also select 'Add Assessment Takers Later' to save the assessment and return to the Assessment Listings."
          render :action => :add_candidates and return
        end

        params[:candidates].each do |key,candidate_data|
          @errors[key] ||= []
          if @assessment.set_applicant_id && !(/^[0-9]{8}$/.match(candidate_data[:applicant_id]).present?)
            @errors[key] << "Applicant ID is invalid."
          end
          if candidate_data[:email].present?
            candidate = Vger::Resources::Candidate.where(:query_options => { :email => candidate_data[:email] }).all[0]
          end
          
          if candidate
            candidate_data[:id] = candidate.id
            candidates[candidate.id] = candidate_data
            attributes_to_update = candidate_data.dup
            attributes_to_update.delete(:applicant_id)
            attributes_to_update.each { |attribute,value| attributes_to_update.delete(attribute) unless candidate.send(attribute).blank? }
            Vger::Resources::Candidate.save_existing(candidate.id, attributes_to_update)
          else
            attributes = candidate_data.dup
            attributes.delete(:applicant_id)
            candidate = Vger::Resources::Candidate.find_or_create(attributes)
            if candidate.error_messages.present?
              @errors[key] |= candidate.error_messages
            else
              candidate_data[:id] = candidate.id
              candidates[candidate.id] = candidate_data
            end
          end
        end

        unless @errors.values.flatten.empty?
          #flash[:error] = "Errors in provided data: <br/>".html_safe
          flash[:error] = @errors.map.with_index do |(candidate_name, candidate_errors), index|
            if candidate_errors.present?
              ["#{candidate_errors.join("<br/>")}"]
            end
          end.compact.uniq.join("<br/>").html_safe
          render :action => :add_candidates and return
        end
        get_templates(params[:candidate_stage])
        params[:send_test_to_candidates] = true
        params[:candidates] = candidates
        if @company.subscription_mgmt
          get_packages
        end
        render :action => :send_test_to_candidates
      end
    else
      if !add_candidates_allow
        flash[:error] = "You need to select traits before sending an assessment. Please select traits from below."
        redirect_to competencies_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
      end
    end
  end

  def candidates_url
    candidates_company_sjt_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end


end