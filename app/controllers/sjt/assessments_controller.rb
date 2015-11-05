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
    if request.get?
    else
      params[:assessment] ||= {}
      params[:assessment][:competencies] ||= []
      if params[:assessment][:competencies].blank?
        flash[:error] = "Competencies to be measured must be selected before proceeding!"
        return
      else
        selected_competency_ids = params[:assessment][:competencies].map(&:to_i)
        selected_competencies = Hash[params[:assessment][:competency_order].select{|competency_id,order| selected_competency_ids.include?(competency_id.to_i) }]
        competency_order = Hash[selected_competencies.map{|competency_id,order| [competency_id.to_i,order.to_i] }]
        competency_order = Hash[competency_order.sort_by{|competency_id, order| order }]
        if competency_order.values.size != competency_order.values.uniq.size
          flash[:error] = "Competencies should have unique order!"
          return
        end
        ordered_competencies = competency_order.keys.select{|competency_id| selected_competency_ids.include?(competency_id) }
        @assessment = api_resource.save_existing(@assessment.id, { competency_order: ordered_competencies })
        if @assessment.error_messages.blank?
          redirect_to add_candidates_company_sjt_assessment_path(:company_id => params[:company_id], :id => @assessment.id)
        else
          flash[:error] = @assessment.error_messages.join("<br/>")
        end
      end
    end
  end

end