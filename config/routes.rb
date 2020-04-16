Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/explorer', to: 'bitcoin_app#explorer'
  get '/tx/:id', to: 'bitcoin_app#txinfo', as: 'txinfo'
  get '/block/:id', to: 'bitcoin_app#blockinfo', as: 'blockinfo'
  get '/address/:id', to: 'bitcoin_app#addressinfo', as: 'addressinfo'
  get '/mining', to: 'bitcoin_app#mining'
  get '/sendings', to: 'bitcoin_app#sendings'
  post '/sent', to: 'bitcoin_app#sent'
  get '/search', to: 'bitcoin_app#search'
  get '/notfound', to: 'bitcoin_app#notfound'
  get '/getnewaddress', to: 'bitcoin_app#getnewaddress'
  get '/wallet', to: 'bitcoin_app#wallet'
  get '/txlist', to: 'bitcoin_app#txlist'
  get '/keys', to: 'bitcoin_app#keys'
end
