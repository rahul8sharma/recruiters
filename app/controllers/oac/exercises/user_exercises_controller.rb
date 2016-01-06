class Oac::Exercises::UserExercisesController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_exercise
  before_filter :validate_exercise
  layout 'oac/oac'

  def candidates
    @user_exercises = Vger::Resources::Oac::UserExercise.where(
      :exercise_id => @exercise.id,
      query_options: {
        :exercise_id => @exercise.id
      },
      include: [:user]
    ).all
  end

  def candidate
    @user = Vger::Resources::User.find(params[:candidate_id], :include => [ :functional_area, :industry, :location ])
  end

  def add_candidates
    params[:users] ||= {}
    params[:users].reject!{|key,data| data[:email].blank? && data[:name].blank?}
    @errors = {}
    if request.put?
      if params[:candidate_stage].empty?
        flash[:error] = "Please select the purpose of assessing these Assessment Takers before proceeding!"
        render :action => :add_candidates and return
      else
        users = {}
        if params[:users].empty?
          flash[:error] = "Please add at least 1 Assessment Taker to send the exercise. You may also select 'Add Assessment Takers Later' to save the exercise and return to the Assessment Listings."
          render :action => :add_candidates and return
        end

        params[:users].each do |key,user_data|
          @errors[key] ||= []
          if user_data[:email].present?
            user = Vger::Resources::User.where(:query_options => { :email => user_data[:email] }).all[0]
          end
          user_data[:role] = Vger::Resources::Role::RoleName::CANDIDATE
          if user
            user_data[:id] = user.id
            users[user.id] = user_data
            attributes_to_update = user_data.dup
            attributes_to_update.delete(:applicant_id)
            attributes_to_update.each { |attribute,value| attributes_to_update.delete(attribute) unless user.send(attribute).blank? }
            Vger::Resources::User.save_existing(user.id, attributes_to_update)
          else
            attributes = user_data.dup
            attributes.delete(:applicant_id)
            user = Vger::Resources::User.find_or_create(attributes)
            if user.error_messages.present?
              @errors[key] |= user.error_messages
            else
              user_data[:id] = user.id
              users[user.id] = user_data
            end
          end
        end

        unless @errors.values.flatten.empty?
          #flash[:error] = "Errors in provided data: <br/>".html_safe
          flash[:error] = @errors.map.with_index do |(user_name, user_errors), index|
            if user_errors.present?
              ["#{user_errors.join("<br/>")}"]
            end
          end.compact.uniq.join("<br/>").html_safe
          render :action => :add_candidates and return
        end
        get_templates(params[:candidate_stage])
        params[:send_test_to_users] = true
        params[:users] = users
        render :action => :send_assessment
      end
    end
  end

  def bulk_upload_candidates
  end

  def assign_assessors
  end
  
  def send_assessment
    params[:send_test_to_users] = true
    if request.put?
      params[:users] ||= {}
      params[:selected_users] ||= {}
      flash[:error] ||= ""
      user_exercises = []
      failed_user_exercises = []
      if params[:selected_users].empty?
        flash[:error] = "Please select at least one user."
        get_templates(params[:candidate_stage])
        render :action => :send_assessment and return
      end
      params[:selected_users].each do |user_id,on|
        user_exercise = @exercise.user_exercises.where(
          :exercise_id => @exercise.id,
          :query_options => {
            :exercise_id => @exercise.id,
            :user_id => user_id
          }
        ).all[0]

        exercise_taker_type = Vger::Resources::Suitability::UserAssessment::AssessmentTakerType::REGULAR
        @user = Vger::Resources::User.find(user_id)
        recipients = []
        options = {
          :candidate_stage => params[:candidate_stage],
          :exercise_taker_type => exercise_taker_type
        }

        options.merge!(template_id: params[:template_id].to_i) if params[:template_id].present?
        # create user_exercise if not present
        # add it to list of user_exercises to send email
        unless user_exercise
          user_exercise = Vger::Resources::Oac::UserExercise.create(
            :exercise_id => @exercise.id,
            :user_id => user_id,
            :options => options
          )
          if user_exercise.error_messages.present?
            failed_user_exercises << user_exercise
          else
            user_exercises.push user_exercise
          end
        end
      end
      exercise = Vger::Resources::Oac::Exercise.send_test_to_users(
        :id => @exercise.id,
        :user_exercise_ids => user_exercises.map(&:id),
        :options => {
          :send_email => true,
          :template_id => params[:template_id]
        }
      ) if user_exercises.present?
      if failed_user_exercises.present?
        flash[:error] = "#{failed_user_exercises.first.error_messages.join('<br/>')}"
        get_templates(params[:candidate_stage])
        render :action => :send_assessment and return
      else
        flash[:notice] = "Test was sent successfully!"
        redirect_to candidates_company_oac_exercise_path(@company.id, @exercise.id)
      end
    end
  end
  
  def send_reminder
    if request.get?
      @user = Vger::Resources::User.find(params[:user_id])
      @user_assessment = Vger::Resources::Oac::UserExercise.where(
        :exercise_id => params[:id], 
        :query_options => { 
          :exercise_id => params[:id], 
          :user_id => params[:user_id] 
        }
      ).all[0]
      get_templates(Vger::Resources::User::Stage::EMPLOYED, true)
    elsif request.put?
      @user_exercises = Vger::Resources::Oac::UserExercise.where(
        :exercise_id => params[:id], 
        :query_options => { 
        :exercise_id => params[:id], 
          :user_id => params[:user_id] 
        }
      ).all.to_a
      Vger::Resources::Oac::Exercise.send_reminder_to_users(
        params.merge(
          :exercise_id => params[:id], 
          :user_exercise_ids => @user_exercises.map(&:id), 
          :template_id => params[:template_id]
        )
      )
      flash[:notice] = "Reminder was sent successfully!"
      redirect_to candidates_company_oac_exercise_path(@company.id, @exercise.id)
    end
  end
  
  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end
  
  def get_exercise
    @exercise = Vger::Resources::Oac::Exercise.find(params[:id])
  end
  
  def get_templates(candidate_stage, reminder = false)
    category = ""
    query_options = {
    }
    if reminder
      category = Vger::Resources::Template::TemplateCategory::SEND_OAC_REMINDER_TO_EMPLOYEE
    else
      category = Vger::Resources::Template::TemplateCategory::SEND_OAC_TO_EMPLOYEE
    end
    query_options[:category] = category if category.present?
    @templates = Vger::Resources::Template\
                  .where(query_options: query_options, scopes: { global_or_for_company_id: @company.id }).all.to_a
    @templates |= Vger::Resources::Template\
                  .where(query_options: query_options, scopes: { global: nil }).all.to_a
  end
  
  def validate_exercise
    if @exercise.workflow_status != Vger::Resources::Oac::Exercise::WorkflowStatus::READY
      redirect_to home_company_oac_exercises_path(@company.id)
    end
  end
end
