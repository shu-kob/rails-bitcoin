require 'bitcoin'
require 'net/http'
require 'json'
Bitcoin.chain_params = :regtest
RPCUSER="hoge"
RPCPASSWORD="hoge"
HOST="localhost"
PORT=18443
require 'rqrcode'
require 'rqrcode_png'

class BitcoinAppController < ApplicationController
  def index
    if params[:id]
      blockheightnum = params[:id].to_i
    end
    if params[:num]
      num = params[:num].to_i
    else
      num = 25
    end
    @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
    @blockheight = @blockchaininfo['blocks']
    if (blockheightnum) && (blockheightnum < @blockheight)
      i = blockheightnum
    else
      i = @blockheight
    end

    if i >= num - 1
      @num = 25
    elsif i < num - 1 && @blockheight >= num
      @num = num
      i = num - 1
    else
      @num = i
    end
		
    @height_num  = i - @num
    blockhash = []
    blockinfo = []
		j = 0
		
    if i == 0
    	@blockhash = blockhash.push(bitcoinRPC('getblockhash',[i]))
      @blockinfo = blockinfo.push(bitcoinRPC('getblock',[@blockhash[j]]))
		else
      while i > @height_num do
        @blockhash = blockhash.push(bitcoinRPC('getblockhash',[i]))
        @blockinfo = blockinfo.push(bitcoinRPC('getblock',[@blockhash[j]]))
        i = i - 1
        j = j + 1
      end
    end
		
    render template: 'bitcoin_app/index'
  end

  def txlist
    mempoolinfo = bitcoinRPC('getrawmempool',[])
    confirmation_num = []
    @txlist = []
		for n in 0..mempoolinfo.length-1
      unconfirmedrawtx = bitcoinRPC('getrawtransaction',[mempoolinfo[n]])
      decodedunconfirmedtxinfo = bitcoinRPC('decoderawtransaction',[unconfirmedrawtx])
      unconf_value = 0
      for u in 0..decodedunconfirmedtxinfo['vout'].length-1
        unconf_value = unconf_value + decodedunconfirmedtxinfo['vout'][u]['value']
      end
      @unconftx = []
      @unconftx.push(decodedunconfirmedtxinfo, unconf_value, 0, -1, -1)
      @txlist.push(@unconftx)
		end
    @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
    current_height = @blockchaininfo['blocks']
		for p in 0..current_height-1
			blockhash = bitcoinRPC('getblockhash',[current_height - p])
      @blockinfo = bitcoinRPC('getblock',[blockhash])
      for s in 0..@blockinfo['tx'].length-1 
        confirmedrawtx = bitcoinRPC('getrawtransaction',[@blockinfo['tx'][s]])
        @decodedtxinfo = bitcoinRPC('decoderawtransaction',[confirmedrawtx])
        value = 0
        for t in 0..@decodedtxinfo['vout'].length-1
          value = value + @decodedtxinfo['vout'][t]['value']
        end

        @conftx = []
        @conftx.push(@decodedtxinfo, value, @blockinfo)
        @txlist.push(@conftx)
      end
    end
    zero_blockhash = bitcoinRPC('getblockhash',[0])
    @decode_zero_blockhash = bitcoinRPC('getblock', [zero_blockhash])
    render template: 'bitcoin_app/txlist'
  end

  def txinfo
    @txid = params[:id]
    @txinfo = gettxinfo(@txid)

    mempoolinfo = bitcoinRPC('getrawmempool',[])
    for w in 0..mempoolinfo.length
      if mempoolinfo[w] == @txid
        @in_mempool = true
      else
        @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
        for i in 0..@blockchaininfo['blocks']
          blockhash = bitcoinRPC('getblockhash', [@blockchaininfo['blocks'] - i])
          blockinfo = bitcoinRPC('getblock', [blockhash])
          for v in 0..blockinfo['tx'].length - 1
            if blockinfo['tx'][v] == @txid
              @confirm_block = blockinfo
            end
          end
        end
      end
    end

    zero_blockhash = bitcoinRPC('getblockhash',[0])
    @decode_zero_blockhash = bitcoinRPC('getblock', [zero_blockhash])

    render template: 'bitcoin_app/txinfo'
  end

  def gettxinfo(txid)
		rawtx = bitcoinRPC('getrawtransaction',[txid])
    if rawtx
      txinfo = bitcoinRPC('decoderawtransaction',[rawtx])
      vin_allinfos = []
      spentflags = []
      @txallinfo = []
      for k in 0..txinfo['vin'].length-1
        vinrawtx = bitcoinRPC('getrawtransaction',[txinfo['vin'][k]['txid']])
        vintx = bitcoinRPC('decoderawtransaction',[vinrawtx])
        vin_outindex = txinfo['vin'][k]['vout']
        if (vin_outindex)
          vin_info = []
          vin_info.push(vintx['vout'][vin_outindex]['scriptPubKey']['addresses'][0])
          vin_info.push(vintx['vout'][vin_outindex]['value'])
          vin_info.push(vintx['vout'][vin_outindex]['scriptPubKey']['asm'])
          vin_info.push(vintx['vout'][vin_outindex]['scriptPubKey']['type'])
          vin_allinfos.push(vin_info)
        end
      end
      output_value = 0
      for t in 0..txinfo['vout'].length-1
        output_value = output_value + txinfo['vout'][t]['value']
        gettxout = bitcoinRPC('gettxout',[txid, t])
        if gettxout
          spent_flag = "未使用"
        else
          spent_flag = "使用済"
        end
        spentflags.push(spent_flag)
      end
      @txallinfo.push(txinfo, vin_allinfos, output_value, spentflags)
    end
    return @txallinfo
  end

  def blockinfo
    @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
    @blockhashid = params[:id]
    @blockinfos = bitcoinRPC('getblock',[@blockhashid])

    render template: 'bitcoin_app/blockinfo'
  end

  def mining
    @blockchaininfo = bitcoinRPC('getblockchaininfo',[])

    render template: 'bitcoin_app/mining'
  end

  def mine
    if params[:blocknum]
      blocknum = params[:blocknum]
    else
      blocknum = 1
    end
    if params[:address]
      address = params[:address]
    else
      listaddressgroupings = bitcoinRPC('listaddressgroupings',[])
      address_num = listaddressgroupings[0].count - 1
      address = listaddressgroupings[0][address_num][0]
    end
    @blockhash = bitcoinRPC('generatetoaddress',[blocknum.to_i, address])
    num = @blockhash.count - 1
    redirect_to blockinfo_path(@blockhash[num])
  end

  def addressinfo
    @addressid = params[:id]
    @validateaddress = bitcoinRPC('validateaddress',[@addressid])
    if @validateaddress['isvalid']
      mempoolinfo = bitcoinRPC('getrawmempool',[])
			@addresstx = []
			
      for n in 0..mempoolinfo.length-1
        address_unconf_txlist = gettxinfo(mempoolinfo[n])
        for p in 0..address_unconf_txlist[0]['vout'].length-1
          if (address_unconf_txlist[0]['vout'][p]['scriptPubKey']['addresses']) && (address_unconf_txlist[0]['vout'][p]['scriptPubKey']['addresses'][0] == @addressid)
            @addresstx.push(address_unconf_txlist)
          end
        end
			end
			
      blockinfo = bitcoinRPC('getblockchaininfo',[])
      current_height = blockinfo['blocks']
			
			for p in 0..current_height-1
        blockhash = bitcoinRPC('getblockhash',[current_height - p])
        @blosckinfos = bitcoinRPC('getblock',[blockhash])
				
        for s in 0..@blosckinfos['tx'].length-1
          address_conf_txlist = gettxinfo(@blosckinfos['tx'][s])
					for t in 0..address_conf_txlist[0]['vout'].length-1
            if (address_conf_txlist[0]['vout'][t]['scriptPubKey']['addresses']) && (address_conf_txlist[0]['vout'][t]['scriptPubKey']['addresses'][0] == @addressid)
              @addresstx.push(address_conf_txlist)
            end
					end
					
				end
				
      end
    end
    render template: 'bitcoin_app/addressinfo'
	end

  def getnewaddress(address_type)
    @newaddress = bitcoinRPC('getnewaddress',["", address_type])
    return @newaddress
  end

  def receive

    address_type = "bech32"
    @address = getnewaddress(address_type)
    amount = params[:amount].to_s
    if params[:amount]
      @uri = "bitcoin:" + @address + "?amount=" + amount
    else
      @uri = "bitcoin:" + @address
    end

    qr = RQRCode::QRCode.new(@uri, :size => 10, :level => :h)
    png = qr.to_img
    @qrcode = png.resize(300, 300).to_data_url
    render template: 'bitcoin_app/receive'
  end

  def addresslist
    @listaddressgroupings = bitcoinRPC('listaddressgroupings',[])
    render template: 'bitcoin_app/addresslist'
  end

  def sendings

  end

  def sent
    address = params[:address]
    amount = params[:amount]
    @txid = bitcoinRPC('sendtoaddress',[address, amount])
    if (@txid)
      redirect_to txinfo_path(@txid)
    else
      render template: 'bitcoin_app/notfound'
    end
  end

  def search
    @posts = params[:search]
		
		if @posts.size == 64
			
			if @posts == "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b"
        @txid = @posts
        redirect_to txinfo_path(@posts)
      elsif @txSearch = bitcoinRPC('getrawtransaction',[@posts])
        redirect_to txinfo_path(@posts)
      else
        @blockinfos = bitcoinRPC('getblock',[@posts])
				
				if @blockinfos
        redirect_to blockinfo_path(@posts)
        end
						
			end
				
		elsif @posts.size == 35 or @posts.size == 44 or @posts.size == 42
      redirect_to addressinfo_path(@posts)
    elsif @posts =~ /\A[0-9]+\z/
      @posts_num = @posts.to_i
			if @blockSearch = bitcoinRPC('getblockhash',[@posts_num])
        redirect_to blockinfo_path(@blockSearch)
      end
    else
      render template: 'bitcoin_app/notfound'
    end
	end

  def keys
    @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
    @balance = bitcoinRPC('getbalance',[])
    @key = Bitcoin::Key.generate

    listaddressgroupings = bitcoinRPC('listaddressgroupings',[])
    address = listaddressgroupings[0][0][0]

    @txid = bitcoinRPC('sendtoaddress',[address, 1])
    @gettx = bitcoinRPC('gettransaction',[@txid])
    @blockhash = bitcoinRPC('generatetoaddress',[1, address])
    @getblock = bitcoinRPC('getblock',[@blockhash[0]])

    render template: 'bitcoin_app/keys'
  end

	private
	def bitcoinRPC(method,param)
		http = Net::HTTP.new(HOST, PORT)
    request = Net::HTTP::Post.new('/')
    request.basic_auth(RPCUSER,RPCPASSWORD)
    request.content_type = 'application/json'
    request.body = {method: method, params: param, id: 'jsonrpc'}.to_json
    JSON.parse(http.request(request).body)["result"]
  end

end
