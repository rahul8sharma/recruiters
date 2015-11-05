class Sjt::AssessmentsController < Suitability::CustomAssessmentsController
  layout 'sjt/sjt'


  def home
    order_by = params[:order_by] || "created_at"
    params[:order_by] ||= order_by
    order_type = params[:order_type] || "DESC"
    @assessments = api_resource.where(
      :query_options => { 
        :company_id => params[:company_id], 
        :assessment_type => ["sjt_competency"] 
      }, 
      :order => "#{order_by} #{order_type}", 
      :page => params[:page], 
      :per => 15
    )
  end

  def create
    respond_to do |format|
      if @assessment.valid? and @assessment.save
        if params[:defined_form_id].present?
          factual_information_form = Vger::Resources::FormBuilder::FactualInformationForm.create({
            :defined_form_id => params[:defined_form_id],
            :company_id => @company.id,
            :assessment_type => "Suitability::CustomAssessment",
            :assessment_id => @assessment.id
          })
        end
        redirect_path = competencies_company_sjt_assessment_path(:company_id => params[:company_id], :id => @assessment.id)
        format.html { redirect_to redirect_path }
      else
        get_meta_data
        add_set
        flash[:error] = @assessment.error_messages.join("<br/>") rescue ""
        format.html { render action: "new" }
      end
    end
  end

  def edit
  end

  def new
  end

  def competencies
    get_competencies(:for_sjt)
    if request.put?
      check_competencies_and_proceed
    end
  end

  def competencies_measured
    @competencies = Vger::Resources::Suitability::Competency.where(
      :query_options => {
        :id => @assessment.competency_order
      }, 
      :methods => [:factor_names], 
      :order => ["name ASC"]
    ).to_a
  end

  def competencies_url
    add_candidates_company_sjt_assessment_path(:company_id => params[:company_id], :id => @assessment.id)
  end


end