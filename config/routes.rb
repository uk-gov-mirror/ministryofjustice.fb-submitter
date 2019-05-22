Rails.application.routes.draw do
  get '/submission/:id', to: 'submission#show'
  post '/submission', to: 'submission#create'

  post '/email', to: 'email#create'
  post '/sms', to: 'sms#create'
end
