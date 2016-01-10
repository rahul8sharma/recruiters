class Oac::ExercisesController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_exercises, only: [:home]
  before_filter :get_exercise, except: [:home, :new, :create]
  before_filter :get_tools, :only => [
                                        :select_tools, 
                                        :customize_assessment
                                      ]
  before_filter :get_master_data, :only => [:customize_assessment]
  before_filter :get_super_competencies, :only => [
                                        :select_super_competencies
                                      ]
  before_filter :validate_status, :only => [
                                    :select_tools,
                                    :customize_assessment,
                                    :select_competencies,
                                    :set_weightage
                                  ]
  before_filter :get_norm_buckets, :only => [
                                      :select_competencies,
                                      :set_weightage
                                    ]
  before_filter :get_super_competency_score_buckets, :only => [
                                      :set_weightage
                                    ]
  before_filter :get_combined_super_competency_score_buckets, :only => [
                                      :select_super_competencies
                                    ]
  before_filter :get_selected_super_competencies, :only => [
                                      :select_competencies,
                                      :set_weightage
                                    ]
  before_filter :get_competencies, :only => [
                                      :select_competencies,
                                      :set_weightage
                                    ]
  before_filter :get_exercise_tools, :only => [
                                        :select_tools, 
                                        :customize_assessment,
                                        :select_competencies,
                                        :select_super_competencies,
                                        :set_weightage
                                      ]
  layout 'oac/oac'

  def home  
  end
  
  def new
    @exercise = Vger::Resources::Oac::Exercise.new(params[:exercise])
  end

  def edit
  end

  def create
    params[:exercise][:report_configuration] = JSON.parse(params[:exercise][:report_configuration])
    @exercise = Vger::Resources::Oac::Exercise.new(params[:exercise])
    @exercise.company_id = params[:company_id]
    if @exercise.save
      flash[:notice] = "Online assessment center is created successfully."
      redirect_to select_tools_company_oac_exercise_path(@company.id, @exercise.id)
    else
      flash[:error] = @exercise.error_messages.to_a.join("<br/>").html_safe
      render :action => :new
    end
  end

  def select_tools
    params[:exercise][:report_configuration] = JSON.parse(params[:exercise][:report_configuration])
    if request.put?
      @exercise = Vger::Resources::Oac::Exercise.save_existing(params[:id], params[:exercise])
      if @exercise.error_messages.blank?
        redirect_to customize_assessment_company_oac_exercise_path(@company.id, @exercise.id)
      else
        flash[:error] = @exercise.error_messages.to_a.join("<br/>").html_safe
        render :action => :select_tools
      end
    else
    end
  end

  def customize_assessment
    if request.put?
      @exercise = Vger::Resources::Oac::Exercise.save_existing(params[:id], params[:exercise])
      if @exercise.error_messages.blank?
        redirect_to select_super_competencies_company_oac_exercise_path(@company.id, @exercise.id)
      else
        flash[:error] = @exercise.error_messages.to_a.join("<br/>").html_safe
        render :action => :customize_assessment
      end
    end
  end
  
  def select_super_competencies
    if request.put?
      params[:exercise][:super_competency_configuration] = 
      Hash[params[:exercise][:super_competency_configuration].select do |competency_id, competency_configuration|
        competency_configuration[:enabled]
      end]
      @exercise = Vger::Resources::Oac::Exercise.save_existing(params[:id], params[:exercise])
      if @exercise.error_messages.blank?
        redirect_to select_competencies_company_oac_exercise_path(@company.id, @exercise.id)
      else
        flash[:error] = @exercise.error_messages.to_a.join("<br/>").html_safe
        render :action => :select_competencies
      end
    else
    end
  end
  
  def select_competencies
    if request.put?
      params[:exercise][:exercise_tools_attributes].each do |id, exercise_tools_attributes|
        params[:exercise][:exercise_tools_attributes][id][:competency_configuration] = 
        Hash[exercise_tools_attributes[:competency_configuration].select do |competency_id, competency_configuration|
          competency_configuration[:enabled]
        end]
      end
      @exercise = Vger::Resources::Oac::Exercise.save_existing(params[:id], params[:exercise])
      if @exercise.error_messages.blank?
        redirect_to set_weightage_company_oac_exercise_path(@company.id, @exercise.id)
      else
        flash[:error] = @exercise.error_messages.to_a.join("<br/>").html_safe
        render :action => :select_competencies
      end
    else
    end
  end

  def set_weightage
    if request.put?
      params[:exercise][:workflow_status] = Vger::Resources::Oac::Exercise::WorkflowStatus::MARKED_FOR_CREATION
      @exercise = Vger::Resources::Oac::Exercise.save_existing(params[:id], params[:exercise])
      if @exercise.error_messages.blank?
        redirect_to add_candidates_company_oac_exercise_path(@company.id, @exercise.id)
      else
        flash[:error] = @exercise.error_messages.to_a.join("<br/>").html_safe
        render :action => :set_weightage
      end
    else
    end
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end
  
  def get_tools
    @tools = Vger::Resources::Oac::Tool.all
  end
  
  def get_exercise_tools
    @exercise_tools = Vger::Resources::Oac::ExerciseTool.where(
      exercise_id: params[:id], 
      query_options: {
        exercise_id: params[:id]
      },
      include: [:tool]
    ).all
  end
  
  def get_exercises
    @exercises = Vger::Resources::Oac::Exercise.where(
      query_options: {
        company_id: params[:company_id]
      },
      methods: [:sent_count, :completed_count],
      page: params[:page], 
      per: 10
    ).all
  end
  
  def get_exercise
    @exercise = Vger::Resources::Oac::Exercise.find(params[:id])
  end
  
  def get_competencies
    @competencies = Vger::Resources::Suitability::Competency.where(
      :query_options => { 
        "id" => @super_competencies.map(&:competency_ids).flatten
      }, 
      :scopes => {
      }, 
      :methods => [:factors], 
      :order => ["name ASC"], 
      :joins => "companies"
    ).all.to_a
  end
  
  def get_super_competencies
    @super_competencies = Vger::Resources::Suitability::SuperCompetency.where(
      :query_options => { 
        "suitability_super_competencies.company_id" => @company.id, 
        :active => true 
      }, 
      :methods => [:competency_ids],
      :scopes => {
      }, 
      :order => ["name ASC"],
    ).all.to_a
  end
  
  def get_norm_buckets
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(order: "weight ASC").all
  end
  
  def get_super_competency_score_buckets
    @super_competency_score_buckets = Vger::Resources::Suitability::SuperCompetencyScoreBucket\
                                                                    .where(query_options: {
                                                                      company_id: params[:company_id]
                                                                    })\
                                                                    .where(order: "min_val ASC").all
    if @super_competency_score_buckets.empty?                                                                    
      @super_competency_score_buckets = Vger::Resources::Suitability::SuperCompetencyScoreBucket\
                                                                    .where(query_options: {
                                                                      company_id: nil
                                                                    })\
                                                                    .where(order: "min_val ASC").all
    end
  end
  
  def get_combined_super_competency_score_buckets
    @super_competency_score_buckets = Vger::Resources::Oac::CombinedSuperCompetencyScoreBucket\
                                                                    .where(query_options: {
                                                                      company_id: params[:company_id]
                                                                    })\
                                                                    .where(order: "min_val ASC").all
    if @super_competency_score_buckets.empty?                                                                    
      @super_competency_score_buckets = Vger::Resources::Oac::CombinedSuperCompetencyScoreBucket\
                                                                    .where(query_options: {
                                                                      company_id: nil
                                                                    })\
                                                                    .where(order: "min_val ASC").all
    end
  end
  
  def get_selected_super_competencies
    @super_competencies = Vger::Resources::Suitability::SuperCompetency\
                          .where(
                            query_options: {
                              id: @exercise.super_competency_configuration.keys.map(&:to_i)
                            },
                            :methods => [:competency_ids]
                          ).all.to_a
  end
  
  
  def get_master_data
    @functional_areas = Hash[Vger::Resources::FunctionalArea.where(:query_options => {:active=>true},:order => "name ASC")\
                          .all.to_a.collect{|x| [x.id,x]}]
    @industries = Hash[Vger::Resources::Industry.where(:query_options => {:active=>true},:order => "name ASC")\
                        .all.to_a.collect{|x| [x.id,x]}]
    @job_experiences = Hash[Vger::Resources::JobExperience.active.all.to_a.collect{|x| [x.id,x]}]  
  end
  
  def validate_status
    #if @exercise.workflow_status == Vger::Resources::Oac::Exercise::WorkflowStatus::READY
    #  flash[:error] = "You can't update the configuration of this Online Assessment Center"
    #  redirect_to add_candidates_company_oac_exercise_path(@company.id, @exercise.id)
    #end  
  end
end
