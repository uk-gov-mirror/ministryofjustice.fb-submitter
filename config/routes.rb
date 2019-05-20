Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/submission/:id', to: 'submission#show'
  post '/submission', to: 'submission#create'

  namespace :save_return do
    resources :email_confirmations, only: [:create]
    resources :email_magic_links, only: [:create]
    resources :email_progress_saved, only: [:create]
  end
end
