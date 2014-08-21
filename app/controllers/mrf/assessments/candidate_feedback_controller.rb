class Mrf::Assessments::CandidateFeedbackController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_assessment

  layout 'mrf'

  def statistics
  end

  def stakeholders
  end
  
  def select_candidates
  end

  def add_stakeholders
    params[:candidate] ||= {}
    params[:stakeholders] ||= {}
    10.times do |index|
      params[:stakeholders][index.to_s] ||= {}
    end
    if request.put?
      if params[:candidate][:email].present?
        candidate = Vger::Resources::Candidate.where(query_options: { email: params[:candidate][:email] }).all.to_a.first
      end
      if !candidate
        candidate = Vger::Resources::Candidate.create(params[:candidate])
        if !candidate.error_messages.empty?
          flash[:error] = candidate.error_messages.join("<br/>").html_safe
          return
        end
      end
      stakeholders = params[:stakeholders].select{|index,stakeholder| stakeholder[:email].present? and stakeholder[:name].present? }
      if stakeholders.empty?
        flash[:error] = "Please add atleast 1 stakeholder"
        return
      end
      stakeholders.each do |index, stakeholder|
        feedback = Vger::Resources::Mrf::Feedback.where(:company_id => @company.id, :assessment_id => @assessment.id, query_options: { 
          email: stakeholder[:email], 
          assessment_id: @assessment.id, 
          role: stakeholder[:role], 
          candidate_id: candidate.id 
        }).all.to_a.first
        if !feedback
          feedback = Vger::Resources::Mrf::Feedback.create(
            company_id: @company.id,
            email: stakeholder[:email],
            name: stakeholder[:name],
            assessment_id: @assessment.id, 
            role: stakeholder[:role], 
            candidate_id: candidate.id,
            last_item_index: -1,
            status: Vger::Resources::Mrf::Feedback::Status::NEW
          )
          if !feedback.error_messages.empty?
            flash[:error] = feedback.error_messages.join("<br/>").html_safe
            return
          end  
        end
      end
      flash[:notice] = "Invitations sent to stakeholders"
      if params[:send_and_add_more].present?
        params[:candidate] = {}
        params[:stakeholders] = {}
        10.times do |index|
          params[:stakeholders][index.to_s] = {}
        end
      else
        redirect_to candidates_company_mrf_assessment_path(@company.id, @assessment.id)
      end
    end
    get_custom_assessment
  end
  
  def bulk_upload
    s3_bucket_name = "bulk_upload_mrf_candidates_#{Rails.env.to_s}"
    s3_key = "mrf_candidates_#{@assessment.id}_#{Time.now.strftime("%d_%m_%Y_%H_%M_%S_%P")}"
    unless params[:bulk_upload][:file]
      flash[:error] = "Please select a csv file."
      redirect_to add_candidates_url and return
    end
    data = params[:bulk_upload][:file].read
    S3Utils.upload(s3_bucket_name, s3_key, data)
    @s3_bucket = s3_bucket_name
    @s3_key = s3_key
    Vger::Resources::Mrf::Feedback\
      .import_from_s3_files(:email => current_user.email,
                    :company_id => @company.id,
                    :assessment_id => @assessment.id,
                    :sender_type => current_user.type,
                    :sender_name => current_user.name,
                    :worksheets => [{
                      :file => "BulkUpload.csv",
                      :bucket => @s3_bucket,
                      :key => @s3_key
                    }]
                   )
    redirect_to details_company_mrf_assessment_url(@company.id,@assessment.id), 
                notice: "Bulk upload in progress."
    #render :action => :preview
  end
  
  def bulk_send_invitations
    Vger::Resources::Mf::Feedback\
      .import_from_s3_files(:email => current_user.email,
                    :assessment_id => @assessment.id,
                    :sender_type => current_user.type,
                    :sender_name => current_user.name,
                    :worksheets => [{
                      :file => "BulkUpload.csv",
                      :bucket => params[:s3_bucket],
                      :key => params[:s3_key]
                    }]
                   )
    redirect_to company_mrf_assessment_url(@company.id,@assessment.id), 
                notice: "Bulk upload in progress."
  end
  
  def preview
  end

  protected  
  
  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

  def get_assessment
    if params[:id].present?
      @assessment = Vger::Resources::Mrf::Assessment.find(params[:id], company_id: @company.id, :include => {:assessment_traits => { methods: [:trait] } })
    else
      @assessment = Vger::Resources::Mrf::Assessment.new
    end
  end

  def get_custom_assessment
    if @assessment.custom_assessment_id.present?
      @custom_assessment = Vger::Resources::Suitability::CustomAssessment.find(@assessment.custom_assessment_id)
    end
  end
end
