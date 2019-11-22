Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/mining', to: 'bitcoin_app#mining'
  get '/explorer', to: 'bitcoin_app#explorer'
  get '/tx/:id', to: 'bitcoin_app#txinfo', as: 'txinfo'
  get '/block/:id', to: 'bitcoin_app#blockinfo', as: 'blockinfo'
  get '/sendings', to: 'bitcoin_app#sendings'
  get 'sent', to: 'bitcoin_app#sent'
  post '/sent', to: 'bitcoin_app#sent'
  get '/keys', to: 'bitcoin_app#keys'
end
