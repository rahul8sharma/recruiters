class Exit::SurveysController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_survey, :except => [:index,:home]
  before_filter :get_defined_forms, :only => [:new, :edit, :create]

  layout 'exit'

  def api_resource
    Vger::Resources::Exit::Survey
  end

  def home
    order_by = params[:order_by] || "exit_surveys.created_at"
    order_type = params[:order_type] || "DESC"
    order = "#{order_by} #{order_type}"
    @surveys = Vger::Resources::Exit::Survey.where(query_options: {company_id: params[:company_id]}, order: order, page: params[:page], per: 10).all
    @user_counts = Vger::Resources::User.group_count(group: "exit_user_surveys.survey_id", joins: :exit_user_surveys, query_options: {
      "exit_user_surveys.survey_id" => @surveys.map(&:id)
    })
    @completed_counts = Vger::Resources::User.group_count(group: "exit_user_surveys.survey_id", joins: :exit_user_surveys, query_options: {
      "exit_user_surveys.survey_id" => @surveys.map(&:id),
      "exit_user_surveys.status" => Vger::Resources::Exit::UserSurvey.completed_statuses
    })
  end

  def new
  end

  def create
    params[:survey][:company_id] = @company.id
    @survey = Vger::Resources::Exit::Survey.new(params[:survey])
    if @survey.save
      if params[:defined_form_id].present?  && params[:defined_form_id] =~ /^\d+$/
        factual_information_form = Vger::Resources::FormBuilder::FactualInformationForm.create({
          :defined_form_id => params[:defined_form_id],
          :company_id => @company.id,
          :assessment_type => "Exit::Survey",
          :assessment_id => @survey.id
        })
      end
      flash[:notice] = "Exit Survey created successfully!"
      redirect_to add_items_company_exit_survey_path(@company.id,@survey.id)
    else
      flash[:error] = @survey.error_messages.join("<br/>").html_safe
      render action: :new
    end
  end

  def add_items
    if request.get?
      get_items
    else
      params[:survey] ||= {}
      params[:items] ||= {}
      items = Hash[params[:items].select{|item_id, item_data| item_data[:selected].present? }]
      if items.empty?
        flash[:error] = "You need to select items before sending a survey. Please select items from below."
        get_items
        redirect_to add_items_company_exit_survey_path(@company.id,@survey.id) and return
      end
      items = Hash[items.sort_by{|item_id, item_data| item_data[:order].to_i }]
      params[:survey][:item_ids] = items.map do |index, item_data|
        { 
          :type => item_data[:type], 
          :id => item_data[:id].to_i, 
          :enable_comment => item_data[:enable_comment].present?,
          :comment_compulsory => item_data[:comment_compulsory].present?
        }
      end
      @survey = Vger::Resources::Exit::Survey.save_existing(@survey.id, params[:survey])
      if !@survey.error_messages.present?
        flash[:notice] = "Exit Survey created successfully!"
        redirect_to add_users_company_exit_survey_path(@company.id,@survey.id)
      else
        flash[:error] = @survey.error_messages.join("<br/>").html_safe
        render action: :new
      end
    end
  end

  def details
    @total_users = Vger::Resources::Exit::UserSurvey.count({
      survey_id: @survey.id
    })
  end

  def traits
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

  def get_survey
    if params[:id].present?
      @survey = Vger::Resources::Exit::Survey.find(params[:id], company_id: @company.id)
    else
      @survey = Vger::Resources::Exit::Survey.new
    end
  end

  def get_items
    @items = Vger::Resources::Exit::Item.where(
      scopes: {
        :for_company => @company.id
      },
      query_options: {
        :item_group_id => nil
      }
    ).all.to_a

    @item_groups = Vger::Resources::Exit::ItemGroup.where(scopes: {
      :for_company => @company.id
    }).all.to_a
    
    @subjective_items = Vger::Resources::SubjectiveItem.where(
      scopes: {
        :for_company => @company.id
      },
      query_options: {
        :active => true,
        :behaviour => "exit_survey"
      }
    ).all.to_a
  end

  def get_traits
    @traits = Vger::Resources::Exit::Trait.where({
      query_options: {
        :active => true
      }
    }).all.to_a.group_by(&:id)
    @survey_traits = @survey.survey_traits.all.to_a
    @survey_traits.each do |survey_trait|
      survey_trait.is_selected = true
      survey_trait.trait = @traits[survey_trait.trait_id][0]
    end
    added_trait_ids = @survey_traits.map(&:trait_id)
    @traits.each do |trait_id,traits|
      if !added_trait_ids.include?(trait_id)
        survey_trait = Vger::Resources::Exit::SurveyTrait.new({
          survey_id: @survey.id,
          trait_id: trait_id
        })
        survey_trait.is_selected = false
        survey_trait.trait = traits[0]
        @survey_traits.push(survey_trait)
      end
    end
  end

  def get_defined_forms
    @defined_forms = Vger::Resources::FormBuilder::DefinedForm.where(scopes: { global_or_for_company_id: @company.id }, query_options: { active: true }).all.to_a
    @defined_forms |= Vger::Resources::FormBuilder::DefinedForm.where(scopes: { global: nil }, query_options: { active: true }).all.to_a
  end
end
