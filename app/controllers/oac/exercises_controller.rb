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
                                      :show,  
                                      :select_competencies,
                                      :set_weightage
                                    ]
  before_filter :get_super_competency_score_buckets, :only => [
                                      :set_weightage
                                    ]
  before_filter :get_combined_super_competency_score_buckets, :only => [
                                      :select_super_competencies,
                                      :show
                                    ]
  before_filter :get_combined_competency_score_buckets, :only => [
                                      :select_competencies
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
                                        :set_weightage,
                                        :show
                                      ]
  before_filter :get_default_factor_norm_ranges, :only => [:select_competencies]
  
  layout 'oac/oac'

  def home  
  end
  
  def new
    @exercise = Vger::Resources::Oac::Exercise.new(params[:exercise])
  end

  def edit
  end
  
  def show
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
  
  def update
    params[:exercise][:report_configuration] = JSON.parse(params[:exercise][:report_configuration])
    @exercise = Vger::Resources::Oac::Exercise.save_existing(@exercise.id, params[:exercise])
    if !@exercise.error_messages.present?
      flash[:notice] = "Online assessment center is updated successfully."
      redirect_to candidates_company_oac_exercise_path(@company.id, @exercise.id)
    else
      flash[:error] = @exercise.error_messages.to_a.join("<br/>").html_safe
      render :action => :edit
    end
  end

  def select_tools
    if request.put?
      params[:exercise][:exercise_tools_attributes] ||= {}
      params[:exercise][:exercise_tools_attributes] = 
      Hash[params[:exercise][:exercise_tools_attributes].select do |tool_index, tool_data|
        tool_data[:tool_id].present?
      end]
      if params[:exercise][:exercise_tools_attributes].size < 2
        flash[:error] = "Please select a minimum of 2 tools"
        render :action => :select_tools and return
      end
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
      jombay_tools_attributes = Hash[params[:exercise][:exercise_tools_attributes]\
                                                  .select do |index, tool_data|
        tool_data.keys.include?("industry_id")
      end]
      if jombay_tools_attributes.values\
        .any?{|tool_data| 
        tool_data["industry_id"].blank? 
      } 
        flash[:error] = "Please select an industry"
        render :action => :customize_assessment and return
      end
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
      @exercise.super_competency_configuration = params[:exercise][:super_competency_configuration]
      if params[:exercise][:super_competency_configuration].size < 2
        flash[:error] = "Please select a minimum of 2 competencies"
        render :action => :select_super_competencies and return
      end
      selected_orders = params[:exercise][:super_competency_configuration].values.map{|config| config[:order] }
      if selected_orders.size != selected_orders.uniq.size
        flash[:error] = "Please select a unique order for each competency"
        render :action => :select_super_competencies and return
      end
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
    @non_selected_competencies = []
    if request.put?
      params[:exercise][:exercise_tools_attributes].each do |id, exercise_tools_attributes|
        params[:exercise][:exercise_tools_attributes][id][:competency_configuration] = 
        Hash[exercise_tools_attributes[:competency_configuration].select do |competency_id, competency_configuration|
          competency_configuration[:enabled]
        end]
      end
      @exercise_tools.each do |exercise_tool|
        exercise_tool.competency_configuration = 
        params[:exercise][:exercise_tools_attributes][exercise_tool.id.to_s][:competency_configuration]
      end
      @non_selected_competencies = @competencies.select do |competency|
        params[:exercise][:exercise_tools_attributes].none? do |id, exercise_tools_attributes|
          exercise_tools_attributes[:competency_configuration].keys.map(&:to_i).include?(competency.id.to_i)
        end
      end
      if @non_selected_competencies.present?
        flash[:error] = "#{@non_selected_competencies.map(&:name).join(', ')} is not measured by any of the tools."
        render :action => :select_competencies and return
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
        redirect_to add_users_bulk_company_oac_exercise_path(@company.id, @exercise.id)
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
      methods: [
        :industry_id,
        :functional_area_id,
        :job_experience,
        :page_size
      ],
      include: [:tool]
    ).all
  end
  
  def get_exercises
    order_by = params[:order_by] || "oac_exercises.created_at"
    order_type = params[:order_type] || "DESC"
    order = "#{order_by} #{order_type}"

    @exercises = Vger::Resources::Oac::Exercise.where(
      query_options: {
        company_id: params[:company_id]
      },
      order: order,
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
  
  def get_combined_competency_score_buckets
    @super_competency_score_buckets = Vger::Resources::Oac::CombinedCompetencyScoreBucket\
                                                                    .where(query_options: {
                                                                      company_id: params[:company_id]
                                                                    })\
                                                                    .where(order: "min_val ASC").all
    if @super_competency_score_buckets.empty?                                                                    
      @super_competency_score_buckets = Vger::Resources::Oac::CombinedCompetencyScoreBucket\
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
    @defined_forms = Vger::Resources::FormBuilder::DefinedForm.where(
      scopes: { for_company_id: @company.id }, 
      query_options: { active: true },
      methods: [:parent_uid]
    ).all.to_a
  end
  
  def validate_status
    #if @exercise.workflow_status == Vger::Resources::Oac::Exercise::WorkflowStatus::READY
    #  flash[:error] = "You can't update the configuration of this exercise."
    #  redirect_to add_users_bulk_company_oac_exercise_path(@company.id, @exercise.id)
    #end  
  end
  
  def get_default_factor_norm_ranges
    exercise_tool = @exercise_tools.select{|x| x.industry_id.present? }.first
    factor_ids = @competencies.map(&:factor_ids).flatten.map(&:to_i)
    if exercise_tool
      @default_factor_norm_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.where({
        query_options: {
          industry_id: exercise_tool.industry_id,
          functional_area_id: exercise_tool.functional_area_id,
          job_experience_id: exercise_tool.job_experience_id,
          factor_id: factor_ids
        }
      }).all.to_a
      if @default_factor_norm_ranges.size == 0
        @default_factor_norm_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.where({
          query_options: {
            industry_id: nil,
            functional_area_id: nil,
            job_experience_id: nil,
            factor_id: factor_ids
          }
        }).all.to_a
      end
    end
    @default_factor_norm_ranges = Hash[@default_factor_norm_ranges.map do |dfnr|
      [dfnr.factor_id,dfnr]
    end]
  end
end
