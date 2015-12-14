class Oac::AssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_exercises, only: [:home]
  before_filter :get_exercise, except: [:home]
  before_filter :get_tools, :only => [:select_tools, :customize_assessment]
  before_filter :get_norm_buckets, :only => [
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
                                        :set_weightage
                                      ]
  layout 'oac/oac'

  def home  
  end

  def select_tools
    if request.post?
      @exercise = Vger::Resources::Oac::Exercise.new(params[:exercise])
      @exercise.company_id = params[:company_id]
      if @exercise.save
        flash[:notice] = "Online assessment center is created successfully."
        redirect_to customize_assessment_company_oac_exercise_path(@company.id, @exercise.id)
      else
        flash[:error] = @exercise.error_messages.to_a.join("<br/>").html_safe
        render :action => :select_tools
      end
    else
      @exercise = Vger::Resources::Oac::Exercise.new
    end
  end

  def customize_assessment
    if request.put?
      @exercise = Vger::Resources::Oac::Exercise.save_existing(params[:id], params[:exercise])
      if @exercise.error_messages.blank?
        flash[:notice] = "Online assessment center is created successfully."
        redirect_to select_competencies_company_oac_exercise_path(@company.id, @exercise.id)
      else
        flash[:error] = @exercise.error_messages.to_a.join("<br/>").html_safe
        render :action => :customize_assessment
      end
    end
  end
  
  def select_competencies
    if request.put?
      @exercise = Vger::Resources::Oac::Exercise.save_existing(params[:id], params[:exercise])
      if @exercise.error_messages.blank?
        flash[:notice] = "Online assessment center is created successfully."
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
      @exercise = Vger::Resources::Oac::Exercise.save_existing(params[:id], params[:exercise])
      if @exercise.error_messages.blank?
        flash[:notice] = "Online assessment center is created successfully."
        redirect_to send_assessment_company_oac_exercise_path(@company.id, @exercise.id)
      else
        flash[:error] = @exercise.error_messages.to_a.join("<br/>").html_safe
        render :action => :set_weightage
      end
    else
    end
  end

  def add_candidates
  end

  def send_assessment
  end

  def assign_assessor
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
    @exercises = Vger::Resources::Oac::Exercise.where(page: params[:page], per: 10).all
  end
  
  def get_exercise
    @exercise = Vger::Resources::Oac::Exercise.find(params[:id])
  end
  
  def get_competencies
=begin
    @competencies = Vger::Resources::Suitability::Competency.where(
      :query_options => {
        :active => true
      }, 
      :scopes => {
        :global => nil
      },
      :methods => [:factor_names], 
      :order => ["name ASC"]
    ).to_a
=end    
    @competencies = Vger::Resources::Suitability::Competency.where(
      :query_options => { 
        "companies_competencies.company_id" => @company.id, :active => true 
      }, 
      :scopes => {
      }, 
      :methods => [:factors], 
      :order => ["name ASC"], 
      :joins => "companies"
    ).all.to_a
  end
  
  def get_norm_buckets
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(order: "weight ASC").all
  end

end
