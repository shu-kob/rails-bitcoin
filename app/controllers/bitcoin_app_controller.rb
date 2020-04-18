require 'bitcoin'
require 'net/http'
require 'json'
Bitcoin.chain_params = :regtest
RPCUSER="hoge"
RPCPASSWORD="hoge"
HOST="localhost"
PORT=18443

class BitcoinAppController < ApplicationController
  def explorer
    @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
		i = @blockchaininfo['blocks']
		
    if i > 25
      @num = 25
    else
      @num = i
		end
		
    @height_num  = @blockchaininfo['blocks'] - @num
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
		
    render template: 'bitcoin_app/explorer'
  end

  def previouspage
    i = params[:id].to_i
    @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
		@blockheight = @blockchaininfo['blocks']
		
    if i > 25
      @num = 25
    else
      @num = i
		end
		
    @height_num  = i - 1 - @num
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
		
    render template: 'bitcoin_app/explorer'
  end

  def nextpage
    i = params[:id].to_i
    i = i + 25
    @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
    @blockheight = @blockchaininfo['blocks']

    if i > @blockheight
      i = @blockheight
    end
		
    if i > 25
      @num = 25
    else
      @num = i
		end
		
    @height_num  = i - 1 - @num
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
		
    render template: 'bitcoin_app/explorer'
  end

  def txinfo
    txid = params[:id]
    @txinfo = addresstxinfo(txid)
    vin_address = []
    vin_value = []

    for k in 0..@txinfo['vin'].length-1
      @vinrawtx = bitcoinRPC('getrawtransaction',[@txinfo['vin'][k]['txid']])
      @vintx = bitcoinRPC('decoderawtransaction',[@vinrawtx])
      @vin_outindex = @txinfo['vin'][k]['vout']
      if(@txinfo['vin'][k]['vout'])
          @vin_address = vin_address.push(@vintx['vout'][@vin_outindex]['scriptPubKey']['addresses'][0])
          @vin_value = vin_value.push(@vintx['vout'][@vin_outindex]['value'])
      end
    end

    render template: 'bitcoin_app/txinfo'
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
    if @addressid.size == 35 or @addressid.size == 44 or @addressid.size == 42
      mempoolinfo = bitcoinRPC('getrawmempool',[])
			@addresstx = []
			
      for n in 0..mempoolinfo.length-1
        address_unconf_txlist = addresstxinfo(mempoolinfo[n])
        for p in 0..address_unconf_txlist['vout'].length-1
          if (address_unconf_txlist['vout'][p]['scriptPubKey']['addresses']) && (address_unconf_txlist['vout'][p]['scriptPubKey']['addresses'][0] == @addressid)
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
          address_conf_txlist = addresstxinfo(@blosckinfos['tx'][s])
					for t in 0..address_conf_txlist['vout'].length-1
            if (address_conf_txlist['vout'][t]['scriptPubKey']['addresses']) && (address_conf_txlist['vout'][t]['scriptPubKey']['addresses'][0] == @addressid)
              @addresstx.push(address_conf_txlist)
            end
					end
					
				end
				
			end
			
      render template: 'bitcoin_app/addressinfo'
    else
    render template: 'bitcoin_app/notfound'
  	end
	end

  def addresstxinfo(txid)
		@rawtx = bitcoinRPC('getrawtransaction',[txid])
    if @rawtx
      @txinfo = bitcoinRPC('decoderawtransaction',[@rawtx])
      vin_address = []
      vin_value = []

      for k in 0..@txinfo['vin'].length-1
        @vinrawtx = bitcoinRPC('getrawtransaction',[@txinfo['vin'][k]['txid']])
        @vintx = bitcoinRPC('decoderawtransaction',[@vinrawtx])
        @vin_outindex = @txinfo['vin'][k]['vout']
				if(@txinfo['vin'][k]['vout'])
          @vin_address = vin_address.push(@vintx['vout'][@vin_outindex]['scriptPubKey']['addresses'][0])
          @vin_value = vin_value.push(@vintx['vout'][@vin_outindex]['value'])
				end
      end
    end
    return @txinfo
  end

	def txlist
    mempoolinfo = bitcoinRPC('getrawmempool',[])
    @unconfirmedtxlist = []
		
		for n in 0..mempoolinfo.length-1
      unconfirmedrawtx = bitcoinRPC('getrawtransaction',[mempoolinfo[n]])
      decodedunconfirmedtxinfo = bitcoinRPC('decoderawtransaction',[unconfirmedrawtx])
      @unconfirmedtxlist.push(decodedunconfirmedtxinfo)
		end
		
    blockinfo = bitcoinRPC('getblockchaininfo',[])
    @confirmedtxlist = []
    current_height = blockinfo['blocks']
				
		for p in 0..current_height-1
			blockhash = bitcoinRPC('getblockhash',[current_height - p])
      @blosckinfos = bitcoinRPC('getblock',[blockhash])
						
			for s in 0..@blosckinfos['tx'].length-1
        confirmedrawtx = bitcoinRPC('getrawtransaction',[@blosckinfos['tx'][s]])
        @decodedtxinfo = bitcoinRPC('decoderawtransaction',[confirmedrawtx])
        @confirmedtxlist.push(@decodedtxinfo)
      end
		
		end
    render template: 'bitcoin_app/txlist'
  end

  def getnewaddress
    @newaddress_bech32 = bitcoinRPC('getnewaddress',["", "bech32"])
    redirect_to addressinfo_path(@newaddress_bech32)
  end

  def wallet
    @listaddressgroupings = bitcoinRPC('listaddressgroupings',[])
    render template: 'bitcoin_app/wallet'
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
    flag = "notfound"
		
		if @posts.size == 64
			
			if @posts == "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b"
        @txid = @posts
        flag = "txinfo"
      elsif @txSearch = bitcoinRPC('getrawtransaction',[@posts])
        flag = "txinfo"                
      else
        @blockinfos = bitcoinRPC('getblock',[@posts])
				
				if @blockinfos
        flag = "blockinfo"
        end
						
			end
				
		elsif @posts.size == 35 or @posts.size == 44 or @posts.size == 42
      flag = "addressinfo"
    elsif @posts =~ /\A[0-9]+\z/
      @posts_num = @posts.to_i
			
			if @blockSearch = bitcoinRPC('getblockhash',[@posts_num])
        flag = "blocknum"
      end
				
		end
		
		if flag == "txinfo"
      redirect_to txinfo_path(@posts)
    elsif flag == "blockinfo"
      redirect_to blockinfo_path(@posts)
    elsif flag == "blocknum"
      redirect_to blockinfo_path(@blockSearch)
    elsif flag == "addressinfo"
      redirect_to addressinfo_path(@posts)
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
