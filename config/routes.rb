Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/mining', to: 'bitcoin_app#mining'
  get '/explorer', to: 'bitcoin_app#explorer'
  get '/tx/:id', to: 'bitcoin_app#txinfo', as: 'txinfo'
  get '/block/:id', to: 'bitcoin_app#blockinfo', as: 'blockinfo'
  get '/sendings', to: 'bitcoin_app#sendings'
  post '/sent', to: 'bitcoin_app#sent'
  get '/search', to: 'bitcoin_app#search'
  get '/keys', to: 'bitcoin_app#keys'
  get '/notfound', to: 'bitcoin_app#notfound'
  get '/getnewaddress', to: 'bitcoin_app#getnewaddress'
  get '/wallet', to: 'bitcoin_app#wallet'
end
