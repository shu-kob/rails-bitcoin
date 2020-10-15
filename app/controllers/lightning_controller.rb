require 'lightning'
require 'rqrcode'

class LightningController < ApplicationController
  
  def lightning
    @message = params[:message]
    @getinfo = rpc.getinfo
    @listpeers = rpc.listpeers
    @listfunds = rpc.listfunds
    @listnodes = rpc.listnodes
    @nodeinfo = []

    @list_start_id = 0

    @listfunds = rpc.listfunds

    if @getinfo['address'][0]
      address = "@" + @getinfo['address'][0]['address'].to_s + ":" + @getinfo['address'][0]['port'].to_s
      @uri = @getinfo['id'] + address
    else
      @uri = @getinfo['id']
    end

    for i in 0..@listpeers['peers'].length-1
      @nodeinfo.push(rpc.listnodes(@listpeers['peers'][i]['id']))
    end

    qrcode = RQRCode::QRCode.new(@uri, :size => 10, :level => :h)
    @qrcode = qrcode.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true
    )

    render template: 'lightning/lightning'
  end

  def ping
    id = params[:id]
    begin
      Timeout.timeout(3) do
        @connect = rpc.ping(id)
        @message = "Ping success"
        return @message
      end
    rescue Lightning::RPCError
      @message = "Ping RPCError"
      return @message
    rescue Timeout::Error
      @message = "Ping timeout"
      return @message
    ensure
      redirect_to lightning_path(@message)
    end
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
    begin
      @receipt = rpc.pay(invoice)
    rescue Lightning::RPCError
      @receipt = "RPCError"
    end
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
    qrcode = RQRCode::QRCode.new(@uri, :size => 20, :level => :h)
    @qrcode = qrcode.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true
    )
    render template: 'lightning/invoice'
  end

  def listinvoices
    @listinvoices = rpc.listinvoices
    render template: 'lightning/listinvoices'
  end

  def deposit

    @address = rpc.newaddr["address"]
    amount = params[:amount].to_s
    if amount != ""
      @uri = "bitcoin:" + @address + "?amount=" + amount
    else
      @uri = "bitcoin:" + @address
    end

    qrcode = RQRCode::QRCode.new(@uri, :size => 10, :level => :h)
    @qrcode = qrcode.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true
    )
    render template: 'lightning/deposit'
  end

  def close
    channnel = params[:id]
    begin
      Timeout.timeout(3) do
        @close = rpc.close(channnel)
        @message = "close success"
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

  def withdraw
    address = params[:address]
    begin
      Timeout.timeout(3) do
        tx = rpc.withdraw(address, "all")
        logger.debug tx
        redirect_to txinfo_path(tx["txid"])
      end
    rescue Lightning::RPCError
      @message = "RPCError"
      redirect_to lightning_path(@message)
      return @message
    rescue Timeout::Error
      @message = "timeout"
      return @message
      redirect_to lightning_path(@message)
    end
  end

  def listchannels
    @listchannels = rpc.listchannels
    render template: 'lightning/listchannels'
  end

  private
  def rpc
    rpc = Lightning::RPC.new('/Users/skobuchi/.lightning/signet/lightning-rpc')
    return rpc
  end
end
