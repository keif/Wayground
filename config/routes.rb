Wayground::Application.routes.draw do
  # USERS
  get "signup" => "users#new", :as => :signup
  post "signup" => "users#create"
  get "account/confirm/:confirmation_code" => "users#confirm", :as => :confirm_account
  resource :account, :controller => 'users', :except => [:index, :new, :create, :destroy]
  get 'profile/:id' => 'users#profile', :as => :profile
  # SESSIONS
  get "signin" => "sessions#new", :as => :signin
  post "signin" => "sessions#create"
  get "signout" => "sessions#delete", :as => :signout
  delete "signout" => "sessions#destroy"
  # OAUTH
  match "auth/:provider/callback" => "sessions#oauth_callback"
  # AUTHORITIES
  resources :authorities do
    get 'delete', :on => :member
  end

  # CONTENT
  resources :paths do
    get 'delete', :on => :member
  end
  resources :pages do
    get 'delete', :on => :member
    delete 'delete' => 'pages#destroy', :on => :member
    resources :versions, :except => [:new, :create, :edit, :update, :destroy]
  end
  resources :documents do
    get 'delete', :on => :member
    delete 'delete' => 'documents#destroy', :on => :member
  end
  get 'download/:id/*filename' => 'documents#download', :as => :download

  root :to => "paths#sitepath", :via => :get, :defaults => { :url => '/' }
  get '*url' => "paths#sitepath"
end
