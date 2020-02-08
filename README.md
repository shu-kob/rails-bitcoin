# rails-bitcoin

## Bitcoin Core
Bitcoin Coreはbitcoindとも呼ばれる公式クライアントです。

### Bitcoin Coreのインストール

#### Macにbitcoindをインストール

下記の通りコマンドを打っていきましょう。

```
$ cd
$ wget https://bitcoin.org/bin/bitcoin-core-0.19.0.1/bitcoin-0.19.0.1-osx64.tar.gz
$ tar -zxvf bitcoin-0.19.0.1-osx64.tar.gz
$ cd bitcoin-0.19.0.1/bin/
$ sudo cp * /usr/local/bin
```

#### Ubuntuにbitcoindをインストール

下記の通りコマンドを打っていきましょう。

```
$ cd
$ wget https://bitcoin.org/bin/bitcoin-core-0.19.0.1/bitcoin-0.19.0.1-x86_64-linux-gnu.tar.gz
$ tar -zxvf bitcoin-0.19.0.1-x86_64-linux-gnu.tar.gz
$ cd bitcoin-0.19.0.1/bin/
$ sudo cp * /usr/local/bin
```

### bitcoindの起動

起動

```
$ bitcoind -regtest -txindex -daemon
```

ブロックチェーンの状況を見てみます。Regtestモードの最初は0ブロックしかありません。

```
$ bitcoin-cli -regtest getblockchaininfo
```
