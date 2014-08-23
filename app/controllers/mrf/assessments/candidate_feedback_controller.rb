require 'csv'
require 'fileutils'
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
    if request.get?
      get_custom_assessment
      get_candidates
    else
      if params[:candidate_ids].nil? || params[:candidate_ids].keys.size == 0
        get_custom_assessment
        get_candidates
        flash[:error] = "Please add atleast 1 candidate"
        render :action => :select_candidates
      else
        redirect_to add_stakeholders_company_mrf_assessment_path(@company.id,@assessment.id, :candidate_ids => params[:candidate_ids].keys.join("|")) and return
      end      
    end
  end

  def download_sample_csv_for_mrf_bulk_upload
    # To be re looked in next release
    #get_custom_assessment
    #if @custom_assessment
    #  get_candidates(10000)
    #  target = Rails.root.join("tmp/bulk_upload_#{@assessment.id}.csv")
    #  source = Rails.application.assets['mrf_bulk_upload_template.csv'].pathname.to_s
    #  FileUtils.cp(source,target)
    #  csv = CSV.open(target, "a") do |csv|
    #    @candidates.each do |candidate|
    #      arr = [candidate.name,candidate.email]
    #      csv << arr
    #    end
    #  end
    #  File.open(target,"r") do |f|
    #    send_data(f.read,type: "text/csv",:filename => "sample_csv_for_bulk_upload_#{@assessment.id}.csv")
    #  end  
    #  File.delete target  
    #else
    file_path = Rails.application.assets['mrf_bulk_upload.csv'].pathname
    send_file(file_path,
        :filename => "sample_csv_for_bulk_upload.csv")
    #end
  end

  def add_stakeholders
    params[:candidate] ||= {}
    params[:feedbacks] ||= {}
    params[:candidate_ids] = params[:candidate_ids].to_s.split('|')
    10.times do |index|
      params[:feedbacks][index.to_s] ||= {}
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
      feedbacks = params[:feedbacks].select{|index,feedback_hash| feedback_hash[:email].present? and feedback_hash[:name].present? }
      if feedbacks.empty?
        flash[:error] = "Please add atleast 1 stakeholder"
        return
      end
      feedbacks.each do |index, feedback_hash|
        feedback = nil
        stakeholder = Vger::Resources::Stakeholder.where(query_options: { email: feedback_hash[:email] }).all.to_a.first
        if stakeholder
          feedback = Vger::Resources::Mrf::Feedback.where(:company_id => @company.id, :assessment_id => @assessment.id, query_options: { 
            stakeholder_id: stakeholder.id,
            assessment_id: @assessment.id, 
            role: feedback_hash[:role], 
            candidate_id: candidate.id 
          }).all.to_a.first
        end
        if !feedback
          stakeholder = Vger::Resources::Stakeholder.create(email: feedback_hash[:email], name: feedback_hash[:name]) if !stakeholder
          if !stakeholder.error_messages.present?
            feedback = Vger::Resources::Mrf::Feedback.create(
              stakeholder_id: stakeholder.id,
              company_id: @company.id,
              assessment_id: @assessment.id, 
              role: feedback_hash[:role], 
              candidate_id: candidate.id,
              last_item_index: -1,
              status: Vger::Resources::Mrf::Feedback::Status::NEW
            )
            if !feedback.error_messages.empty?
              flash[:error] = feedback.error_messages.join("<br/>").html_safe
              return
            end
          else
            flash[:error] = stakeholder.error_messages.join("<br/>").html_safe
            return
          end    
        end
      end
      flash[:notice] = "Invitations sent to stakeholders"
      if params[:send_and_add_more].present?
        params[:candidate] = {}
        params[:feedbacks] = {}
        10.times do |index|
          params[:feedbacks][index.to_s] = {}
        end
      else
        Vger::Resources::Mrf::Assessment.send_invitations(company_id: @company.id, id: @assessment.id)
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

  def get_candidates(per=44)
    @candidates = Vger::Resources::Candidate.where(
      joins: :candidate_assessments, 
      query_options: { 
        "suitability_candidate_assessments.assessment_id" => @assessment.custom_assessment_id
      }, 
      select: [:name, :email, "candidates.id"], 
      page: params[:page] || 1, 
      per: per
    ).all.to_a     
  end

end
