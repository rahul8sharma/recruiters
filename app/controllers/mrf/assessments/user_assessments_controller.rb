require 'csv'
require 'fileutils'
class Mrf::Assessments::UserAssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_assessment

  layout 'mrf/mrf'
  
  def bulk_upload
    s3_key = "mrf/users/#{@assessment.id}_#{Time.now.strftime("%d_%m_%Y_%H_%M_%S_%P")}"
    if request.put?
      if !params[:bulk_upload] || !params[:bulk_upload][:file]
        flash[:error] = "Please select a csv file."
        redirect_to bulk_upload_company_mrf_assessment_user_assessments_path(
          @company.id,
          @assessment.id
        ) and return
      else
        data = params[:bulk_upload][:file].read
        obj = S3Utils.upload(s3_key, data)
        @s3_bucket = obj.bucket.name
        @s3_key = obj.key
        Vger::Resources::Mrf::UserAssessment\
          .import_from_s3_files(
                        :email => current_user.email,
                        :company_id => @company.id,
                        :assessment_id => @assessment.id,
                        :sender_id => current_user.id,
                        :send_invitations => params[:send_invitations],
                        :user_invitation_template_id => 
                                          params[:user_invitation_template_id],
                        :stakeholder_invitation_template_id => 
                                        params[:stakeholder_invitation_template_id],
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
      get_templates_for_users
    end
  end
  
  def add_users
    params[:users] ||= {}
    10.times do |index|
      params[:users][index] ||= {}
    end
    get_templates_for_users
    if request.put?
      users = params[:users].select do |index,user_hash| 
        user_hash[:email].present? and user_hash[:name].present?
      end
      if users.empty?
        flash[:error] = "Please add atleast 1 user"
        return
      end

      user_emails = users.collect{|index, user_hash| user_hash[:email]}
      if user_emails.size != user_emails.uniq.size
        flash[:error] = "Please enter a unique email address for each User!"
        return
      end
      user_assessment_ids = []
      users.each do |index, user_hash|
        user = get_or_create_user(user_hash)
        return if !user
        feedback = nil
        user_assessment = get_or_create_user_assessment(user)
        return if !user_assessment
        user_assessment_ids << user_assessment.id
      end
      flash[:notice] = "Invitations sent to users"
      Vger::Resources::Mrf::Assessment.send_invitations_to_users(
        company_id: @company.id, 
        id: @assessment.id,
        user_assessment_ids: user_assessment_ids
      )
      redirect_to company_mrf_assessment_user_assessments_path(@company.id, @assessment.id) and return
    end
  end
  
  def index
    @user_assessments = Vger::Resources::Mrf::UserAssessment.where(
      assessment_id: @assessment.id,
      query_options: {
        assessment_id: @assessment.id
      },
      order: "updated_at DESC",
      include: [:user],
      page: params[:page],
      per: 10
    )
  end
  
  def edit
    @user_assessment = Vger::Resources::Mrf::UserAssessment.find(
      params[:id],
      assessment_id: @assessment.id,
      include: [:user]
    )
  end
  
  def update
    @user_assessment = Vger::Resources::Mrf::UserAssessment.save_existing(
      params[:id],
      assessment_id: @assessment.id,
      stakeholder_types: params[:stakeholder_types],
    )
    if @user_assessment.error_messages.present?
      render :action => :edit
    else
      redirect_to company_mrf_assessment_user_assessments_path(@company.id, @assessment.id)
    end
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

  def get_assessment
    if params[:mrf_assessment_id].present?
      @assessment = Vger::Resources::Mrf::Assessment.find(params[:mrf_assessment_id], company_id: @company.id, :include => {:assessment_traits => { methods: [:trait] } })
    else
      @assessment = Vger::Resources::Mrf::Assessment.new
    end
  end

  def get_or_create_user(user_hash)
    user_hash[:role] = Vger::Resources::Role::RoleName::CANDIDATE
    user = Vger::Resources::User.find_or_create(user_hash)
    if !user.error_messages.empty?
      flash[:error] = user.error_messages.join("<br/>").html_safe
      return nil
    end
    return user
  end

  def get_or_create_user_assessment(user)
    user_assessment = Vger::Resources::Mrf::UserAssessment.where(
      company_id: @company.id,
      assessment_id: @assessment.id,
      query_options: {
        assessment_id: @assessment.id,
        user_id: user.id
      }
    ).all.to_a.first
    if !user_assessment
      user_assessment = Vger::Resources::Mrf::UserAssessment.create(
        assessment_id: @assessment.id,
        user_id: user.id,
        user_invitation_template_id: params[:user_invitation_template_id],
        stakeholder_invitation_template_id: params[:stakeholder_invitation_template_id],
        stakeholder_types: params[:stakeholder_types]
      )
      if !user_assessment.error_messages.empty?
        flash[:error] = user_assessment.error_messages.join("<br/>").html_safe
        return nil
      end
    end
    return user_assessment
  end

  def get_templates_for_users
    query_options = {
      category: eval("Vger::Resources::Template::TemplateCategory::SEND_MRF_INVITATION_TO_CANDIDATE")
    }
    @user_templates = Vger::Resources::Template\
                  .where(
                    query_options: query_options, 
                    scopes: { global_or_for_company_id: @company.id },
                  ).all.to_a
    @user_templates |= Vger::Resources::Template\
                  .where(
                    query_options: query_options, 
                    scopes: { global: nil }
                  ).all.to_a
    query_options = {
      category: eval("Vger::Resources::Template::TemplateCategory::SEND_#{@assessment.assessment_type.upcase}_MRF_INVITATION_TO_STAKEHOLDER_FROM_CANDIDATE")
    }              
    @stakeholder_templates = Vger::Resources::Template\
                  .where(
                    query_options: query_options, 
                    scopes: { global_or_for_company_id: @company.id }
                  ).all.to_a
    @stakeholder_templates |= Vger::Resources::Template\
                  .where(
                    query_options: query_options, 
                    scopes: { global: nil }
                  ).all.to_a              
  end
end
