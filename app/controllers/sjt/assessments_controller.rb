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
    Rails.logger.ap("--LOGGER--")
    Rails.logger.ap(@assessments.size)
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
  end

  def add_candidates
  end

  def send_assessment
  end

  protected

end