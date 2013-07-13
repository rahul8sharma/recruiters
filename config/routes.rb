Recruiters::Application.routes.draw do
  resources :companies, :only => [:index, :show] do
    collection do
      post :import
  	  get :manage
  	  post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
    
    member do
      get "settings" => "companies#settings", :as => :settings
      get "statistics" => "companies#statistics", :as => :statistics
      get "settings/company" => "companies#company", :as => :company_settings                        
      get "settings/account" => "companies#account", :as => :account_settings
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
    	  post :import
    	  post 'import_from_google_drive'
        post 'export_to_google_drive' 
	    end
    end
    
    resources :assessments, :path => "tests", :except => [:destroy] do
      member do
        get "candidates" => "assessments#candidates", :as => :candidates
        get "norms" => "assessments#norms", :as => :norms
        put "norms" => "assessments#norms", :as => :norms
        get "styles" => "assessments#styles", :as => :styles
        put "styles" => "assessments#styles", :as => :styles
        get "candidates/add" => "assessments#add_candidates", :as => :add_candidates
        put "candidates/add" => "assessments#add_candidates", :as => :add_candidates
        get "candidates/send-test" => "assessments#send_test_to_candidates", :as => :send_test_to_candidates
        put "candidates/send-test" => "assessments#send_test_to_candidates", :as => :send_test_to_candidates
        get "candidates/:candidate_id/send-reminder" => "assessments#send_reminder", :as => :send_reminder_to_candidate
        put "candidates/:candidate_id/send-reminder" => "assessments#send_reminder", :as => :send_reminder_to_candidate
        get "candidates/:candidate_id" => "assessments#candidate", :as => :candidate
        
        [*1..6].each do |page|
          get "candidates/:candidate_id/report/page#{page}" => "assessment_reports#page#{page}", :as => "page#{page}_assessment_report"
        end
      end
      
      resources :candidates, :except => [:destroy, :show] do
        collection do
          get "upload/bulk" => "candidates#upload_bulk", :as => :bulk_upload
          get "upload/single" => "candidates#upload_single", :as => :single_upload
          get 'manage'
          post 'import'
          post 'import_from_google_drive'
          post 'export_to_google_drive'
        end
      end
    end
    
    resources :jobs, :only => [:show, :index, :new] do
    	collection do
    	  get :manage
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
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end

  resources :functional_areas, :only => [:index, :new] do
	  collection do 
	    post :import 
      get 'manage'
      post 'import_from_google_drive'
      post 'export_to_google_drive'
	  end
  end
  
  resources :locations, :only => [:index, :new] do
	  collection do
	    post :import 
	    get 'manage'
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end

  resources :industries, :only => [:index, :new] do
	  collection do
	    post :import 
	    get 'manage'
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end

  resources :job_experiences, :only => [:index, :new] do
	  collection do
	    post :import 
	    get 'manage'
      post 'import_from_google_drive'
      post 'export_to_google_drive'
    end
  end
  
  namespace :suitability do
    resources :item_groups do
		  collection do
		    get :manage
		    post :import_from_google_drive
	    end
	  end
	  
	  resources :items, :only => [:index, :new, :show] do
	  end
	
	  resources :factor_norm_bucket_descriptions, :only => [:index] do
		  collection do
		    get :manage
		    post :import_from_google_drive
		    post 'export_to_google_drive'
		  end
  	end   
  	
  	resources :default_factor_norm_ranges, :only => [:index] do
		  collection do
		    get :manage
		    post :import_from_google_drive
		    post 'export_to_google_drive'
		  end
  	end   
  	
  	resources :fitment_grade_mappings, :only => [:index] do
		  collection do
		    get :manage
		    post :import_from_google_drive
		    post 'export_to_google_drive'
		  end
  	end   
  	
  	resources :fitment_grades, :only => [:index] do
		  collection do
		    get :manage
		    post :import_from_google_drive
		    post 'export_to_google_drive'
		  end
  	end  
  	
  	resources :fits, :only => [:index] do
		  collection do
		    get :manage
		    post :import_from_google_drive
		    post 'export_to_google_drive'
		  end
  	end   
  	
  	resources :norm_buckets, :only => [:index] do
		  collection do
		    get :manage
		    post :import_from_google_drive
		    post 'export_to_google_drive'
		  end
  	end   
  	
  	resources :overall_fitment_grades, :only => [:index] do
		  collection do
		    get :manage
		    post :import_from_google_drive
		    post 'export_to_google_drive'
		  end
  	end   
  	
  	resources :post_assessment_guidelines, :only => [:index] do
		  collection do
		    get :manage
		    post :import_from_google_drive
		    post 'export_to_google_drive'
		  end
  	end   
  	
  	resources :recommendations, :only => [:index] do
		  collection do
		    get :manage
		    post :import_from_google_drive
		    post 'export_to_google_drive'
		  end
  	end   
	
    resources :factors, :only => [:index, :new, :show] do
		  resources :items do
			  get 'add_option' => 'items#add_option'
			  resources :options do
			  end
		  end
		  collection do
		    post :import 
		    get :manage
		    post :import_from_google_drive
		    post 'export_to_google_drive'
		  end
  	end
  	
  	namespace :job do
      resources :factor_norms, :only => [ :index ] do
        collection do
          post :import
          get :edit
          get 'manage'
          post 'import_from_google_drive'
          post 'export_to_google_drive'
        end
      end
    end
  end

  match "/login", :to => "users#login", :as => :login
  match "/users/password/edit", :to => "users#reset_password", :as => :reset_password
  match "/users/password/new", :to => "users#forgot_password", :as => :forgot_password
	match "/logout", :to => "users#logout", :via => [:get, :delete], :as => :logout
	
  root :to => "pages#home"
end
