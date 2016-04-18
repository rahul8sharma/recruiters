require 'sidekiq/web'

Recruiters::Application.routes.draw do
  get "/users/password/link_sent", :to => "users#link_sent", :as => :link_sent
  get "/users/confirmation", :to => "users#confirm", :as => :confirm

  get "/users/password/edit", :to => "users#reset_password", :as => :reset_password
  put "/users/password/edit", :to => "users#update_password", :as => :update_password

  get "/users/password/new", :to => "users#forgot_password", :as => :forgot_password
  post "/users/password/create", :to => "users#send_reset_password", :as => :send_reset_password

  get "/users/activate", :to => "users#activate", :as => :activate_account
  put "/users/activate", :to => "users#activate"

  get "/users/password_settings" => "users#password_settings", :as => :password_settings
  put "/users/update_password_settings" => "users#update_password_settings", :as => :update_password_settings

  resources :users do
    member do
      match 'generate_assessment_link' => "users_management#generate_assessment_link", :as => :generate_assessment_link
      match 'deactivate_assessment_link' => "users_management#deactivate_assessment_link", :as => :deactivate_assessment_link
      get 'assessment_link/:assessment_id' => "users_management#assessment_link", :as => :assessment_link
      match 'update_user_stage' => "users_management#update_user_stage", :as => :update_user_stage
    end
    collection do
      get "manage" => "users_management#manage", :as => :manage
      post "update_user_assessments" => "users_management#update_user_assessments", :as => :update_user_assessments
      post 'export' => "users_management#export"
      post 'import' => "users_management#import"
      post 'export_validation_progress' => "users_management#export_validation_progress"
      post 'export_user_responses' => "users_management#export_user_responses"
      post 'export_user_reports' => "users_management#export_user_reports"
      post 'export_user_report_urls' => "users_management#export_user_report_urls"
      post 'download_pdf_reports' => "users_management#download_pdf_reports"
      post 'resend_invitations_to_users' => "users_management#resend_invitations_to_users"
      post 'send_360_invitations_to_users' => "users_management#send_360_invitations_to_users"
      post 'import_user_scores' => "users_management#import_user_scores", as: :import_user_scores
      post 'import_assessments_factor_scores' => "users_management#import_assessments_factor_scores", as: :import_assessments_factor_scores
      post 'export_assessments_factor_scores' => "users_management#export_assessments_factor_scores", as: :export_assessments_factor_scores
      get :destroy_all
    end
  end
  resources :assessments, :controller => "assessments", :path => "assessments" do
    collection do
      get :search
    end
  end
  resources :companies do
    scope module: :companies do
      namespace :jq, path: "hiring" do
        resources :jobs do
          scope module: :jobs do
            resources :user_jobs, path: "users"
          end
        end
      end
    end

    collection do
      post :import
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
      post :export_companies
      post :export_monthly_report
      post :export_monthly_partner_usage
      post :mrf_export_monthly_report
      get :select
    end

    resources :standard_assessments, :controller => "companies/standard_assessments", :path => "standard-tests" do
      member do
        get "send_test" => "companies/standard_assessments#send_test", :as => :send_test
      end
    end

    member do
      get "plans" => "companies/plans#index", :as => :plans
      put "plans/:plan_id/upgrade_subscription" => "companies/plans#upgrade_subscription", :as => :upgrade_subscription
      get "plans/:plan_id/review" => "companies/plans#review", :as => :review_plan
      get "plans/:plan_id/contact" => "companies/plans#contact", :as => :contact_plan
      get "plans/:plan_id/payment_status" => "companies/plans#payment_status", :as => :payment_status

      get "users_search" => "companies#users_search", :as => :users_search
      get "reports" => "companies#reports", :as => :reports
      get "settings" => "company_settings#settings", :as => :settings
      get "statistics" => "company_statistics#statistics", :as => :statistics
      get "statistics_360" => "company_statistics#statistics_360", :as => :statistics_360
      get "email_usage_stats" => "company_statistics#email_usage_stats", :as => :email_usage_stats
      get "settings/company" => "company_settings#company", :as => :company_settings
      get "settings/account" => "company_settings#account", :as => :account_settings
      get "settings/user_settings" => "company_settings#user_settings", :as => :user_settings
      get "settings/data/competencies" => "company_settings#competencies", :as => :competencies
      get "settings/data/competencies/create" => "company_settings#create_competencies", :as => :create_competencies
      get "settings/data/competencies/:id/details/" => "company_settings#competency", :as => :competency
      match "settings/user_settings/add_users" => "company_settings#add_users", :as => :add_users
      put "settings/user_settings/remove_users" => "company_settings#remove_users", :as => :remove_users
      get "settings/user_settings/confirm_remove_users" => "company_settings#confirm_remove_users", :as => :confirm_remove_users

      get "settings/company_managers" => "company_settings#company_managers", :as => :company_managers
      get "comments" => "companies#comments"
      put "settings/user_settings/remove_company_managers" => "company_settings#remove_company_managers", :as => :remove_company_managers
      get "settings/user_settings/confirm_remove_company_managers" => "company_settings#confirm_remove_company_managers", :as => :confirm_remove_company_managers
      match "settings/user_settings/add_company_managers" => "company_settings#add_company_managers", :as => :add_company_managers

      get "users/:user_id" => "companies#user", :as => :user
      get "add_subscription" => "companies#add_subscription", :as => :add_subscription
      put "add_subscription" => "companies#add_subscription"
      
      get "add_mrf_subscription" => "companies#add_mrf_subscription", :as => :add_mrf_subscription
      put "add_mrf_subscription" => "companies#add_mrf_subscription"
      
      get "home" => "companies#home", :as => :home
      get :landing
      get :email_assessment_stats
      get :email_reports_summary
    end

    resources :hiring_managers do
      collection do
        post :import
        get 'assign_jobs' => "hiring_managers#assign_jobs_form", :as => :assign_jobs_form
        post :assign_jobs
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :admins do
      collection do
        get :manage
        get :destroy_all
        post :import
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :walkin_groups, path: "walk-ins", :controller => :walkin_groups do
      member do
        get "summary" => "walkin_groups#summary", as: :summary
        put "summary" => "walkin_groups#summary", as: :summary
        get "customize" => "walkin_groups#customize", as: :customize
        put "customize" => "walkin_groups#customize", as: :customize
        get "expire" => "walkin_groups#expire", as: :expire
      end
    end

    resources :training_requirement_groups, path: "training-requirements", :controller => :training_requirement_groups do
      member do
        get "training_requirements" => "training_requirement_groups#training_requirements", as: :training_requirements
        match "customize" => "training_requirement_groups#customize", as: :customize
        get "download_report" => "training_requirement_groups#download_report", as: :download_report
        get "training_requirements_report" => "training_requirement_groups#training_requirements_report", :as => :training_requirements_report
      end
    end

    resources :benchmarks, :benchmark_assessments, :controller => "suitability/benchmarks", :except => [:destroy] do
      member do
        get "norms" => "suitability/benchmarks#norms", :as => :norms
        put "norms" => "suitability/benchmarks#norms", :as => :norms

        get "set_weightage" => "suitability/custom_assessments#set_weightage", :as => :set_weightage
        put "set_weightage" => "suitability/custom_assessments#set_weightage", :as => :set_weightage

        get "competency_norms" => "suitability/benchmarks#competency_norms", :as => :competency_norms
        put "competency_norms" => "suitability/benchmarks#competency_norms", :as => :competency_norms
        get "competencies" => "suitability/benchmarks#competencies", :as => :competencies
        put "competencies" => "suitability/benchmarks#competencies", :as => :competencies

        get "styles" => "suitability/benchmarks#styles", :as => :styles
        put "styles" => "suitability/benchmarks#styles", :as => :styles

        get "download_benchmark_report" => "suitability/benchmarks#download_benchmark_report", :as => :download_benchmark_report
        get "benchmark_report" => "suitability/assessment_reports#benchmark_report", :as => :benchmark_report

        get "candidates" => "suitability/benchmarks/user_assessments#users", :as => :users
        get "candidates/add" => "suitability/benchmarks/user_assessments#add_users", :as => :add_users
        put "candidates/add" => "suitability/benchmarks/user_assessments#add_users", :as => :add_users

        put "candidates/bulk_upload" => "suitability/benchmarks/user_assessments#bulk_upload", :as => :bulk_upload
        get "email_reports" => "suitability/benchmarks/user_assessments#email_reports", :as => :email_reports

        get "candidates/send-test" => "suitability/benchmarks/user_assessments#send_test_to_users", :as => :send_test_to_users
        put "candidates/send-test" => "suitability/benchmarks/user_assessments#send_test_to_users", :as => :send_test_to_users
        put "candidates/bulk-send-test" => "suitability/benchmarks/user_assessments#bulk_send_test_to_users", :as => :bulk_send_test_to_users
        get "candidates/:user_id/send-reminder" => "suitability/benchmarks/user_assessments#send_reminder", :as => :send_reminder_to_user
        put "candidates/:user_id/send-reminder" => "suitability/benchmarks/user_assessments#send_reminder", :as => :send_reminder_to_user
        get "candidates/:user_id" => "suitability/benchmarks/user_assessments#user", :as => :user
      end

      resources :users, path: "candidates", :except => [:destroy, :show] do
        resources :user_assessment_reports, :controller => :assessment_reports, :path => "reports", :only => [ :show ] do
          member do
            get "assessment_report" => "assessment_reports#assessment_report", :as => :assessment_report
            get "competency_report" => "assessment_reports#competency_report", :as => :competency_report
            get "manage" => "assessment_reports#manage", :as => :manage
            put "manage" => "assessment_reports#manage", :as => :manage
          end
        end
      end
    end

    resources :custom_assessments, :fit_assessments, :competency_assessments, :controller => "suitability/custom_assessments", :path => "tests", :except => [:destroy] do
      member do
        get "download_pdf_reports" => "suitability/custom_assessments#download_pdf_reports", :as => :download_pdf_reports
        match "norms" => "suitability/custom_assessments#norms", :as => :norms
        match "set_weightage" => "suitability/custom_assessments#set_weightage", :as => :set_weightage
        match "functional_traits" => "suitability/custom_assessments#functional_traits", :as => :functional_traits
        get "reports" => "suitability/custom_assessments/user_assessments#reports", :as => :reports
        match "competency_norms" => "suitability/custom_assessments#competency_norms", :as => :competency_norms
        match "competencies" => "suitability/custom_assessments#competencies", :as => :competencies

        match "styles" => "suitability/custom_assessments#styles", :as => :styles

        get "enable_training_requirements_report" => "suitability/custom_assessments/training_requirements_reports#enable_training_requirements_report", :as => :enable_training_requirements_report

        get "download_training_requirements_report" => "suitability/custom_assessments/training_requirements_reports#download_report", :as => :download_training_requirements_report

        get "training_requirements" => "suitability/custom_assessments/training_requirements_reports#training_requirements", :as => :training_requirements

        put "training_requirements/:assessment_report_id" => "suitability/custom_assessments/training_requirements_reports#update", :as => :update_training_requirements
        post "training_requirements" => "suitability/custom_assessments/training_requirements_reports#create", :as => :create_training_requirements

        get "training_requirements_report" => "assessment_reports#training_requirements_report", :as => :training_requirements_report

        get "candidates" => "suitability/custom_assessments/user_assessments#users", :as => :users
        match "candidates/add" => "suitability/custom_assessments/user_assessments#add_users", :as => :add_users
        get "candidates/add_bulk" => "suitability/custom_assessments/user_assessments#add_users_bulk", :as => :add_users_bulk

        get "candidates/expire_links" => "suitability/custom_assessments/user_assessments#expire_links", :as => :expire_links

        match "candidates/send-reminder-to-pending" =>"suitability/custom_assessments/user_assessments#send_reminder_to_pending_users", :as => :send_reminder_to_pending_users
        put "candidates/bulk_upload" => "suitability/custom_assessments/user_assessments#bulk_upload", :as => :bulk_upload
        
        match "email_reports" => "suitability/custom_assessments/user_assessments#email_reports", :as => :email_reports
        
        get "trigger_report_downloader" => "suitability/custom_assessments/user_assessments#trigger_report_downloader", :as => :trigger_report_downloader

        get "export_feedback_scores" => "suitability/custom_assessments/user_assessments#export_feedback_scores", :as => :export_feedback_scores

        match "email_assessment_status" => "suitability/custom_assessments/user_assessments#email_assessment_status", :as => :email_assessment_status

        match "candidates/send-test" => "suitability/custom_assessments/user_assessments#send_test_to_users", :as => :send_test_to_users
        put "candidates/bulk-send-test" => "suitability/custom_assessments/user_assessments#bulk_send_test_to_users", :as => :bulk_send_test_to_users
        match "candidates/resend-invitations" => "suitability/custom_assessments/user_assessments#resend_invitations", :as => :resend_invitations
        match "candidates/:user_id/send-reminder" => "suitability/custom_assessments/user_assessments#send_reminder", :as => :send_reminder_to_user
        get "candidates/:user_id" => "suitability/custom_assessments/user_assessments#user", :as => :user
        match "candidates/:user_id/extend-validity" => "suitability/custom_assessments/user_assessments#extend_validity", :as => :extend_validity
        get "candidates/:user_id/expire-link" => "suitability/custom_assessments/user_assessments#expire_assessment_link", :as => :expire_assessment_link
        get "candidates/:user_id/update-status" => "suitability/custom_assessments/user_assessments#update_status", :as => :update_status
      end

      resources :users, path: "candidates", :except => [:destroy, :show] do
        resources :user_assessment_reports, :controller => :assessment_reports, :path => "reports", :only => [ :show ] do
          member do
            get "assessment_report" => "assessment_reports#assessment_report", :as => :assessment_report
            get "competency_report" => "assessment_reports#competency_report", :as => :competency_report
            match "manage" => "assessment_reports#manage", :as => :manage
          end
        end
      end

      resources :users, :except => [:destroy, :show] do
        resources :user_assessment_reports, :controller => :assessment_reports, :path => "reports", :only => [ :show ] do
          member do
            get "assessment_report" => "assessment_reports#assessment_report", :as => :assessment_report
            get "competency_report" => "assessment_reports#competency_report", :as => :competency_report
            match "manage" => "assessment_reports#manage", :as => :manage
          end
        end
      end
    end

    resources :mrf_walkin_groups, path: "360/walk-ins", :controller => "mrf/walkin_groups" do
      member do
        match "summary" => "mrf/walkin_groups#summary", as: :summary
        match "customize" => "mrf/walkin_groups#customize", as: :customize
        get "expire" => "mrf/walkin_groups#expire", as: :expire
      end
    end

    resources :mrf_assessments, :controller => "mrf/assessments", :path => "360" do
      resources :user_assessments, :controller => "mrf/assessments/user_assessments" do
        collection do
          match "add" => "mrf/assessments/user_assessments#add_users", :as => :add
          match "bulk_upload" => "mrf/assessments/user_assessments#bulk_upload", :as => :bulk_upload
        end
      end

      collection do
        get "create_for_assessment" => "mrf/assessments#create_for_assessment", :as => :create_for_assessment
        get "candidates" => "mrf/feedbacks#index", :as => :users
        match "home" => "mrf/assessments#home", :as => :home
      end

      member do
        get "group_reports" => "mrf/assessments/assessment_reports#group_reports", :as => :group_reports
        get "group_reports/new" => "mrf/assessments/assessment_reports#new_group_report", :as => :new_group_report
        get "group_report/:report_id" => "mrf/assessments/assessment_reports#s3_report", :as => :s3_group_report
        get "group_report/:report_id/mrf_report" => "mrf/assessments/assessment_reports#group_report", :as => :group_report

        get "group_report/:report_id/edit" => "mrf/assessments/assessment_reports#edit_group_report", :as => :edit_group_report
        post "group_report" => "mrf/assessments/assessment_reports#create", :as => :create_group_report
        put "group_report/:report_id" => "mrf/assessments/assessment_reports#update", :as => :update_group_report

        get "details" => "mrf/assessments#details", :as => :details
        get "traits" => "mrf/assessments#traits", :as => :traits

        get "candidates" => "mrf/assessments/user_feedback#users", :as => :users
        get ":user_id/statistics" => "mrf/assessments/user_feedback#statistics", :as => :user_statistics
        get ":user_id/stakeholders" => "mrf/assessments/user_feedback#stakeholders", :as => :user_stakeholders
        get "stakeholders/:stakeholder_id" => "mrf/assessments/user_feedback#stakeholder", :as => :stakeholder
        get ":user_id/update_feedback" => "mrf/assessments/user_feedback#update_feedback", :as => :update_feedback

        get "order_enable_items" => "mrf/assessments#order_enable_items", :as => :order_enable_items
        get "candidates/:user_id/reports/:report_id/mrf_report" => "mrf/assessments/reports#report", :as => :report
        get "candidates/:user_id/reports/:report_id" => "mrf/assessments/reports#s3_report", :as => :s3_report


        match "competencies" => "mrf/assessments#competencies", :as => :competencies
        match "add_traits" => "mrf/assessments#add_traits", :as => :add_traits
        match "add_traits_range" => "mrf/assessments#add_traits_range", :as => :add_traits_range
        match "select_users" => "mrf/assessments/user_feedback#select_users", :as => :select_users
        match "order_enable_items" => "mrf/assessments#order_enable_items", :as => :order_enable_items
        match "add_subjective_items" => "mrf/assessments#add_subjective_items", :as => :add_subjective_items
        match "add_stakeholders" => "mrf/assessments/user_feedback#add_stakeholders", :as => :add_stakeholders
        match "/send-reminder" => "mrf/assessments/user_feedback#send_reminder", :as => :send_reminder
        match "bulk_upload" => "mrf/assessments/user_feedback#bulk_upload", :as => :bulk_upload

        match "set_cap" => "mrf/assessments#set_cap", :as => :set_cap

        get "/download_sample_csv_for_mrf_bulk_upload", :to => "mrf/assessments/user_feedback#download_sample_csv_for_mrf_bulk_upload", :as => :download_sample_csv_for_mrf_bulk_upload
        get "/export_feedback_urls" => "mrf/assessments/user_feedback#export_feedback_urls", :as => :export_feedback_urls
        get "/export_feedback_status" => "mrf/assessments/user_feedback#export_feedback_status", :as => :export_feedback_status
        get "/export_report_urls" => "mrf/assessments/user_feedback#export_report_urls", :as => :export_report_urls
        get "/enable-self-ratings" => "mrf/assessments/user_feedback#enable_self_ratings", :as => :enable_self_ratings
        get "/expire_feedback_urls" => "mrf/assessments/user_feedback#expire_feedback_urls", :as => :expire_feedback_urls
      end
    end


    resources :sjt_assessments, :controller => "sjt/assessments", :path=> "sjt" do
      collection do
        match "home" => "sjt/assessments#home", :as => :home
      end

      member do
        match "competencies" => "sjt/assessments#competencies", :as => :competencies
        match "competencies_measured" => "sjt/assessments#competencies_measured", :as => :competencies_measured
        match "send_test_to_users" => "sjt/assessments/user_assessments#send_test_to_users", :as => :send_test_to_users
        match "candidates" => "sjt/assessments/user_assessments#users", :as => :users
        match "add_users" => "sjt/assessments/user_assessments#add_users", :as => :add_users
        match "candidates/add_bulk" => "sjt/assessments/user_assessments#add_users_bulk", :as => :add_users_bulk
        put "candidates/bulk_upload" => "sjt/assessments/user_assessments#bulk_upload", :as => :bulk_upload
        put "candidates/bulk-send-test" => "sjt/assessments/user_assessments#bulk_send_test_to_users", :as => :bulk_send_test_to_users
        get "candidates/expire_links" => "sjt/assessments/user_assessments#expire_links", :as => :expire_links
        match "candidates/resend-invitations" => "sjt/assessments/user_assessments#resend_invitations", :as => :resend_invitations
        match "candidates/:user_id" => "sjt/assessments/user_assessments#user", :as => :user
        match "reports" => "sjt/assessments/user_assessments#reports", :as => :reports
        match "email_assessment_status" => "sjt/assessments/user_assessments#email_assessment_status", :as => :email_assessment_status
        match "candidates/:user_id/extend-validity" => "sjt/assessments/user_assessments#extend_validity", :as => :extend_validity
        get "trigger_report_downloader" => "sjt/assessments/user_assessments#trigger_report_downloader", :as => :trigger_report_downloader
        get "export_feedback_scores" => "sjt/assessments/user_assessments#export_feedback_scores", :as => :export_feedback_scores
        match "candidates/:user_id/send-reminder" => "sjt/assessments/user_assessments#send_reminder", :as => :send_reminder_to_user
        match "email_reports" => "sjt/assessments/user_assessments#email_reports", :as => :email_reports
      end

    end

    resources :oac_exercises, :controller => "oac/exercises", :path => "oac" do
      collection do
        match "home" => "oac/exercises#home", :as => :home
      end

      member do
        match "edit" => "oac/exercises#edit", :as => :edit
        match "select_tools" => "oac/exercises#select_tools", :as => :select_tools
        match "select_competencies" => "oac/exercises#select_competencies", :as => :select_competencies
        match "select_super_competencies" => "oac/exercises#select_super_competencies", :as => :select_super_competencies
        match "set_weightage" => "oac/exercises#set_weightage", :as => :set_weightage
        match "customize_assessment" => "oac/exercises#customize_assessment", :as => :customize_assessment
        match "add_candidates" => "oac/exercises/user_exercises#add_candidates", :as => :add_candidates
        get "add_bulk" => "oac/exercises/user_exercises#add_users_bulk", :as => :add_users_bulk
        put "bulk_upload" => "oac/exercises/user_exercises#bulk_upload", :as => :bulk_upload
        put "bulk_send_assessment" => "oac/exercises/user_exercises#bulk_send_assessment", :as => :bulk_send
        match "send_assessment" => "oac/exercises/user_exercises#send_assessment", :as => :send_assessment
        
        get "candidates" => "oac/exercises/user_exercises#candidates", :as => :candidates
        get "candidates/:user_id/" => "oac/exercises/user_exercises#candidate", :as => :candidate
        match "candidates/:user_id/send_reminder" => "oac/exercises/user_exercises#send_reminder", :as => :send_reminder
        match "candidates/:user_id/assign_assessor" => "oac/exercises/user_exercises#assign_assessor", :as => :assign_assessor

        get "candidates/:user_id/reports/:report_id/oac_report" => "oac/exercises/reports#report", :as => :report
        get "candidates/:user_id/reports/:report_id" => "oac/exercises/reports#s3_report", :as => :s3_report
        
        get "download_bulk_upload_csv" => "oac/exercises/user_exercises#download_bulk_upload_csv", as: :download_bulk_upload_csv
        get "export_report_summary" => "oac/exercises/user_exercises#export_report_summary", :as => :export_report_summary
      end
    end

    resources :engagement_surveys, :controller => "engagement/surveys", :path => "engagement" do
      collection do
        match "home" => "engagement/surveys#home", :as => :home
      end

      member do
        match "add_elements" => "engagement/surveys#add_elements", :as => :add_elements

        get "details" => "engagement/surveys#details", :as => :details
        get "elements" => "engagement/surveys#elements", :as => :elements

        get "candidates" => "engagement/surveys/users#users", :as => :users
        match "candidates/add" => "engagement/surveys/users#add_users", :as => :add_users
        get "candidates/add_bulk" => "engagement/surveys/users#add_users_bulk", :as => :add_users_bulk
        get "candidates/send-reminder-to-pending" =>"engagement/surveys/users#send_reminder_to_pending_users",:as => :send_reminder_to_pending_users
        put "candidates/bulk_upload" => "engagement/surveys/users#bulk_upload", :as => :bulk_upload
        get "email_reports" => "engagement/surveys/users#email_reports", :as => :email_reports
        get "export_feedback_scores" => "engagement/surveys/users#export_feedback_scores", :as => :export_feedback_scores

        get "email_assessment_status" => "engagement/surveys/users#email_assessment_status", :as => :email_assessment_status

        match "candidates/send-survey" => "engagement/surveys/users#send_survey_to_users", :as => :send_survey_to_users
        put "candidates/bulk-send-test" => "engagement/surveys/users#bulk_send_survey_to_users", :as => :bulk_send_survey_to_users

        match "candidates/:user_id/send-reminder" => "engagement/surveys/users#send_reminder", :as => :send_reminder
        get "candidates/:user_id" => "engagement/surveys/users#user", :as => :user

        get "candidates/:user_id/reports/:report_id/engagement_report" => "engagement/surveys/reports#report", :as => :report
        get "candidates/:user_id/reports/:report_id" => "engagement/surveys/reports#s3_report", :as => :s3_report

        put "bulk_upload" => "engagement/surveys/users#bulk_upload", :as => :bulk_upload
        get "/download_sample_csv_for_engagement_bulk_upload", :to => "engagement/surveys/users#download_sample_csv_for_engagement_bulk_upload", :as => :download_sample_csv_for_engagement_bulk_upload
      end
    end

    resources :exit_surveys, :controller => "exit/surveys", :path => "exit" do
      collection do
        match "home" => "exit/surveys#home", :as => :home
      end

      member do
        match "add_items" => "exit/surveys#add_items", :as => :add_items

        get "details" => "exit/surveys#details", :as => :details
        get "traits" => "exit/surveys#traits", :as => :traits

        get "candidates" => "exit/surveys/users#users", :as => :users
        match "candidates/add" => "exit/surveys/users#add_users", :as => :add_users
        get "candidates/add_bulk" => "exit/surveys/users#add_users_bulk", :as => :add_users_bulk
        get "candidates/send-reminder-to-pending" =>"exit/surveys/users#send_reminder_to_pending_users",:as => :send_reminder_to_pending_users
        put "candidates/bulk_upload" => "exit/surveys/users#bulk_upload", :as => :bulk_upload
        get "email_reports" => "exit/surveys/users#email_reports", :as => :email_reports
        get "export_feedback_scores" => "exit/surveys/users#export_feedback_scores", :as => :export_feedback_scores

        get "email_assessment_status" => "exit/surveys/users#email_assessment_status", :as => :email_assessment_status

        match "candidates/send-survey" => "exit/surveys/users#send_survey_to_users", :as => :send_survey_to_users
        put "candidates/bulk-send-test" => "exit/surveys/users#bulk_send_survey_to_users", :as => :bulk_send_survey_to_users

        match "candidates/:user_id/send-reminder" => "exit/surveys/users#send_reminder", :as => :send_reminder
        get "candidates/:user_id" => "exit/surveys/users#user", :as => :user

        get "candidates/:user_id/reports/:report_id/exit_report" => "exit/surveys/reports#report", :as => :report
        get "candidates/:user_id/reports/:report_id" => "exit/surveys/reports#s3_report", :as => :s3_report

        get "group_reports/:report_id/exit_report" => "exit/surveys/group_reports#report", :as => :group_report
        get "group_reports/new" => "exit/surveys/group_reports#new", :as => :new_group_report
        get "group_reports" => "exit/surveys/group_reports#index", :as => :group_reports
        post "group_reports" => "exit/surveys/group_reports#create", :as => :create_group_report

        get "group_reports/:report_id/edit" => "exit/surveys/group_reports#edit", :as => :edit_group_report
        put "group_reports/:report_id" => "exit/surveys/group_reports#update", :as => :update_group_report
        get "group_reports/:report_id" => "exit/surveys/group_reports#s3_report", :as => :s3_group_report


        put "bulk_upload" => "exit/surveys/users#bulk_upload", :as => :bulk_upload
        get "/download_sample_csv_for_exit_bulk_upload", :to => "exit/surveys/users#download_sample_csv_for_exit_bulk_upload", :as => :download_sample_csv_for_exit_bulk_upload
      end
    end

    resources :retention_surveys, :controller => "retention/surveys", :path => "retention" do
      collection do
        match "home" => "retention/surveys#home", :as => :home
      end

      member do
        match "add_items" => "retention/surveys#add_items", :as => :add_items

        get "details" => "retention/surveys#details", :as => :details
        get "traits" => "retention/surveys#traits", :as => :traits

        get "candidates" => "retention/surveys/users#users", :as => :users
        get "candidates/add" => "retention/surveys/users#add_users", :as => :add_users
        put "candidates/add" => "retention/surveys/users#add_users", :as => :add_users
        get "candidates/add_bulk" => "retention/surveys/users#add_users_bulk", :as => :add_users_bulk
        get "candidates/send-reminder-to-pending" =>"retention/surveys/users#send_reminder_to_pending_users",:as => :send_reminder_to_pending_users
        put "candidates/bulk_upload" => "retention/surveys/users#bulk_upload", :as => :bulk_upload
        get "email_reports" => "retention/surveys/users#email_reports", :as => :email_reports
        get "export_feedback_scores" => "retention/surveys/users#export_feedback_scores", :as => :export_feedback_scores

        get "email_assessment_status" => "retention/surveys/users#email_assessment_status", :as => :email_assessment_status

        match "candidates/send-survey" => "retention/surveys/users#send_survey_to_users", :as => :send_survey_to_users
        put "candidates/bulk-send-test" => "retention/surveys/users#bulk_send_survey_to_users", :as => :bulk_send_survey_to_users

        match "candidates/:user_id/send-reminder" => "retention/surveys/users#send_reminder", :as => :send_reminder
        get "candidates/:user_id" => "retention/surveys/users#user", :as => :user
      end
    end

    resources :jobs do
      collection do
        get :manage
        get :destroy_all
        post :import
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
  end

  resources :company_managers do
    collection do
      get :manage
      get :destroy_all
      post :import
      post :import_from_google_drive
      post :export_to_google_drive
      get :email_usage_stats, :as => :email_usage_stats
      get :email_assessment_stats, :as => :email_assessment_stats
      get :email_reports_summary, :as => :email_reports_summary
    end
  end

  resources :standard_assessments, :controller => "suitability/standard_assessments", :path => "standard-tests", :except => [:destroy] do
    member do
      match "norms" => "suitability/standard_assessments#norms", :as => :norms
      get "reports" => "suitability/standard_assessments#reports", :as => :reports
      match "competency_norms" => "suitability/standard_assessments#competency_norms", :as => :competency_norms
      match "competencies" => "suitability/standard_assessments#competencies", :as => :competencies
      match "styles" => "suitability/standard_assessments#styles", :as => :styles
    end
  end

  resources :templates do
    collection do
      post :import
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end
  
  resources :template_categories do
  end

  resources :template_variables do
    collection do
      post :import
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end

  resources :report_configurations do
    collection do
      get :load_configuration
      post :report_preview_mrf
      post :report_preview_suitability
      post :report_preview_oac
    end
  end

  resources :sections do
    collection do
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end

  resources :functional_areas do
    collection do
      post :import
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end

  resources :subscriptions, :only => [:index] do
    collection do
      post :expire_subscription, :as => :expire_subscription
      post :payment_status, :as => :payment_status
      post :import
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end

  resources :plans do
    collection do
      post :import
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end

  resources :languages do
    collection do
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end


  resources :locations do
    collection do
      get :get_locations
      post :import
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end

  resources :industries do
    collection do
      post :import
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end

  resources :degrees do
    collection do
      post :import
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end

  resources :job_experiences do
    collection do
      post :import
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end

  resources :teams do
    collection do
      get :get_teams
      post :import
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end



  namespace :functional do
    resources :traits do
      collection do
        get :get_traits
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :trait_score_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :norm_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :items do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
        post :import_with_options_from_google_drive
      end
      resources :options do
      end
    end
  end

  resources :objective_items do
    collection do
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
      post :import_with_options_from_google_drive
    end
    resources :objective_options do
    end
  end

  resources :subjective_items do
    collection do
      get :manage
      get :destroy_all
      post :import_from_google_drive
      post :export_to_google_drive
    end
  end

  namespace :mrf do
    get "assessments_management" => 'assessments_management#manage', :as => :assessments_management
    post 'assessments_management/export_mrf_scores' => 'assessments_management#export_mrf_scores', :as => :export_scores
    post 'assessments_management/export_mrf_raw_scores' => 'assessments_management#export_mrf_raw_scores', :as => :export_raw_scores
    match 'assessments_management/replicate_assessment' => 'assessments_management#replicate_assessment', :as => :replicate_assessment

    resources :subscriptions, :only => [:index] do
      collection do
        post :expire_subscription, :as => :expire_subscription
        post :import
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :traits do
      collection do
        get :get_traits
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :competency_guidelines do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :trait_guidelines do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :subjective_items do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :items do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
        post :import_with_options_from_google_drive
      end
      resources :options do
      end
    end

    resources :trait_score_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :competency_score_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :trait_graph_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :competency_graph_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :norm_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :default_trait_norm_ranges do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :default_competency_norm_ranges do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

  end

  namespace :engagement  do
    resources :facets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :factors do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :elements do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :items do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
        post :import_with_options_from_google_drive
      end
    end
  end

  namespace :retention do
    resources :traits do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :items do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
        post :import_with_options_from_google_drive
      end
    end
  end

  namespace :exit  do
    resources :traits do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :items do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
        post :import_with_options_from_google_drive
      end
    end

    resources :item_groups do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
  end

  namespace :suitability do
    get "assessments_management" => 'assessments_management#manage', :as => :assessments_management
    match 'assessments_management/replicate_assessment' => 'assessments_management#replicate_assessment', :as => :replicate_assessment
    match 'assessments_management/projection_report' => 'assessments_management#projection_report', :as => :projection_report
    
    resources :super_competencies do
      collection do
        get :manage
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
    
    resources :super_competency_score_buckets do
      collection do
        get :manage
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
    
    resources :super_competency_score_bucket_descriptions do
      collection do
        get :manage
        post :export_to_google_drive
        post :import_via_s3
      end
    end

    resources :item_groups do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
        post :import_with_options_from_google_drive
      end
    end

    resources :user_assessment_report_feedbacks do
      collection do
        get "thank-you" => "user_assessment_report_feedbacks#thank_you", :as => :thank_you_page
      end
    end

    resources :items do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
      get :add_option
      resources :options do
      end
    end

    resources :factor_norm_bucket_descriptions do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
        post :import_via_s3
      end
    end

    resources :default_factor_norm_ranges do
      collection do
        get :manage
        get :destroy_all
        post :import_via_s3
        post :export_to_google_drive
      end
    end

    resources :fitment_grade_mappings do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :fitment_grade do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :fits do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :competencies do
      collection do
        get :manage
        get :get_competencies
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :competency_grades do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :norm_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :consistency_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :overall_factor_score_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :factor_score_ratings do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :company_norm_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :competency_score_ratings do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :aggregate_competency_score_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :pattern_response_buckets do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :fitment_grades do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :overall_fitment_grades do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :post_assessment_guidelines do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
        post :import_via_s3
      end
    end

    resources :recommendations do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :factors do
      collection do
        get :get_factors
        post :import
        get :manage
        post :manage
        post :import_display_names
        get :export_display_names
        post :export_display_names
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    namespace :job do
      resources :factor_norms do
        collection do
          #post :import
          get :edit
          get :manage
          #get :destroy_all
          post :import_via_s3
          post :export_to_google_drive
        end
      end
    end
  end

  namespace :oac, path: "oac" do
    get "manage" => "exercise_management#manage", as: :manage
    post "export_tool_wise_scores" => "exercise_management#export_tool_wise_scores", as: :export_tool_wise_scores
    post "import_tool_wise_scores" => "exercise_management#import_tool_wise_scores", as: :import_tool_wise_scores
    
    resources :super_competency_guidelines do
      collection do
        get :manage
        get :count
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
        
    resources :exercise_super_competencies do
      collection do
        get :manage
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
    
    resources :aggregate_super_competency_score_buckets do
      collection do
        get :manage
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
    
    resources :aggregate_super_competency_score_ratings do
      collection do
        get :manage
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
    
    resources :combined_super_competency_score_buckets do
      collection do
        get :manage
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
    
    resources :combined_competency_score_buckets do
      collection do
        get :manage
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
    
    resources :user_super_competency_scores do
    end
    
    resources :user_competency_scores do
    end
    
    resources :tools do
    end
  end

  namespace :sq do
    resources :quadrants do
      collection do
        post :import
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

     resources :activities do
      collection do
        post :import
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    namespace :premium do

       resources :books do
        collection do
          post :import
          get :manage
          get :destroy_all
          post :import_from_google_drive
          post :export_to_google_drive
        end
      end

       resources :events do
        collection do
          post :import
          get :manage
          get :destroy_all
          post :import_from_google_drive
          post :export_to_google_drive
        end
      end

       resources :foods do
        collection do
          post :import
          get :manage
          get :destroy_all
          post :import_from_google_drive
          post :export_to_google_drive
        end
      end

    end
    namespace :inspirations do

       resources :quotes do
        collection do
          post :import
          get :manage
          get :destroy_all
          post :import_from_google_drive
          post :export_to_google_drive
        end
      end

       resources :stories do
        collection do
          post :import
          get :manage
          get :destroy_all
          post :import_from_google_drive
          post :export_to_google_drive
        end
      end

       resources :videos do
        collection do
          post :import
          get :manage
          get :destroy_all
          post :import_from_google_drive
          post :export_to_google_drive
        end
      end

    end

    resources :exercises do
      collection do
        post :import
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :items do
      collection do
        get :manage
        post :import_from_google_drive
        post :export_to_google_drive
        post :import_with_options_from_google_drive
      end
    end

    resources :options
  end


  namespace :social_recognition do
    resources :moods do
      collection do
        post :import
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
    resources :behaviors do
      collection do
        post :import
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
    resources :lead_points do
      collection do
        post :import
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
    resources :gift_providers do
      collection do
        post :import
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

  end

  namespace :finance do
    resources :mutual_funds do
      collection do
        post :import
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end
  end

  namespace :form_builder do
    resources :defined_forms do
      collection do
        get :manage
        post :replicate
      end
    end
    resources :factual_information_forms
  end

  namespace :jq do
    resources :user_assessment_reports do
      collection do
        get :manage
        post :export_norm_population
        post :import_norm_population
      end
      member do
        get :report
      end
    end

    resources :quadrant_descriptions do
      collection do
        get :manage
        post :destroy_all
        get :count
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :functions do
      collection do
        get :manage
        post :destroy_all
        get :count
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :jobs do
      collection do
        post :destroy_all
        get :manage
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :interview_questions do
      collection do
        post :destroy_all
        get :manage
        post :import_from_google_drive
        post :export_to_google_drive
      end
    end

    resources :user_jobs

    resources :multimedia_answers
  end

  resources :multimedia_profiles
  resources :work_experiences
  
  resources :stakeholders do
  end
  
  namespace :idp do
    resources :idps do
      collection do
        get :manage
        post :import_via_s3
      end
    end
    resources :alps
    resources :competencies
    resources :comments
    resources :feedbacks
    resources :tasks
    resources :meetings
    resources :meeting_updates
    resources :meeting_users
    resources :resources
  end

  get "/competency_management/", :to => "suitability/competencies_management#manage", :as => :competencies_management

  get "/trr/manage", :to => "suitability/custom_assessments/training_requirements_reports_management#manage", :as => :trr_manage
  post "/trr/manage/export_assessment_trr_users", :to =>  "suitability/custom_assessments/training_requirements_reports_management#export_assessment_trr_users", :as => :export_assessment_trr_users
  post "/trr/manage/export_group_trr_users", :to => "suitability/custom_assessments/training_requirements_reports_management#export_group_trr_users", :as => :export_group_trr_users
  post "/trr/manage/import_assessment_trr_users", :to => "suitability/custom_assessments/training_requirements_reports_management#import_assessment_trr_users", :as => :import_assessment_trr_users
  post "/trr/manage/import_group_trr_users", :to => "suitability/custom_assessments/training_requirements_reports_management#import_group_trr_users", :as => :import_group_trr_users

  match "/login", :to => "users#login", :as => :login
  match "/logout", :to => "users#logout", :via => [:get, :delete], :as => :logout

  get "/sidekiq/queue-job" => "sidekiq#queue_job"
  get "/sidekiq/generate_factor_benchmarks" => "sidekiq#generate_factor_benchmarks"
  get "/sidekiq/generate_mrf_scores" => "sidekiq#generate_mrf_scores"
  get "/sidekiq/upload_reports", :to => "sidekiq#upload_reports"
  get "/sidekiq/upload_jq_reports", :to => "sidekiq#upload_jq_reports"
  get "/sidekiq/upload_mrf_reports", :to => "sidekiq#upload_mrf_reports"
  get "/sidekiq/upload_mrf_group_reports", :to => "sidekiq#upload_mrf_group_reports"
  get "/sidekiq/upload_engagement_reports", :to => "sidekiq#upload_engagement_reports"
  get "/sidekiq/upload_exit_reports", :to => "sidekiq#upload_exit_reports"
  get "/sidekiq/upload_exit_group_reports", :to => "sidekiq#upload_exit_group_reports"
  get "/sidekiq/upload_benchmark_reports", :to => "sidekiq#upload_benchmark_reports"
  get "/sidekiq/upload_training_requirements_reports", :to => "sidekiq#upload_training_requirements_reports"
  get "/sidekiq/upload_training_requirement_groups_reports", :to => "sidekiq#upload_training_requirement_groups_reports"
  get "/sidekiq/upload_oac_reports", :to => "sidekiq#upload_oac_reports"


  match "/sidekiq/regenerate_reports/", :to => "reports_management#regenerate_reports", :as => :regenerate_reports
  match "/sidekiq/regenerate_mrf_reports/", :to => "reports_management#regenerate_mrf_reports", :as => :regenerate_mrf_reports
  match "/sidekiq/regenerate_exit_individual_reports/", :to => "reports_management#regenerate_exit_individual_reports", :as => :regenerate_exit_individual_reports
  match "/sidekiq/regenerate_exit_group_reports/", :to => "reports_management#regenerate_exit_group_reports", :as => :regenerate_exit_group_reports

  get "/master-data", :to => "pages#home", :as => :master_data
  get "/help/adding_users", :to => "help#adding_users", :as => :help_adding_users
  get "/help/process-explanation", :to => "help#process_explanation", :as => :help_process_explanation
  get "/download_sample_csv_for_user_bulk_upload", :to => "help#download_sample_csv_for_user_bulk_upload", :as => :download_sample_csv_for_user_bulk_upload
  get "/report-management", :to => "reports_management#report_management", :as => :report_management
  match "/report-generator", :to => "reports_management#report_generator", :as => :report_generator
  post "/report-generator-scores", :to => "reports_management#report_generator_scores", :as => :report_generator_scores
  post "/generate_report", :to =>"reports_management#generate_report", :as => :generate_report
  put "/modify_norms", :to => "reports_management#modify_norms", :as => :modify_norms
  put "/manage_report", :to => "reports_management#manage_report", :as => :manage_report

  get "/suitability_cover_page", :to => "report_cover#cover", :as => :report_cover


  resources :global_configurations do
    collection do
      post :update_fallback_strategy
    end
  end
  
  match "/sign_up" => "signup#sign_up", :as => :sign_up
  root :to => "users#login"

  mount JombayNotify::Engine => "/jombay-notify"
  mount Sidekiq::Web => '/sidekiq'
end
