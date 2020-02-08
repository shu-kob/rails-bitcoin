# rails-bitcoin

== Bitcoin Core
Bitcoin Coreはbitcoindとも呼ばれ

=== Bitcoin Coreのインストール

 1. Macにbitcoindをインストール

下記の通りコマンドを打っていきましょう。改行のある箇所は改行やスペースを入れずにコマンド入力してください。

//cmd{
$ cd
$ wget https://bitcoin.org/bin/bitcoin-core-0.19.0.1/
bitcoin-0.19.0.1-osx64.tar.gz
$ tar -zxvf bitcoin-0.19.0.1-osx64.tar.gz
$ cd bitcoin-0.19.0.1/bin/
$ sudo cp * /usr/local/bin
//}

 2. Ubuntuにbitcoindをインストール

下記の通りコマンドを打っていきましょう。改行のある箇所は改行やスペースを入れずにコマンド入力してください。

//cmd{
$ cd
$ wget https://bitcoin.org/bin/bitcoin-core-0.19.0.1/
bitcoin-0.19.0.1-x86_64-linux-gnu.tar.gz
$ tar -zxvf bitcoin-0.19.0.1-x86_64-linux-gnu.tar.gz
$ cd bitcoin-0.19.0.1/bin/
$ sudo cp * /usr/local/bin
//}

=== bitcoindの起動

起動

//cmd{
$ bitcoind -regtest -txindex -daemon
//}

ブロックチェーンの状況を見てみます。Regtestモードの最初は0ブロックしかありません。

//cmd{
$ bitcoin-cli -regtest getblockchaininfo
//}
