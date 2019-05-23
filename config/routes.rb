Rails.application.routes.draw do
  if Rails.env.development?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  get '/submission/:id', to: 'submission#show'
  post '/submission', to: 'submission#create'

  post '/email', to: 'email#create'
  post '/sms', to: 'sms#create'
end
