require 'csv'
require 'fileutils'
class Mrf::Assessments::CandidateAssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_assessment

  layout 'mrf/mrf'
  
  def add_candidates
    params[:candidates] ||= {}
    10.times do |index|
      params[:candidates][index] ||= {}
    end
    get_templates_for_candidates
    if request.put?
      candidates = params[:candidates].select do |index,candidate_hash| 
        candidate_hash[:email].present? and candidate_hash[:name].present?
      end
      if candidates.empty?
        flash[:error] = "Please add atleast 1 candidate"
        return
      end

      candidate_emails = candidates.collect{|index, candidate_hash| candidate_hash[:email]}
      if candidate_emails.size != candidate_emails.uniq.size
        flash[:error] = "Please enter a unique email address for each Candidate!"
        return
      end
      candidate_assessment_ids = []
      candidates.each do |index, candidate_hash|
        candidate = get_or_create_candidate(candidate_hash)
        return if !candidate
        feedback = nil
        candidate_assessment = get_or_create_candidate_assessment(candidate)
        return if !candidate_assessment
        candidate_assessment_ids << candidate_assessment.id
      end
      flash[:notice] = "Invitations sent to candidates"
      Vger::Resources::Mrf::Assessment.send_invitations_to_candidates(
        company_id: @company.id, 
        id: @assessment.id,
        candidate_assessment_ids: candidate_assessment_ids
      )
      redirect_to company_mrf_assessment_candidate_assessments_path(@company.id, @assessment.id) and return
    end
  end
  
  def index
    @candidate_assessments = Vger::Resources::Mrf::CandidateAssessment.where(
      assessment_id: @assessment.id,
      query_options: {
        assessment_id: @assessment.id
      },
      order: "updated_at DESC",
      include: [:candidate],
      page: params[:page],
      per: 10
    )
  end
  
  def edit
    @candidate_assessment = Vger::Resources::Mrf::CandidateAssessment.find(
      params[:id],
      assessment_id: @assessment.id,
      include: [:candidate]
    )
  end
  
  def update
    @candidate_assessment = Vger::Resources::Mrf::CandidateAssessment.save_existing(
      params[:id],
      assessment_id: @assessment.id,
      stakeholder_types: params[:stakeholder_types],
    )
    if @candidate_assessment.error_messages.present?
      render :action => :edit
    else
      redirect_to company_mrf_assessment_candidate_assessments_path(@company.id, @assessment.id, @candidate_assessment.id)
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

  def get_or_create_candidate(candidate_hash)
    candidate = nil
    if candidate_hash[:email].present?
      candidate = Vger::Resources::Candidate.where(query_options: { email: candidate_hash[:email] }).all.to_a.first
    end
    if !candidate
      candidate = Vger::Resources::Candidate.find_or_create(candidate_hash)
      if !candidate.error_messages.empty?
        flash[:error] = candidate.error_messages.join("<br/>").html_safe
        return nil
      end
    end
    return candidate
  end

  def get_or_create_candidate_assessment(candidate)
    candidate_assessment = Vger::Resources::Mrf::CandidateAssessment.where(
      company_id: @company.id,
      assessment_id: @assessment.id,
      query_options: {
        assessment_id: @assessment.id,
        candidate_id: candidate.id
      }
    ).all.to_a.first
    if !candidate_assessment
      candidate_assessment = Vger::Resources::Mrf::CandidateAssessment.create(
        assessment_id: @assessment.id,
        candidate_id: candidate.id,
        candidate_invitation_template_id: params[:candidate_invitation_template_id],
        stakeholder_invitation_template_id: params[:stakeholder_invitation_template_id],
        stakeholder_types: params[:stakeholder_types]
      )
      if !candidate_assessment.error_messages.empty?
        flash[:error] = candidate_assessment.error_messages.join("<br/>").html_safe
        return nil
      end
    end
    return candidate_assessment
  end

  def get_templates_for_candidates
    query_options = {
      category: Vger::Resources::Template::TemplateCategory::SEND_MRF_INVITATION_TO_CANDIDATE
    }
    @candidate_templates = Vger::Resources::Template\
                  .where(
                    query_options: query_options, 
                    scopes: { global_or_for_company_id: @company.id },
                  ).all.to_a
    @candidate_templates |= Vger::Resources::Template\
                  .where(
                    query_options: query_options, 
                    scopes: { global: nil }
                  ).all.to_a
    query_options = {
      category: Vger::Resources::Template::TemplateCategory::SEND_MRF_INVITATION_TO_STAKEHOLDER_FROM_CANDIDATE
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
