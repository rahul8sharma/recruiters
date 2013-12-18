Recruiters::Application.routes.draw do
  resources :candidates do
    collection do 
      get "manage" => "candidates#manage", :as => :manage
      post 'export'
      post 'import'
      post 'export_validation_progress'
      post 'export_candidate_responses'
      post 'export_candidate_reports'
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
    end

    member do
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

    resources :assessments, :path => "tests", :except => [:destroy] do
      member do
        get "norms" => "assessments#norms", :as => :norms
        put "norms" => "assessments#norms", :as => :norms

        get "competency_norms" => "assessments#competency_norms", :as => :competency_norms
        put "competency_norms" => "assessments#competency_norms", :as => :competency_norms
        get "competencies" => "assessments#competencies", :as => :competencies
        put "competencies" => "assessments#competencies", :as => :competencies                    

        get "styles" => "assessments#styles", :as => :styles
        put "styles" => "assessments#styles", :as => :styles
        
        get "candidates" => "candidate_assessments#candidates", :as => :candidates
        get "candidates/add" => "candidate_assessments#add_candidates", :as => :add_candidates
        put "candidates/add" => "candidate_assessments#add_candidates", :as => :add_candidates

        put "candidates/bulk_upload" => "candidate_assessments#bulk_upload", :as => :bulk_upload
        get "email_reports" => "candidate_assessments#email_reports", :as => :email_reports

        get "candidates/send-test" => "candidate_assessments#send_test_to_candidates", :as => :send_test_to_candidates
        put "candidates/send-test" => "candidate_assessments#send_test_to_candidates", :as => :send_test_to_candidates
        put "candidates/bulk-send-test" => "candidate_assessments#bulk_send_test_to_candidates", :as => :bulk_send_test_to_candidates
        get "candidates/:candidate_id/send-reminder" => "candidate_assessments#send_reminder", :as => :send_reminder_to_candidate
        put "candidates/:candidate_id/send-reminder" => "candidate_assessments#send_reminder", :as => :send_reminder_to_candidate
        get "candidates/:candidate_id" => "candidate_assessments#candidate", :as => :candidate
      end

      resources :candidates, :except => [:destroy, :show] do
        collection do
          get "upload/bulk" => "candidates#upload_bulk", :as => :bulk_upload
          get "upload/single" => "candidates#upload_single", :as => :single_upload
        end
        
        resources :candidate_assessment_reports, :controller => :assessment_reports, :path => "reports", :only => [ :show ] do
          member do
            get "assessment_report" => "assessment_reports#assessment_report", :as => :assessment_report
            get "competency_report" => "assessment_reports#competency_report", :as => :competency_report
            get "benchmark_report" => "assessment_reports#benchmark_report", :as => :benchmark_report
            get "manage" => "assessment_reports#manage", :as => :manage
            put "manage" => "assessment_reports#manage", :as => :manage
          end
        end
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

  namespace :suitability do
    resources :item_groups do
      collection do
        get :manage
        get :destroy_all
        post :import_from_google_drive
      end
    end

    resources :items do
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
    
    resources :competencies, :only => [:index] do
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

    resources :factors, :only => [:index, :new, :show] do
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

  match "/login", :to => "users#login", :as => :login
  match "/logout", :to => "users#logout", :via => [:get, :delete], :as => :logout
  
  get "/users/password/edit", :to => "users#reset_password", :as => :reset_password
  put "/users/password/edit", :to => "users#update_password", :as => :update_password
  
  get "/users/password/new", :to => "users#forgot_password", :as => :forgot_password
  post "/users/password/create", :to => "users#send_reset_password", :as => :send_reset_password
  
  get "/users/activate", :to => "users#activate", :as => :activate_account
  put "/users/activate", :to => "users#activate"
  
  get "/users/password_settings" => "users#password_settings", :as => :password_settings
  put "/users/update_password_settings" => "users#update_password_settings", :as => :update_password_settings

  
  match "/sidekiq/upload_reports", :to => "sidekiq#upload_reports"
  get "/sidekiq/regenerate_reports/", :to => "sidekiq#regenerate_reports", :as => :regenerate_reports
  put "/sidekiq/regenerate_reports/", :to => "sidekiq#regenerate_reports"
  
  get "/master-data", :to => "pages#home"
  get "/help/adding_candidates", :to => "help#adding_candidates", :as => :help_adding_candidates
  get "/download_sample_csv_for_candidate_bulk_upload", :to => "help#download_sample_csv_for_candidate_bulk_upload", :as => :download_sample_csv_for_candidate_bulk_upload
  get "/report-management", :to => "pages#report_management", :as => :report_management
  put "/modify_norms", :to => "pages#modify_norms", :as => :modify_norms
  put "/manage_report", :to => "pages#manage_report", :as => :manage_report
  
  root :to => "users#login"
  
  mount JombayNotify::Engine => "/jombay-notify"
end
