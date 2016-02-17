Rails.application.routes.draw do

  get 'events/:id/dashboard', to: 'events#dashboard', id: /\d+/, as: 'event_dashboard'
  get 'events/:id/pledge-breakdown', to: 'events#pledge_breakdown', id: /\d+/, as: 'event_pledge_breakdown'
  resources :events do
    resources :teams, only: [:new]
  end
  resources :teams, except: [:index] do
    resources :pledges, only: [:new]
  end
  resources :pledges, only: [:create]

  devise_for :users, :controllers => {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }, :skip => [:passwords]

  devise_scope :user do
    # Note: This view has not yet been created.
#    get "/users/:id", to: "users/registrations#show", as: 'show_user'

    # Password Reset support.
    get "/users/password/reset/new" => "users/password_resets#new"
    post "/users/password/reset" => "users/password_resets#create"
    get "/users/password/reset/edit" => "users/password_resets#edit"
    put "/users/password/reset" => "users/password_resets#update"
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get 'tour' => 'home#tour'
  get 'about' => 'home#about'

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Allows events to be accessed using custom key.
  get ':event_url_key' => 'events#show', as: 'show_event', constraints: ReservedUrlKeyConstraint.new


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
