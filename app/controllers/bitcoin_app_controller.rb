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
        if i > 10
            @num = 10
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
    
    def keys
        @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
        logger.debug @blockchaininfo
        @balance = bitcoinRPC('getbalance',[])
    
        @key = Bitcoin::Key.generate
        logger.debug @key

        address = "2NA9JGD8MKjpffNsxqzPUtqPZiwYmzB9QEz"

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

    def mining
        address = "2NA9JGD8MKjpffNsxqzPUtqPZiwYmzB9QEz"

        @blockhash = bitcoinRPC('generatetoaddress',[1, address])
        logger.debug @blockhash
        logger.debug @blockhash[0]
        @getblock = bitcoinRPC('getblock',[@blockhash[0]])
        logger.debug @getblock

        render template: 'bitcoin_app/mining'
    end

    def search
        @posts = params[:search]
        logger.debug @posts.size
        if @posts.size == 64
            @txSearch = bitcoinRPC('getrawtransaction',[@posts])
            if @txSearch.nil?
                @blockinfos = bitcoinRPC('getblock',[@posts])
                if @blockinfos
                    render template: 'bitcoin_app/blockinfo'
                else
                    render template: 'bitcoin_app/notfound'
                end
            end
        else
            logger.debug @posts
            @posts_num = @posts.to_i
            @blockSearch = bitcoinRPC('getblockhash',[@posts_num])
            logger.debug @blockSearch
            if @blockSearch
                @blockinfos = bitcoinRPC('getblock',[@blockSearch])
                render template: 'bitcoin_app/blockinfo'
            else
                render template: 'bitcoin_app/notfound'
            end
        end
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
