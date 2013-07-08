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
      get "candidates/:candidate_id" => "candidates#show", :as => :candidate                                  
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
      resources :candidates, :except => [:destroy, :show] do
        collection do
          get "add" => "candidates#add", :as => :add
          get "upload/bulk" => "candidates#upload_bulk", :as => :bulk_upload
          get "upload/single" => "candidates#upload_single", :as => :single_upload
          get "send-test" => "candidates#send_test_to_candidates", :as => :send_test_to_candidates
          get 'manage'
          post 'import'
          post 'import_from_google_drive'
          post 'export_to_google_drive'
        end
        
        member do
          get "report/:page" => "candidates#assessment_report", :as => :assessment_report
          get "send_reminder" => "candidates#send_reminder", :as => :send_reminder
        end
      end
      
      
      member do
        get "employees/send-test" => "candidates#send_test_to_employees", :as => :send_test_to_employees
        get "norms" => "assessments#norms", :as => :norms
        get "styles" => "assessments#styles", :as => :styles
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
	match "/logout", :to => "users#logout", :via => [:get, :delete], :as => :logout
	
  root :to => "pages#home"
end
