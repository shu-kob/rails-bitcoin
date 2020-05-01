require 'lightning'

class LightningController < ApplicationController
  
  def lightning
    # initialize RPC interface using unix socket file.
    rpc = Lightning::RPC.new('/Users/skobuchi/.lightning/testnet/lightning-rpc')
    @getinfo = rpc.getinfo

    @listpeers = rpc.listpeers
    @listfunds = rpc.listfunds
    @listnodes = rpc.listnodes
    render template: 'lightning/lightning'
  end
end
