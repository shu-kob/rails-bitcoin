require 'bitcoin'
require 'net/http'
require 'json'
Bitcoin.chain_params = :regtest
RPCUSER="hoge"
RPCPASSWORD="hoge"
HOST="localhost"
PORT=18332


class BitcoinAppController < ApplicationController
    def explorer
        @blockchaininfo = bitcoinRPC('getblockchaininfo',[])
        i = @blockchaininfo['blocks']
        logger.debug @blockchaininfo
        @num = 10
        @height_num  = @blockchaininfo['blocks'] - @num
        logger.debug @num
        logger.debug @height_num
        blockhash = []
        blockinfo = []
        j = 0
        while i > @height_num do
            @blockhash = blockhash.push(bitcoinRPC('getblockhash',[i]))
            logger.debug @blockhash
            logger.debug @blockhash[j]
            @blockinfo = blockinfo.push(bitcoinRPC('getblock',[@blockhash[j]]))
            logger.debug @blockinfo
            logger.debug @blockinfo[j]['height']
            logger.debug @blockinfo.length-1
            i = i - 1
            j = j + 1
        end
        render template: 'bitcoin_app/explorer'
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
        render template: 'bitcoin_app/txinfo'
    end

    def txinfo
        @txid = params[:id]
        @rawtx = bitcoinRPC('getrawtransaction',[@txid])
        @txinfo = bitcoinRPC('decoderawtransaction',[@rawtx])
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
