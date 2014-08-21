Recruiters::Application.routes.draw do
  resources :candidates do
    member do
      match 'generate_assessment_link' => "candidates_management#generate_assessment_link", :as => :generate_assessment_link
      match 'deactivate_assessment_link' => "candidates_management#deactivate_assessment_link", :as => :deactivate_assessment_link
      get 'assessment_link/:assessment_id' => "candidates_management#assessment_link", :as => :assessment_link
      match 'update_candidate_stage' => "candidates_management#update_candidate_stage", :as => :update_candidate_stage
    end
    collection do
      get "manage" => "candidates_management#manage", :as => :manage
      post "update_candidate_assessments" => "candidates_management#update_candidate_assessments", :as => :update_candidate_assessments
      post 'export' => "candidates_management#export"
      post 'import' => "candidates_management#import"
      post 'export_validation_progress' => "candidates_management#export_validation_progress"
      post 'export_candidate_responses' => "candidates_management#export_candidate_responses"
      post 'export_candidate_reports' => "candidates_management#export_candidate_reports"
      post 'export_candidate_report_urls' => "candidates_management#export_candidate_report_urls"
      get :destroy_all
    end
  end

  resources :companies do
    collection do
      post :import
      get :manage
      get :destroy_all
      post 'import_from_google_drive'
      post 'export_to_google_drive'
      post :export_companies
      post :export_monthly_report
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

      get "reports" => "companies#reports", :as => :reports
      get "settings" => "company_settings#settings", :as => :settings
      get "statistics" => "company_statistics#statistics", :as => :statistics
      get "settings/company" => "company_settings#company", :as => :company_settings
      get "settings/account" => "company_settings#account", :as => :account_settings
      get "settings/user_settings" => "company_settings#user_settings", :as => :user_settings
      get "settings/data/competencies" => "company_settings#competencies", :as => :competencies
      get "settings/data/competencies/create" => "company_settings#create_competencies", :as => :create_competencies
      get "settings/data/competencies/:id/details/" => "company_settings#competency", :as => :competency
      match "settings/user_settings/add_users" => "company_settings#add_users", :as => :add_users
      put "settings/user_settings/remove_users" => "company_settings#remove_users", :as => :remove_users
      get "settings/user_settings/confirm_remove_users" => "company_settings#confirm_remove_users", :as => :confirm_remove_users
      get "candidates/:candidate_id" => "companies#candidate", :as => :candidate
      get "add_subscription" => "companies#add_subscription", :as => :add_subscription
      get "home" => "companies#home", :as => :home
      get "landing" => "companies#landing", :as => :landing
    end

    resources :hiring_managers, :only => [:index, :new] do
      collection do
        post :import
        get 'assign_jobs' => "hiring_managers#assign_jobs_form", :as => :assign_jobs_form
        post :assign_jobs
        post 'import_from_google_drive'
        post 'export_to_google_drive'
      end
    end

    resources :admins, :only => [:index, :new] do
      collection do
        get :manage
        get :destroy_all
        post :import
        post 'import_from_google_drive'
        post 'export_to_google_drive'
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
        get "download_report" => "training_requirement_groups#download_report", as: :download_report
        get "training_requirements_report" => "training_requirement_groups#training_requirements_report", :as => :training_requirements_report
      end
    end

    resources :benchmarks, :controller => "suitability/benchmarks", :except => [:destroy] do
      member do
        get "norms" => "suitability/benchmarks#norms", :as => :norms
        put "norms" => "suitability/benchmarks#norms", :as => :norms

        get "competency_norms" => "suitability/benchmarks#competency_norms", :as => :competency_norms
        put "competency_norms" => "suitability/benchmarks#competency_norms", :as => :competency_norms
        get "competencies" => "suitability/benchmarks#competencies", :as => :competencies
        put "competencies" => "suitability/benchmarks#competencies", :as => :competencies

        get "styles" => "suitability/benchmarks#styles", :as => :styles
        put "styles" => "suitability/benchmarks#styles", :as => :styles

        get "download_benchmark_report" => "suitability/benchmarks#download_benchmark_report", :as => :download_benchmark_report
        get "benchmark_report" => "suitability/assessment_reports#benchmark_report", :as => :benchmark_report

        get "candidates" => "suitability/benchmarks/candidate_assessments#candidates", :as => :candidates
        get "candidates/add" => "suitability/benchmarks/candidate_assessments#add_candidates", :as => :add_candidates
        put "candidates/add" => "suitability/benchmarks/candidate_assessments#add_candidates", :as => :add_candidates

        put "candidates/bulk_upload" => "suitability/benchmarks/candidate_assessments#bulk_upload", :as => :bulk_upload
        get "email_reports" => "suitability/benchmarks/candidate_assessments#email_reports", :as => :email_reports

        get "candidates/send-test" => "suitability/benchmarks/candidate_assessments#send_test_to_candidates", :as => :send_test_to_candidates
        put "candidates/send-test" => "suitability/benchmarks/candidate_assessments#send_test_to_candidates", :as => :send_test_to_candidates
        put "candidates/bulk-send-test" => "suitability/benchmarks/candidate_assessments#bulk_send_test_to_candidates", :as => :bulk_send_test_to_candidates
        get "candidates/:candidate_id/send-reminder" => "suitability/benchmarks/candidate_assessments#send_reminder", :as => :send_reminder_to_candidate
        put "candidates/:candidate_id/send-reminder" => "suitability/benchmarks/candidate_assessments#send_reminder", :as => :send_reminder_to_candidate
        get "candidates/:candidate_id" => "suitability/benchmarks/candidate_assessments#candidate", :as => :candidate
      end

      resources :candidates, :except => [:destroy, :show] do
        resources :candidate_assessment_reports, :controller => :assessment_reports, :path => "reports", :only => [ :show ] do
          member do
            get "assessment_report" => "assessment_reports#assessment_report", :as => :assessment_report
            get "competency_report" => "assessment_reports#competency_report", :as => :competency_report
            get "manage" => "assessment_reports#manage", :as => :manage
            put "manage" => "assessment_reports#manage", :as => :manage
          end
        end
      end
    end

    resources :custom_assessments, :controller => "suitability/custom_assessments", :path => "tests", :except => [:destroy] do
      member do
        get "norms" => "suitability/custom_assessments#norms", :as => :norms
        put "norms" => "suitability/custom_assessments#norms", :as => :norms

        get "reports" => "suitability/custom_assessments/candidate_assessments#reports", :as => :reports

        get "competency_norms" => "suitability/custom_assessments#competency_norms", :as => :competency_norms
        put "competency_norms" => "suitability/custom_assessments#competency_norms", :as => :competency_norms
        get "competencies" => "suitability/custom_assessments#competencies", :as => :competencies
        put "competencies" => "suitability/custom_assessments#competencies", :as => :competencies

        get "styles" => "suitability/custom_assessments#styles", :as => :styles
        put "styles" => "suitability/custom_assessments#styles", :as => :styles

        get "enable_training_requirements_report" => "suitability/custom_assessments/training_requirements_reports#enable_training_requirements_report", :as => :enable_training_requirements_report

        get "download_training_requirements_report" => "suitability/custom_assessments/training_requirements_reports#download_report", :as => :download_training_requirements_report

        get "training_requirements" => "suitability/custom_assessments/training_requirements_reports#training_requirements", :as => :training_requirements
        get "training_requirements_report" => "assessment_reports#training_requirements_report", :as => :training_requirements_report

        get "candidates" => "suitability/custom_assessments/candidate_assessments#candidates", :as => :candidates
        get "candidates/add" => "suitability/custom_assessments/candidate_assessments#add_candidates", :as => :add_candidates
        put "candidates/add" => "suitability/custom_assessments/candidate_assessments#add_candidates", :as => :add_candidates

        put "candidates/bulk_upload" => "suitability/custom_assessments/candidate_assessments#bulk_upload", :as => :bulk_upload
        get "email_reports" => "suitability/custom_assessments/candidate_assessments#email_reports", :as => :email_reports

        get "candidates/send-test" => "suitability/custom_assessments/candidate_assessments#send_test_to_candidates", :as => :send_test_to_candidates
        put "candidates/send-test" => "suitability/custom_assessments/candidate_assessments#send_test_to_candidates", :as => :send_test_to_candidates
        put "candidates/bulk-send-test" => "suitability/custom_assessments/candidate_assessments#bulk_send_test_to_candidates", :as => :bulk_send_test_to_candidates
        get "candidates/:candidate_id/send-reminder" => "suitability/custom_assessments/candidate_assessments#send_reminder", :as => :send_reminder_to_candidate
        put "candidates/:candidate_id/send-reminder" => "suitability/custom_assessments/candidate_assessments#send_reminder", :as => :send_reminder_to_candidate
        get "candidates/:candidate_id" => "suitability/custom_assessments/candidate_assessments#candidate", :as => :candidate
      end
      
      resources :candidates, :except => [:destroy, :show] do
        resources :candidate_assessment_reports, :controller => :assessment_reports, :path => "reports", :only => [ :show ] do
          member do
            get "assessment_report" => "assessment_reports#assessment_report", :as => :assessment_report
            get "competency_report" => "assessment_reports#competency_report", :as => :competency_report
            get "manage" => "assessment_reports#manage", :as => :manage
            put "manage" => "assessment_reports#manage", :as => :manage
          end
        end
      end
    end
    
    resources :mrf_assessments, :controller => "mrf/assessments", :path => "360" do
      collection do
        get "home" => "mrf/assessments#home", :as => :home
        put "home" => "mrf/assessments#home", :as => :home
      end

      member do
        get "add_traits" => "mrf/assessments#add_traits", :as => :add_traits
        put "add_traits" => "mrf/assessments#add_traits", :as => :add_traits

        get "candidates" => "mrf/assessments#candidates", :as => :candidates

        get "details" => "mrf/assessments#details", :as => :details
        get "traits" => "mrf/assessments#traits", :as => :traits

        get ":candidate_id/statistics" => "mrf/assessments/candidate_feedback#statistics", :as => :candidate_statistics
        get ":candidate_id/stakeholders" => "mrf/assessments/candidate_feedback#stakeholders", :as => :candidate_stakeholders
        
        get "select_candidates" => "mrf/assessments/candidate_feedback#select_candidates", :as => :select_candidates
        put "select_candidates" => "mrf/assessments/candidate_feedback#select_candidates", :as => :select_candidates
        
        get "add_stakeholders" => "mrf/assessments/candidate_feedback#add_stakeholders", :as => :add_stakeholders
        put "add_stakeholders" => "mrf/assessments/candidate_feedback#add_stakeholders", :as => :add_stakeholders
        put "bulk_upload" => "mrf/assessments/candidate_feedback#bulk_upload", :as => :bulk_upload

      end
    end

    resources :jobs, :only => [:show, :index, :new] do
      collection do
        get :manage
        get :destroy_all
        post :import
        post 'import_from_google_drive'
        post 'export_to_google_drive'
      end
    end
  end

  resources :standard_assessments, :controller => "suitability/standard_assessments", :path => "standard-tests", :except => [:destroy] do
    member do
      get "norms" => "suitability/standard_assessments#norms", :as => :norms
      put "norms" => "suitability/standard_assessments#norms", :as => :norms

      get "reports" => "suitability/standard_assessments#reports", :as => :reports

      get "competency_norms" => "suitability/standard_assessments#competency_norms", :as => :competency_norms
      put "competency_norms" => "suitability/standard_assessments#competency_norms", :as => :competency_norms
      get "competencies" => "suitability/standard_assessments#competencies", :as => :competencies
      put "competencies" => "suitability/standard_assessments#competencies", :as => :competencies

      get "styles" => "suitability/standard_assessments#styles", :as => :styles
      put "styles" => "suitability/standard_assessments#styles", :as => :styles
    end
  end

  resources :account_managers, :only => [:index, :new] do
    collection do
      post :import
      get 'assign_jobs' => "account_managers#assign_jobs_form", :as => :assign_jobs_form
      post :assign_jobs
      get :manage
      get :destroy_all
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end

  resources :functional_areas, :only => [:index, :new] do
    collection do
      post :import
      get :manage
      get :destroy_all
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end

  resources :subscriptions, :only => [:index] do
    collection do
      post :expire_subscription, :as => :expire_subscription
      post :payment_status, :as => :payment_status
      post :import
      get :manage
      get :destroy_all
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end

  resources :plans, :only => [:index] do
    collection do
      post :import
      get :manage
      get :destroy_all
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end


  resources :locations, :only => [:index, :new] do
    collection do
      get :get_locations
      post :import
      get :manage
      get :destroy_all
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end

  resources :industries, :only => [:index, :new] do
    collection do
      post :import
      get :manage
      get :destroy_all
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end

  resources :degrees, :only => [:index, :new] do
    collection do
      post :import
      get :manage
      get :destroy_all
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end

  resources :job_experiences, :only => [:index, :new] do
    collection do
      post :import
      get :manage
      get :destroy_all
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end

  resources :locations, :only => [:index, :new] do
    collection do
      post :import
      get :manage
      get :destroy_all
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end
  
  namespace :mrf do
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
      end
      resources :options do
      end
    end
  end

  namespace :suitability do
    resources :item_groups do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
      end
    end

    resources :candidate_assessment_report_feedbacks do
      collection do
        get "thank-you" => "candidate_assessment_report_feedbacks#thank_you", :as => :thank_you_page
      end
    end

    resources :items do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post :export_to_google_drive
      end
      get 'add_option' => 'items#add_option'
      resources :options do
      end
    end

    resources :factor_norm_bucket_descriptions, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
        post 'import_via_s3'
      end
    end

    resources :default_factor_norm_ranges, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post 'import_via_s3'
        post 'export_to_google_drive'
      end
    end

    resources :fitment_grade_mappings, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :fitment_grades, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :fits, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :competencies do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :competency_grades, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :norm_buckets, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :consistency_buckets, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :overall_factor_score_buckets, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :aggregate_competency_score_buckets, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :pattern_response_buckets, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :overall_fitment_grades, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :post_assessment_guidelines, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
        post 'import_via_s3'
      end
    end

    resources :recommendations, :only => [:index] do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    resources :factors do
      collection do
        post :import
        get :manage
        get :destroy_all
        post :import_from_google_drive
        post 'export_to_google_drive'
      end
    end

    namespace :job do
      resources :factor_norms, :only => [ :index ] do
        collection do
          post :import
          get :edit
          get :manage
          get :destroy_all
          post 'import_via_s3'
          post 'export_to_google_drive'
        end
      end
    end
  end

  namespace :finance do
    resources :mutual_funds,:only => [:index] do
      collection do
        post :import
        get :manage
        get :destroy_all
        post 'import_from_google_drive'
        post 'export_to_google_drive'
      end
    end
  end

  match "/login", :to => "users#login", :as => :login
  match "/logout", :to => "users#logout", :via => [:get, :delete], :as => :logout

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

  get "/sidekiq/generate_factor_benchmarks" => "sidekiq#generate_factor_benchmarks"
  match "/sidekiq/upload_reports", :to => "sidekiq#upload_reports"
  match "/sidekiq/upload_benchmark_reports", :to => "sidekiq#upload_benchmark_reports"
  match "/sidekiq/upload_training_requirements_reports", :to => "sidekiq#upload_training_requirements_reports"
  match "/sidekiq/upload_training_requirement_groups_reports", :to => "sidekiq#upload_training_requirement_groups_reports"
  get "/sidekiq/regenerate_reports/", :to => "sidekiq#regenerate_reports", :as => :regenerate_reports
  put "/sidekiq/regenerate_reports/", :to => "sidekiq#regenerate_reports"

  get "/master-data", :to => "pages#home"
  get "/help/adding_candidates", :to => "help#adding_candidates", :as => :help_adding_candidates
  get "/help/process-explanation", :to => "help#process_explanation", :as => :help_process_explanation
  get "/download_sample_csv_for_candidate_bulk_upload", :to => "help#download_sample_csv_for_candidate_bulk_upload", :as => :download_sample_csv_for_candidate_bulk_upload
  get "/download_sample_csv_for_mrf_bulk_upload", :to => "help#download_sample_csv_for_mrf_bulk_upload", :as => :download_sample_csv_for_mrf_bulk_upload
  get "/report-management", :to => "pages#report_management", :as => :report_management
  put "/modify_norms", :to => "pages#modify_norms", :as => :modify_norms
  put "/manage_report", :to => "pages#manage_report", :as => :manage_report

  resources :global_configurations do
    collection do
      post :update_fallback_strategy
    end
  end

  match "/sign_up" => "signup#sign_up", :as => :sign_up
  root :to => "users#login"

  mount JombayNotify::Engine => "/jombay-notify"
end
