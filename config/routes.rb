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
        get :show
        get :preview, :path => "preview"
        get :traversable_from
        put :update_status
      end
      collection do
        # get :show, :path => ":status/:id", :as => "_show"
        get :status, :path => ":status"
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
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
