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
        logger.debug @blockchaininfo
        if i > 25
            @num = 25
        else
            @num = i
        end
        @height_num  = @blockchaininfo['blocks'] - @num
        logger.debug @num
        logger.debug @height_num
        blockhash = []
        blockinfo = []
        j = 0
        if i == 0
            @blockhash = blockhash.push(bitcoinRPC('getblockhash',[i]))
            logger.debug @blockhash
            logger.debug @blockhash[j]
            @blockinfo = blockinfo.push(bitcoinRPC('getblock',[@blockhash[j]]))
            logger.debug @blockinfo
            logger.debug @blockinfo[j]['height']
            logger.debug @blockinfo.length
            logger.debug @blockinfo.length-1
        else
            while i > @height_num do
                @blockhash = blockhash.push(bitcoinRPC('getblockhash',[i]))
                logger.debug @blockhash
                logger.debug @blockhash[j]
                @blockinfo = blockinfo.push(bitcoinRPC('getblock',[@blockhash[j]]))
                logger.debug @blockinfo
                logger.debug @blockinfo[j]['height']
                logger.debug @blockinfo.length
                logger.debug @blockinfo.length-1
                i = i - 1
                j = j + 1
            end
        end
        render template: 'bitcoin_app/explorer'
    end

    def txinfo
        @txid = params[:id]
        @rawtx = bitcoinRPC('getrawtransaction',[@txid])
        logger.debug @rawtx
        if @rawtx
            @txinfo = bitcoinRPC('decoderawtransaction',[@rawtx])
            vin_address = []
            vin_value = []

            for k in 0..@txinfo['vin'].length-1
                @vinrawtx = bitcoinRPC('getrawtransaction',[@txinfo['vin'][k]['txid']])
                logger.debug @vinrawtx
                @vintx = bitcoinRPC('decoderawtransaction',[@vinrawtx])
                logger.debug @vintx
                @vin_outindex = @txinfo['vin'][k]['vout']
                if(@txinfo['vin'][k]['vout'])
                    @vin_address = vin_address.push(@vintx['vout'][@vin_outindex]['scriptPubKey']['addresses'][0])
                    @vin_value = vin_value.push(@vintx['vout'][@vin_outindex]['value'])
                end
            end
        end
        render template: 'bitcoin_app/txinfo'
    end

    def blockinfo
        @blockhashid = params[:id]
        @blockinfos = bitcoinRPC('getblock',[@blockhashid])

        render template: 'bitcoin_app/blockinfo'
    end

    def addressinfo
        @addressid = params[:id]
        if @addressid.size == 35 or @addressid.size == 44
            mempoolinfo = bitcoinRPC('getrawmempool',[])
            @addresstx = []
            for n in 0..mempoolinfo.length-1
                memrawtx = bitcoinRPC('getrawtransaction',[mempoolinfo[n]])
                @memdecodetx = bitcoinRPC('decoderawtransaction',[memrawtx])
                for q in 0..@memdecodetx['vout'].length-1
                    if @memdecodetx['vout'][q]['scriptPubKey']['addresses'][0] == @addressid
                        @addresstx.push(@memdecodetx)
                    end
                end
            end
            blockinfo = bitcoinRPC('getblockchaininfo',[])
            current_height = blockinfo['blocks']
            @vin_txinfo = []
            for p in 0..current_height-1
                blockhash = bitcoinRPC('getblockhash',[current_height - p])
                @blosckinfos = bitcoinRPC('getblock',[blockhash])
                for s in 0..@blosckinfos['tx'].length-1
                    rawtxinfo = bitcoinRPC('getrawtransaction',[@blosckinfos['tx'][s]])
                    @decodedtxinfo = bitcoinRPC('decoderawtransaction',[rawtxinfo])
                    for t in 0..@decodedtxinfo['vout'].length-1
                        if (@decodedtxinfo['vout'][t]['scriptPubKey']['addresses']) && (@decodedtxinfo['vout'][t]['scriptPubKey']['addresses'][0] == @addressid)
                            @addresstx.push(@decodedtxinfo)
                        end
                    end
                    for k in 0..@decodedtxinfo['vin'].length-1
                        if (@decodedtxinfo['vin'][k]['txid'])
                            @vinrawtx = bitcoinRPC('getrawtransaction',[@decodedtxinfo['vin'][k]['txid']])
                            @vintx = bitcoinRPC('decoderawtransaction',[@vinrawtx])
                            for w in 0..@vintx['vout'].length-1
                                if(@vintx['vout'][w]['scriptPubKey']['addresses']) && (@vintx['vout'][w]['scriptPubKey']['addresses'][0] == @addressid)
                                    @vin_txinfo.push(@vintx)
                                end
                            end
                        end
                    end
                end
            end
            render template: 'bitcoin_app/addressinfo'
        else
            render template: 'bitcoin_app/notfound'
        end
    end

    def mining
        listaddressgroupings = bitcoinRPC('listaddressgroupings',[])
        address = listaddressgroupings[1][0][0]
        @blockhash = bitcoinRPC('generatetoaddress',[1, address])
        logger.debug @blockhash
        logger.debug @blockhash[0]
        @getblock = bitcoinRPC('getblock',[@blockhash[0]])
        logger.debug @getblock

        render template: 'bitcoin_app/mining'
    end

    def getnewaddress
        @newaddress_bech32 = bitcoinRPC('getnewaddress',["", "bech32"])
        logger.debug @newaddress_bech32

        render template: 'bitcoin_app/getnewaddress'
    end

    def wallet
        @listaddressgroupings = bitcoinRPC('listaddressgroupings',[])
        logger.debug @listaddressgroupings

        if @listaddressgroupings
            render template: 'bitcoin_app/wallet'
        else
            render template: 'bitcoin_app/getnewaddress'
        end
    end

    def sendings

    end

    def sent
        logger.debug params
        address = params[:address]

        logger.debug address
        amount = params[:amount]
        logger.debug amount

        @txid = bitcoinRPC('sendtoaddress',[address, amount])
        logger.debug @txid
        @rawtx = bitcoinRPC('getrawtransaction',[@txid])
        @txinfo = bitcoinRPC('decoderawtransaction',[@rawtx])
        vin_address = []
        vin_value = []

        for k in 0..@txinfo['vin'].length-1
            @vinrawtx = bitcoinRPC('getrawtransaction',[@txinfo['vin'][k]['txid']])
            logger.debug @vinrawtx
            @vintx = bitcoinRPC('decoderawtransaction',[@vinrawtx])
            logger.debug @vintx
            @vin_outindex = @txinfo['vin'][k]['vout']
            if(@txinfo['vin'][k]['vout'])
                @vin_address = vin_address.push(@vintx['vout'][@vin_outindex]['scriptPubKey']['addresses'][0])
                @vin_value = vin_value.push(@vintx['vout'][@vin_outindex]['value'])
            end
        end
        render template: 'bitcoin_app/txinfo'
    end

    def search
        @posts = params[:search]
        flag = "notfound"
        if @posts.size == 64
            if @posts == "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b"
                @txid = @posts
                flag = "txinfo"
            elsif @txSearch = bitcoinRPC('getrawtransaction',[@posts])
                @rawtx = @txSearch
                @txid = @posts
                @txinfo = bitcoinRPC('decoderawtransaction',[@txSearch])
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
                flag = "txinfo"                
            else
                @blockinfos = bitcoinRPC('getblock',[@posts])
                if @blockinfos
                    flag = "blockinfo"
                end
            end
        elsif @posts =~ /\A[0-9]+\z/
            @posts_num = @posts.to_i
            logger.debug @posts_num
            if @blockSearch = bitcoinRPC('getblockhash',[@posts_num])
                @blockinfos = bitcoinRPC('getblock',[@blockSearch])
                flag = "blockinfo"
            end
        end
        if flag == "txinfo"
            render template: 'bitcoin_app/txinfo'
        elsif flag == "blockinfo"
            render template: 'bitcoin_app/blockinfo'
        else
            render template: 'bitcoin_app/notfound'
        end
    end

    def keys
        @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
        logger.debug @blockchaininfo
        @balance = bitcoinRPC('getbalance',[])
    
        @key = Bitcoin::Key.generate
        logger.debug @key

        listaddressgroupings = bitcoinRPC('listaddressgroupings',[])
        address = listaddressgroupings[0][0][0]

        @txid = bitcoinRPC('sendtoaddress',[address, 1])
        logger.debug @txid
        @gettx = bitcoinRPC('gettransaction',[@txid])
        logger.debug @gettx
        @blockhash = bitcoinRPC('generatetoaddress',[1, address])
        logger.debug @blockhash
        logger.debug @blockhash[0]
        @getblock = bitcoinRPC('getblock',[@blockhash[0]])
        logger.debug @getblock

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
