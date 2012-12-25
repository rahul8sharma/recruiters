Recruiters::Application.routes.draw do
  
  devise_for :users, :controllers => {
    :registrations => "recruiters/users/registrations",
    :sessions => "recruiters/users/sessions",
    :passwords => "recruiters/users/passwords"
  }

  resources :users
  
  namespace :recruiters, :path => '' do
    # root :to => 'landing#index', :as => :root
    root :to => proc { |env|
      user = env["rack.session"]["yoren_user"]
      if user.blank?
        controller = Recruiters::LandingController
        controller.action("index").call(env)
      else
        controller = Recruiters::DashboardController
        controller.action("dashboard").call(env)
      end
    }
    
    resources :jobs, :only => [] do
      member do
        get :flush
        get :show
        get :preview, :path => "preview"
        get :traversable_from
        put :update_status
      end
      
      collection do
        # get :show, :path => ":status/:id", :as => "_show"
        get :status, :path => "status/:status"
        get :edit, :path => ":id/edit/:section"
        put :update, :path => ":id/edit/:section"
      end

      resources :candidates, :only => [:index, :show]
    end

    resources :company_profiles, :path => "company-profiles" do
      collection do
        post :create_new
      end
    end

    resources :dashboard, :only => [] do
      collection do
        put :job_posting, :path => "job_posting"
      end
    end

  end  
end
