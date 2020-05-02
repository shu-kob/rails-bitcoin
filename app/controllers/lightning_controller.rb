require 'lightning'
require 'rqrcode'
require 'rqrcode_png'

class LightningController < ApplicationController
  
  def lightning
    @getinfo = rpc.getinfo
    @listpeers = rpc.listpeers
    @listfunds = rpc.listfunds
    @listnodes = rpc.listnodes

    @num_per_page = 25;
    @list_start_id = 0;

    logger.debug @getinfo['address']
    logger.debug @getinfo['address'][0]['address']

    @uri = @getinfo['id'] + "@" + @getinfo['address'][0]['address'].to_s + ":" + @getinfo['address'][0]['port'].to_s

    qr = RQRCode::QRCode.new(@uri, :size => 10, :level => :h)
    png = qr.to_img
    @qrcode = png.resize(300, 300).to_data_url

    render template: 'lightning/lightning'
  end

  def connect
    id = params[:id]
    logger.debug id

    begin
      Timeout.timeout(10) do # 10秒でタイムアウト
        if @connect = rpc.connect(id)
          redirect_to lightning_path
        else
          render template: 'bitcoin_app/notfound'
        end    
      end
    rescue Timeout::Error
      redirect_to lightning_path   # タイムアウト発生時の処理
    end

  end

  def fundchannel
  end

  def pay

  end

  def paid
    invoice = params[:pay]['invoice']
    @receipt = rpc.pay(invoice)
    render template: 'lightning/receipt'
  end

  def listsendpays
    @listsendpays = rpc.listsendpays
    render template: 'lightning/listsendpays'
  end

  def issue_invoice

  end

  def invoice
    msatoshi = params[:issue]['msatoshi'].to_i
    label = params[:issue]['label']
    description = params[:issue]['description']
    @invoice = rpc.invoice(msatoshi, label, description)
    @uri = @invoice['bolt11']
    qr = RQRCode::QRCode.new(@uri)
    png = qr.to_img
    @qrcode = png.resize(500, 500).to_data_url
    render template: 'lightning/invoice'
  end

  private
  def rpc
    rpc = Lightning::RPC.new('/Users/skobuchi/.lightning/testnet/lightning-rpc')
    return rpc
  end
end
