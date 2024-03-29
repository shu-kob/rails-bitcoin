require 'bitcoin'
require 'net/http'
require 'json'
Bitcoin.chain_params = :regtest
RPCUSER="hoge"
RPCPASSWORD="hoge"
HOST="localhost"
PORT=18443
require 'openassets'
require 'rqrcode'

class BitcoinAppController < ApplicationController
  def index
    @network = chain()
    @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
    if blockchain_explorer_url() == "regtest"
      redirect_to blocklist_path()
    else
      render template: 'bitcoin_app/index'
    end
  end

  def blocklist
    if blockchain_explorer_url() == "regtest"
      if params[:blockheight]
        blockheightnum = params[:blockheight].to_i
      end
      if params[:blocknum]
        blocknum = params[:blocknum].to_i
      else
        blocknum = 25
      end
      @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
      @blockheight = @blockchaininfo['blocks']
      if (blockheightnum) && (blockheightnum < @blockheight)
        i = blockheightnum
      else
        i = @blockheight
      end

      if i >= blocknum - 1
        @blocknum = 25
      elsif i < blocknum - 1 && @blockheight >= blocknum
        @blocknum = blocknum
        i = blocknum - 1
      else
        @blocknum = i
      end
		
      @height_num  = i - @blocknum
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
		
      render template: 'bitcoin_app/blocklist'
    else
      blockchain_explorer_url = blockchain_explorer_url()
      redirect_to blockchain_explorer_url
    end
  end

  def txlist
    if blockchain_explorer_url() == "regtest"
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
    else
      blockchain_explorer_url = blockchain_explorer_url()
      redirect_to blockchain_explorer_url + 'tx/recent'
    end
  end

  def txinfo
    @txid = params[:txid]
    if blockchain_explorer_url() == "regtest"
      @blockinfos = bitcoinRPC('getblock',[@blockhash])
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
    else
      blockchain_explorer_url = blockchain_explorer_url()
      redirect_to blockchain_explorer_url + 'tx/' + @txid
    end
  end

  def gettxinfo(txid)
		rawtx = bitcoinRPC('getrawtransaction',[txid])
    if rawtx
      txinfo = bitcoinRPC('decoderawtransaction',[rawtx])
      vin_allinfos = []
      gettxouts = []
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
      spendable = true
      for t in 0..txinfo['vout'].length-1
        output_value = output_value + txinfo['vout'][t]['value']
        gettxout = bitcoinRPC('gettxout',[txid, t])
        gettxouts.push(gettxout)
        if gettxout
          if gettxout['coinbase'] == true
            if (gettxout['confirmations'] <= 100)
              spendable = false
            end
          end
        end
      end
      @txallinfo.push(txinfo, vin_allinfos, output_value, gettxouts, spendable)
    end
    return @txallinfo
  end

  def blockinfo
    @blockhashid = params[:blockhash]
    if blockchain_explorer_url() == "regtest"
      @blockinfos = bitcoinRPC('getblock',[@blockhashid])
      render template: 'bitcoin_app/blockinfo'
    else
      blockchain_explorer_url = blockchain_explorer_url()
      redirect_to blockchain_explorer_url + 'block/' + @blockhashid
    end
  end

  def blockheightinfo
    @blockheight = params[:blockheight].to_i
    @blockhash = bitcoinRPC('getblockhash',[@blockheight])
    redirect_to blockinfo_path(@blockhash)
  end

  def blockchain_explorer_url()
    chain = chain()
    if chain == "main"
      blockchain_explorer_url = 'https://blockstream.info/'
    elsif chain == "test"
      blockchain_explorer_url = 'https://blockstream.info/testnet/'
    elsif chain == "signet"
      blockchain_explorer_url = 'https://explorer.bc-2.jp/'
    elsif chain == "regtest"
      blockchain_explorer_url = 'regtest'
    end
    return blockchain_explorer_url
  end

  def chain()
    @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
    return @blockchaininfo["chain"]
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
    @addressid = params[:address]
    if blockchain_explorer_url() == "regtest"
      @validateaddress = bitcoinRPC('validateaddress',[@addressid])
      if @validateaddress['isvalid']
        mempoolinfo = bitcoinRPC('getrawmempool',[])
			  @addresstx = []
			
        for n in 0..mempoolinfo.length-1
          address_unconf_txlist = gettxinfo(mempoolinfo[n])
          for p in 0..address_unconf_txlist[0]['vout'].length-1
            if (address_unconf_txlist[0]['vout'][p]['scriptPubKey']['addresses']) && (address_unconf_txlist[0]['vout'][p]['scriptPubKey']['addresses'][0] == @addressid)
              address_unconf_txlist.push(0)
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
                address_conf_txlist.push(current_height - @blosckinfos['height'] + 1)
                @addresstx.push(address_conf_txlist)
              end
					  end
				  end
        end
      end
      @uri = "bitcoin:" + @addressid

      qrcode = RQRCode::QRCode.new(@uri, :size => 10, :level => :h)
      @qrcode = qrcode.as_svg(
        offset: 0,
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 6,
        standalone: true
      )
      render template: 'bitcoin_app/addressinfo'
    else
      blockchain_explorer_url = blockchain_explorer_url()
      redirect_to blockchain_explorer_url + 'address/' + @addressid
    end
	end

  def getnewaddress(address_type)
    @newaddress = bitcoinRPC('getnewaddress',["", address_type])
    return @newaddress
  end

  def receive

    address_type = "bech32"
    @address = getnewaddress(address_type)
    amount = params[:amount].to_s
    if amount != ""
      @uri = "bitcoin:" + @address + "?amount=" + amount
    else
      @uri = "bitcoin:" + @address
    end

    qrcode = RQRCode::QRCode.new(@uri, size: 10, level: :h)
    @qrcode = qrcode.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true
    )
    render template: 'bitcoin_app/receive'
  end

  def addresslist
    @listaddressgroupings = bitcoinRPC('listaddressgroupings',[])
    render template: 'bitcoin_app/addresslist'
  end

  def sendings

  end

  def sent
    address = params[:sending]['address']
    amount = params[:sending]['amount']
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

  def wallet
    mnemonic = Bitcoin::Mnemonic.new('english')
    entropy = SecureRandom.hex(32)
    @word_list = mnemonic.to_mnemonic(entropy)
    mnemonic_ja = Bitcoin::Mnemonic.new('japanese')
    @word_list_ja = mnemonic_ja.to_mnemonic(entropy)
    seed = mnemonic.to_seed(@word_list)
    master_key = Bitcoin::ExtKey.generate_master(seed)
    @key = master_key.derive(84, true).derive(0, true).derive(0, true).derive(0).derive(0)
    render template: 'bitcoin_app/wallet'
  end

  def utxolist
    if oa_address = params[:oaaddress]
      @utxo_list = api.list_unspent([oa_address])
    else
      @utxo_list = api.list_unspent
    end
    render template: 'bitcoin_app/utxolist'
  end

  def openassetsaddress(btc_address)
    oa_address = OpenAssets.address_to_oa_address(btc_address)
    return oa_address
  end

  def assetutxo

  end

  def assetissue
    btc_address = params[:address]
    oa_address = openassetsaddress(btc_address)
    amount = params[:amount].to_i
    metadata = ''
    @tx = api.issue_asset(oa_address, amount, metadata)
    render template: 'bitcoin_app/assetissue'
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

  def api
    api = OpenAssets::Api.new({
      network:             'regtest',
      provider:           'bitcoind',
      cache:            'regtest.db',
      dust_limit:                600,
      default_fees:            10000,
      min_confirmation:            1,
      max_confirmation:      9999999,
      rpc: {
        user:                  'hoge',
        password:              'hoge',
        schema:               'http',
        port:                  18332,
        host:            'localhost',
        timeout:                  60,
        open_timeout:             60 }
    })
    return api
  end

end
