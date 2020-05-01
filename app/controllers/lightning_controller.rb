require 'lightning'

class LightningController < ApplicationController
  
  def lightning
    # initialize RPC interface using unix socket file.
    rpc = Lightning::RPC.new('/Users/skobuchi/.lightning/testnet/lightning-rpc')
    @getinfo = rpc.getinfo

    @listpeers = rpc.listpeers
    logger.debug @listpeers
    logger.debug @listpeers['peers'][0]
    @listfunds = rpc.listfunds
    logger.debug @listfunds
    @listnodes = rpc.listnodes
    logger.debug @listnodes
    render template: 'lightning/lightning'
  end
end
