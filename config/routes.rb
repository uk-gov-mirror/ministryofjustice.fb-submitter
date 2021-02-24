Rails.application.routes.draw do
  get '/health', to: 'health#show'
  post '/submission', to: 'submission#create'

  namespace 'v2' do
    resources :submissions, only: :create
  end

  post '/email', to: 'email#create'
  post '/sms', to: 'sms#create'

  resource :metrics, only: [:show]
end
