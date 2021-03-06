Rails.application.routes.draw do
  concern :versioned do
    resources :versions, except: %i(new create edit update destroy)
  end

  root to: 'paths#sitepath', via: :get, url: '/'

  # USERS
  get 'signup' => 'users#new', as: :signup
  post 'signup' => 'users#create'
  get 'account/confirm/:confirmation_code' => 'users#confirm', as: :confirm_account
  resource :account, controller: 'users', except: %i(index new create destroy)
  get 'profile/:id' => 'users#profile', as: :profile
  # SESSIONS
  get 'signin' => 'sessions#new', as: :signin
  post 'signin' => 'sessions#create'
  get 'signout' => 'sessions#delete', as: :signout
  delete 'signout' => 'sessions#destroy'
  # OAUTH
  match 'auth/:provider/callback' => 'sessions#oauth_callback', via: %i(get post)
  # AUTHORITIES
  resources :authorities
  # SETTINGS
  resources :settings do
    collection { get 'initialize_defaults' }
  end

  # CONTENT
  resources :paths
  resources :pages, concerns: :versioned
  resources :documents
  get 'download/:id/*filename' => 'documents#download', as: :download
  resources :events, concerns: :versioned do
    member do
      get 'approve'
      post 'approve' => 'events#set_approved'
      get 'merge'
      post 'merge' => 'events#perform_merge'
      post 'update_tags'
    end
    resources :external_links
  end
  resources :images
  resources :sources do
    member do
      get 'processor'
      post 'processor' => 'sources#runprocessor'
    end
  end
  get 'tags' => 'tags#index'
  get 'tags/:tag' => 'tags#tag'

  # PROJECTS
  resources :projects
  get 'project/*projecturl' => 'projects#show', as: :project_name, format: false

  # Calendar
  month_regexp = /0[1-9]|1[0-2]/
  year_regexp = /\d{4}/
  get 'calendar' => 'calendar#index', as: :calendar
  get 'calendar/subscribe' => 'calendar#subscribe', as: :calendar_subscribe
  get 'calendar/:year/:month/:day' => 'calendar#day', as: :calendar_day,
      constraints: { year: year_regexp, month: month_regexp, day: /0[1-9]|[1-3]\d/ }
  get 'calendar/:year/:month' => 'calendar#month', as: :calendar_month,
      constraints: { year: year_regexp, month: month_regexp }
  get 'calendar/:year' => 'calendar#year', as: :calendar_year,
      constraints: { year: year_regexp }

  get '*url' => 'paths#sitepath', format: false
end
