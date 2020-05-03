require 'lightning'
require 'rqrcode'
require 'rqrcode_png'

class LightningController < ApplicationController
  
  def lightning
    @message = params[:message]
    @getinfo = rpc.getinfo
    @listpeers = rpc.listpeers
    @listfunds = rpc.listfunds
    @listnodes = rpc.listnodes
    @nodeinfo= []
    @ping= []

    @num_per_page = 500;
    @list_start_id = 0;

    if @getinfo['address'][0]
      address = "@" + @getinfo['address'][0]['address'].to_s + ":" + @getinfo['address'][0]['port'].to_s
      @uri = @getinfo['id'] + address
    else
      @uri = @getinfo['id']
    end

    for i in 0..@listpeers['peers'].length-1
      @nodeinfo.push(rpc.listnodes(@listpeers['peers'][i]['id']))
    end

    for j in 0..@listnodes['nodes'].length-1
      begin
        rpc_ping = rpc.ping(@listnodes['nodes'][j]['nodeid'])
        ping = "OK"
      rescue Lightning::RPCError
        ping = "NO"
      ensure
        @ping.push(ping)
      end
    end

    qr = RQRCode::QRCode.new(@uri, :size => 10, :level => :h)
    png = qr.to_img
    @qrcode = png.resize(300, 300).to_data_url

    render template: 'lightning/lightning'
  end

  def connect
    id = params[:id]
    begin
      Timeout.timeout(3) do
        @connect = rpc.connect(id)
        @message = "connect success"
        return @message
      end
    rescue Lightning::RPCError
      @message = "RPCError"
      return @message
    rescue Timeout::Error
      @message = "timeout"
      return @message
    ensure
      redirect_to lightning_path(@message)
    end

  end

  def fundchannel
    id = params[:id]
    amount = params[:amount]
    logger.debug id
    logger.debug amount
    begin
      Timeout.timeout(3) do
        @fundchannel = rpc.fundchannel(id, amount)
        @message = "fundchannel success"
        return @message
      end
    rescue Lightning::RPCError
      @message = "RPCError"
      return @message
    rescue Timeout::Error
      @message = "timeout"
      return @message
    ensure
      redirect_to lightning_path(@message)
    end
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
