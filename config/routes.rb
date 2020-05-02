Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/', to: 'bitcoin_app#index'
  get '/index', to: 'bitcoin_app#index'
  get '/index/:blockheight/:blocknum', to: 'bitcoin_app#index', as: 'pagenation'
  get '/tx/:txid', to: 'bitcoin_app#txinfo', as: 'txinfo'
  get '/block/:blockhash', to: 'bitcoin_app#blockinfo', as: 'blockinfo'
  get '/address/:address', to: 'bitcoin_app#addressinfo', as: 'addressinfo'
  get '/mining', to: 'bitcoin_app#mining'
  post '/mine', to: 'bitcoin_app#mine'
  get '/mine', to: 'bitcoin_app#mine'
  get '/sendings', to: 'bitcoin_app#sendings'
  post '/sent', to: 'bitcoin_app#sent'
  get '/search', to: 'bitcoin_app#search'
  get '/notfound', to: 'bitcoin_app#notfound'
  get '/receive', to: 'bitcoin_app#receive'
  post '/receive', to: 'bitcoin_app#receive'
  get '/addresslist', to: 'bitcoin_app#addresslist'
  get '/txlist', to: 'bitcoin_app#txlist'
  get '/keys', to: 'bitcoin_app#keys'
  get 'lightning', to: 'lightning#lightning'
  get 'lightning/pay', to: 'lightning#pay', as: 'pay'
  post 'lightning/paid', to: 'lightning#paid'
  get 'lightning/listsendpays', to: 'lightning#listsendpays', as: 'listsendpays'
  get 'lightning/issue_invoice', to: 'lightning#issue_invoice', as: 'issue_invoice'
  post 'lightning/invoice', to: 'lightning#invoice', as: 'invoice'
  post 'lightning/connect', to: 'lightning#connect', as: 'connect'
end
