Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/submission/:id', to: 'submission#show'
  post '/submission', to: 'submission#create'

  namespace :save_return do
    resources :email_confirmations
  end
end
