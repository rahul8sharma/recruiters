require 'csv'
require 'fileutils'
class Mrf::Assessments::CandidateFeedbackController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_assessment
  before_filter :get_candidate, only: [:statistics, :stakeholders, :update_feedback]

  layout 'mrf/mrf'
  
  def expire_feedback_urls
    params[:options] ||= {}
    options = {
      :assessment => {
        :args => {
          :user_id => current_user.id,
          :assessment_id => params[:id]
        }.merge(params[:options])
      }
    }
    @assessment\
      .disable_feedbacks(options)
    redirect_to request.env['HTTP_REFERER'], notice: "Links are marked for expiration."
  end
  
  def update_feedback
    feedback = Vger::Resources::Mrf::Feedback.save_existing(params[:feedback_id],
      {
        company_id: @company.id, 
        assessment_id: @assessment.id, 
        active: params[:active]
      }
    )
    flash[:notice] = "Candidate successfully #{feedback.active ? 'enabled':'disabled'}."
    redirect_to candidate_stakeholders_company_mrf_assessment_path(@company.id, @assessment.id, @candidate.id)
  end

  def send_reminder
    if request.put?
      params[:options] ||= {}.to_yaml
      params[:options] = YAML.load(params[:options]) || {}
      params[:options].merge!(template_id: params[:template_id])
      Vger::Resources::Mrf::Assessment.send_reminders(company_id: @company.id, id: @assessment.id, options: params[:options])
      flash[:notice] = "Reminders sent successfully."
      redirect_to details_company_mrf_assessment_path(@company.id, @assessment.id)
    else
      get_templates(true)
      get_custom_assessment
    end
  end

  def enable_self_ratings
    Vger::Resources::Mrf::Assessment.enable_self_ratings(company_id: @company.id, id: @assessment.id, candidate_id: params[:candidate_id])
    flash[:notice] = "Self Ratings will be enabled shortly. Please refresh this page in some time to see updated statuses."
    redirect_to details_company_mrf_assessment_path(@company.id, @assessment.id)
  end

  def export_feedback_urls
    options = {
      email: Rails.application.config.emails[:jit_recipients][:product]+","+
                Rails.application.config.emails[:jit_recipients][:product_support]+","+
                Rails.application.config.emails[:jit_recipients][:psychs],
      assessment_id: @assessment.id
    }
    Vger::Resources::Mrf::Assessment.export_feedback_urls(company_id: @company.id, id: @assessment.id, options: options)
    flash[:notice] = "360 Degree urls for pending stakeholders will be generated and emailed soon."
    redirect_to details_company_mrf_assessment_path(@company.id, @assessment.id)
  end

  def export_report_urls
    options = {
      email: Rails.application.config.emails[:jit_recipients][:product]+","+
                Rails.application.config.emails[:jit_recipients][:product_support]+","+
                Rails.application.config.emails[:jit_recipients][:psychs],
      assessment_id: @assessment.id
    }
    Vger::Resources::Mrf::Assessment.export_report_urls(company_id: @company.id, id: @assessment.id, options: options)
    flash[:notice] = "360 Degree report urls for candidates will be generated and emailed soon."
    redirect_to details_company_mrf_assessment_path(@company.id, @assessment.id)
  end

  def statistics
    get_custom_assessment
    @feedbacks = Vger::Resources::Mrf::Feedback.group_count({
      company_id: @company.id,
      assessment_id: @assessment.id,
      joins: [:stakeholder_assessment],
      query_options: {
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id,
        candidate_id: @candidate.id
      },
      group: ["role"]
    })
    @completed_feedbacks = Vger::Resources::Mrf::Feedback.group_count({
      company_id: @company.id,
      assessment_id: @assessment.id,
      joins: [:stakeholder_assessment],
      query_options: {
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id,
        candidate_id: @candidate.id,
        status: Vger::Resources::Mrf::Feedback.completed_statuses
      },
      group: ["role"]
    })
    @self_feedback = Vger::Resources::Mrf::Feedback.where({
      company_id: @company.id,
      assessment_id: @assessment.id,
      joins: [:stakeholder_assessment],
      query_options: {
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id,
        candidate_id: @candidate.id,
        role: Vger::Resources::Mrf::Feedback::Role::SELF
      }
    }).last
    @report = Vger::Resources::Mrf::Report.where(
      query_options: {
        assessment_id: @assessment.id,
        candidate_id: @candidate.id
      },
      select: ["id","candidate_id","status"]
    ).all.last
  end

  def stakeholders
    order_by = params[:order_by] || "stakeholders.id"
    order_type = params[:order_type] || "ASC"
    order = "#{order_by} #{order_type}"
    @stakeholders = Vger::Resources::Stakeholder.where(
      joins: {:stakeholder_assessments => :feedbacks },
      query_options: {
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id,
        "mrf_feedbacks.candidate_id" => @candidate.id
      },
      order: order,
      per: 10,
      page: params[:page]
    )
    @stakeholder_assessments = Vger::Resources::Mrf::StakeholderAssessment.where(
      company_id: @company.id,
      assessment_id: @assessment.id,
      query_options: {
        "stakeholder_id" => @stakeholders.map(&:id),
        "assessment_id" => @assessment.id
      }
    ).all.group_by{|stakeholder_assessment| stakeholder_assessment.stakeholder_id }
    @feedbacks = Vger::Resources::Mrf::Feedback.where({
      company_id: @company.id,
      assessment_id: @assessment.id,
      query_options: {
        stakeholder_assessment_id: @stakeholder_assessments.values.flatten.map(&:id),
        candidate_id: @candidate.id
      }
    }).all.to_a.group_by{|feedback| feedback.stakeholder_assessment_id }
  end
  
  def stakeholder
    @stakeholder = Vger::Resources::Stakeholder.find(params[:stakeholder_id])
    @stakeholder_assessment = Vger::Resources::Mrf::StakeholderAssessment.where(
      company_id: @company.id,
      assessment_id: @assessment.id,
      query_options: {
        "stakeholder_id" => params[:stakeholder_id],
        "assessment_id" => @assessment.id
      }
    ).all.first
    @feedbacks = Vger::Resources::Mrf::Feedback.where({
      company_id: @company.id,
      assessment_id: @assessment.id,
      query_options: {
        stakeholder_assessment_id: @stakeholder_assessment.id
      },
      :include => :candidate
    }).all.to_a
  end

  def candidates
    order_by = params[:order_by] || "candidates.id"
    order_type = params[:order_type] || "ASC"
    order = "#{order_by} #{order_type}"
    @candidates = Vger::Resources::Candidate.where(
      joins: { :feedbacks => :stakeholder_assessment },
      query_options: {
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id
      },
      select: "distinct(candidates.id),candidates.name,email",
      order: order,
      page: params[:page],
      per: 10
    ).all
    @feedbacks = Vger::Resources::Mrf::Feedback.where(
      company_id: @company.id,
      assessment_id: @assessment.id,
      joins: :stakeholder_assessment,
      query_options: {
        candidate_id: @candidates.map(&:id),
        "mrf_stakeholder_assessments.assessment_id" => @assessment.id
      }
    ).all.to_a
    @reports = Vger::Resources::Mrf::Report.where(
      query_options: {
        assessment_id: @assessment.id,
        candidate_id: @candidates.map(&:id)
      },
      select: ["id","candidate_id","status"]
    ).all.to_a.group_by{|report| report.candidate_id }
    @feedbacks = @feedbacks.group_by{|feedback| feedback.candidate_id }
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
    get_templates(false)
    if request.put?
      feedbacks = params[:feedbacks].select{|index,feedback_hash| feedback_hash[:email].present? and feedback_hash[:name].present? }
      if feedbacks.empty?
        flash[:error] = "Please add atleast 1 stakeholder"
        return
      end

      stakeholder_emails = feedbacks.collect{|index, feedback_hash| feedback_hash[:email]}
      if stakeholder_emails.size != stakeholder_emails.uniq.size
        flash[:error] = "Multiple Stakeholders cannot share an email address. Please enter a unique email address for each Stakeholder!"
        return
      end

      candidate = get_or_create_candidate
      return if !candidate

      feedbacks.each do |index, feedback_hash|
        feedback = nil
        stakeholder = get_or_create_stakeholder(feedback_hash)
        return if !stakeholder
        stakeholder_assessment = get_or_create_stakeholder_assessment(stakeholder)
        return if !stakeholder_assessment
        feedback = get_or_create_feedback(stakeholder_assessment,candidate,feedback_hash)
        return if !feedback
      end
      flash[:notice] = "Invitations sent to stakeholders"
      if params[:send_invitations]
        Vger::Resources::Mrf::Assessment.send_invitations(company_id: @company.id, id: @assessment.id)
      end
      if params[:send_and_add_more].present?
        params[:candidate] = {}
        params[:feedbacks] = {}
        10.times do |index|
          params[:feedbacks][index.to_s] = {}
        end
      else
        redirect_to candidates_company_mrf_assessment_path(@company.id, @assessment.id) and return
      end
    end
    get_custom_assessment
  end

  def bulk_upload
    s3_key = "mrf/feedbacks/#{@assessment.id}_#{Time.now.strftime("%d_%m_%Y_%H_%M_%S_%P")}"
    if request.put?
      if !params[:bulk_upload] || !params[:bulk_upload][:file]
        flash[:error] = "Please select a csv file."
        redirect_to bulk_upload_company_mrf_assessment_path and return
      else
        data = params[:bulk_upload][:file].read
        obj = S3Utils.upload(s3_key, data)
        @s3_bucket = obj.bucket.name
        @s3_key = obj.key
        Vger::Resources::Mrf::Feedback\
          .import_from_s3_files(:email => current_user.email,
                        :company_id => @company.id,
                        :assessment_id => @assessment.id,
                        :sender_type => current_user.type,
                        :sender_name => current_user.name,
                        :send_invitations => params[:send_invitations],
                        :template_id => params[:template_id],
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
    else
      get_custom_assessment
      get_templates(false)
    end
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

  def get_or_create_candidate
    candidate = nil
    if params[:candidate][:email].present?
      candidate = Vger::Resources::Candidate.where(query_options: { email: params[:candidate][:email] }).all.to_a.first
    end
    if !candidate
      candidate = Vger::Resources::Candidate.find_or_create(params[:candidate])
      if !candidate.error_messages.empty?
        flash[:error] = candidate.error_messages.join("<br/>").html_safe
        return nil
      end
    end
    return candidate
  end

  def get_or_create_stakeholder(feedback_hash)
    stakeholder = Vger::Resources::Stakeholder.where(query_options: { email: feedback_hash[:email] }).all.to_a.first
    if !stakeholder
      stakeholder = Vger::Resources::Stakeholder.create(email: feedback_hash[:email], name: feedback_hash[:name])
      if !stakeholder.error_messages.empty?
        flash[:error] = stakeholder.error_messages.join("<br/>").html_safe
        return nil
      end
    end
    return stakeholder
  end

  def get_or_create_stakeholder_assessment(stakeholder)
    stakeholder_assessment = Vger::Resources::Mrf::StakeholderAssessment.where(
      company_id: @company.id,
      assessment_id: @assessment.id,
      query_options: {
        assessment_id: @assessment.id,
        stakeholder_id: stakeholder.id
      }
    ).all.to_a.first
    if !stakeholder_assessment
      stakeholder_assessment = Vger::Resources::Mrf::StakeholderAssessment.create(
        company_id: @company.id,
        assessment_id: @assessment.id,
        stakeholder_id: stakeholder.id,
        invitation_template_id: params[:template_id]
      )
      if !stakeholder_assessment.error_messages.empty?
        flash[:error] = stakeholder_assessment.error_messages.join("<br/>").html_safe
        return nil
      end
    end
    return stakeholder_assessment
  end

  def get_or_create_feedback(stakeholder_assessment,candidate,feedback_hash)
    feedback = Vger::Resources::Mrf::Feedback.where(
      company_id: @company.id,
      assessment_id: @assessment.id,
      stakeholder_assessment_id: stakeholder_assessment.id,
      query_options: {
        stakeholder_assessment_id: stakeholder_assessment.id,
        role: feedback_hash[:role],
        candidate_id: candidate.id
      }
    ).all.to_a.first
    if !feedback
      feedback = Vger::Resources::Mrf::Feedback.create(
        stakeholder_assessment_id: stakeholder_assessment.id,
        company_id: @company.id,
        assessment_id: @assessment.id,
        stakeholder_id: stakeholder_assessment.stakeholder_id,
        role: feedback_hash[:role],
        candidate_id: candidate.id,
        status: Vger::Resources::Mrf::Feedback::Status::PENDING
      )
      if !feedback.error_messages.empty?
        flash[:error] = feedback.error_messages.join("<br/>").html_safe
        return nil
      end
    end
    return feedback
  end

  def get_candidate
    @candidate = Vger::Resources::Candidate.find(params[:candidate_id])
  end
  
  def get_templates(reminder)
    category = ""
    query_options = {
    }
    if reminder
      category = Vger::Resources::Template::TemplateCategory::SEND_MRF_REMINDER_TO_STAKEHOLDER
    else
      category = Vger::Resources::Template::TemplateCategory::SEND_MRF_INVITATION_TO_STAKEHOLDER
    end
    query_options[:category] = category if category.present?
    @templates = Vger::Resources::Template\
                  .where(query_options: query_options, scopes: { global_or_for_company_id: @company.id }).all.to_a
    @templates |= Vger::Resources::Template\
                  .where(query_options: query_options, scopes: { global: nil }).all.to_a
  end
end
