require 'lightning'
require 'rqrcode'
require 'rqrcode_png'

class LightningController < ApplicationController
  
  def lightning
    @getinfo = rpc.getinfo
    @listpeers = rpc.listpeers
    @listfunds = rpc.listfunds
    @listnodes = rpc.listnodes

    logger.debug @getinfo['address']
    logger.debug @getinfo['address'][0]['address']

    @uri = @getinfo['id'] + "@" + @getinfo['address'][0]['address'].to_s + ":" + @getinfo['address'][0]['port'].to_s

    qr = RQRCode::QRCode.new(@uri, :size => 10, :level => :h)
    png = qr.to_img
    @qrcode = png.resize(300, 300).to_data_url

    render template: 'lightning/lightning'
  end

  def pay

  end

  def paid
    invoice = params[:pay]['invoice']
    @receipt = rpc.pay(invoice)
    render template: 'lightning/receipt'
  end

  private
  def rpc
    rpc = Lightning::RPC.new('/Users/skobuchi/.lightning/testnet/lightning-rpc')
    return rpc
  end
end
