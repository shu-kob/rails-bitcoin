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

停止

```
$ bitcoin-cli -regtest stop
```

### 設定ファイルにオプションをまとめる

いちいちオプションをつけて操作するのが面倒なので、設定ファイルにまとめましょう。

### Macの場合

```
cd "/Users/${USER}/Library/Application Support/Bitcoin/"
```

### Linuxの場合

```
cd ~/.bitcoin

```

### Mac, Linux共通 

生成されているbitcoin.confを編集

下記をコピペして保存

```
regtest=1
txindex=1
server=1
daemon=1
rpcuser=hoge
rpcpassword=hoge
[regtest]
rpcport=18443
port=18444
```

起動してブロックチェーン情報を取得
```
bitcoind
bitcoin-cli getblockchaininfo
```

起動したままにして、Ruby on Railsの環境を整えていきます。

## Ruby on Railsのインストール

### Macの場合

```
brew link autoconf
brew unlink autoconf && brew link autoconf
brew install rbenv ruby-build
brew update && brew upgrade ruby-build
rbenv install 2.6.4
# かなりが時間かかるので気長に待ちましょう
rbenv global 2.6.4
ruby -v
# 2.6.4であればOK
gem install bundler
bundle -v
gem install rails --version="~> 6.0.0”
rails -v
# 6系であればOK
git clone https://github.com/shu-kob/rails-bitcoin
cd rails-bitcoin
bundle install
brew install yarn
yarn install --check-files
rails s
```


### Ubuntuの場合

```
sudo apt-get update
sudo apt-get -y install git curl g++ make
sudo apt-get -y install zlib1g-dev libssl-dev libreadline-dev
sudo apt-get -y install libyaml-dev libxml2-dev libxslt-dev
sudo apt-get -y install sqlite3 libsqlite3-dev nodejs
cd
git clone git://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL
mkdir -p ~/.rbenv/plugins
cd ~/.rbenv/plugins
git clone git://github.com/sstephenson/ruby-build.git
rbenv install 2.6.4
かなりが時間かかるので気長に待ちましょう
rbenv global 2.6.4
rbenv version
# 2.6.4であればOK
which ruby
# 例)/home/vagrant/.rbenv/shims/ruby などと返ってくればOK
ruby -v
# 2.6.4であればOK
gem install rails --version="~> 6.0.0”
rbenv rehash
rails -v
# 6系であればOK
git clone https://github.com/shu-kob/rails-bitcoin
cd rails-bitcoin
bundle install
sudo apt-get install yarn
sudo apt-get install npm
sudo npm install -g n
yarn install --check-files
rails s
```

### Mac, Linux共通 

http://localhost:3000/

