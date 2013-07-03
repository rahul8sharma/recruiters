Recruiters::Application.routes.draw do
  resources :companies, :only => [:index, :show] do
    member do
      get "settings" => "companies#settings", :as => :settings
      get "statistics" => "companies#statistics", :as => :statistics
      get "settings/company" => "companies#company", :as => :company_settings                        
      get "settings/account" => "companies#account", :as => :account_settings                 
      get "employees/send-test" => "candidates#send_test_to_employees", :as => :send_test_to_employees
    end
    
    resources :tests, :only => [:index, :show, :new] do
      collection do 
        
      end
      
      member do
        get "norm_criteria"
        get "norms"            
      end
    end
    
    resources :candidates, :only => [:index, :show] do
      collection do
        get "upload/bulk" => "candidates#upload_bulk", :as => :bulk_upload
        get "upload/single" => "candidates#upload_single", :as => :single_upload
        get "send-test" => "candidates#send_test_to_candidates", :as => :send_test_to_candidates
      end
      
      member do
        get "assessment/:assessment_id/report/:page" => "candidates#assessment_report", :as => :assessment_report
      end
    end
  end

  match "/login", :to => "users#login", :as => :login
	match "/logout", :to => "users#logout", :via => [:get, :delete], :as => :logout
	
  root :to => "pages#home"
end
