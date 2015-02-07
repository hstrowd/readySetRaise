Rails.application.routes.draw do

  resources :organizations do
    resources :fundraisers, only: [:new]
  end
  resources :fundraisers, except: [:new] do
    resources :events, only: [:new]
  end

  get 'event/:id/dashboard', to: 'events#dashboard', id: /\d/, as: 'event_dashboard'
  resources :events, except: [:index] do
    resources :teams, only: [:new]
  end
  resources :teams, except: [:index] do
    resources :pledges, only: [:new]
  end
  resources :pledges, only: [:new, :create, :show]

  devise_for :users, :controllers => { registrations: 'users/registrations' },
                     :skip => [:passwords]

  devise_scope :user do
    get "/users/:id", to: "users/registrations#show", as: 'show_user'

    # Password Reset support.
    get "/users/password/reset/new" => "users/password_resets#new"
    post "/users/password/reset" => "users/password_resets#create"
    get "/users/password/reset/edit" => "users/password_resets#edit"
    put "/users/password/reset" => "users/password_resets#update"

    # Password changes for logged in users.
    get "/users/password/change/new" => "users/password_changes#edit_password"
    post "/users/password/change" => "users/password_changes#update_password"
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # Allows organizations to be looked up by key.
  get 'orgs/:url_key' => 'organizations#show', as: 'show_org'

  get 'about' => 'home#about'

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
