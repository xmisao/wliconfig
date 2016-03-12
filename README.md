# wliconfig

This programm is the 3rd party configuration cli for BUFFALO INC wireless lan adopters are called 'WLI' series.

`wliconfig` is tiny utility that change connect wireless lan network by scraping configuration page of 'WLI' terminal.

Supported 'WLI' terminals:

* WLI-UTX-AG300

That's all.

----

# wliconfig

このプログラムはBUFFALOの'WLI'シリーズと呼ばれる無線LANアダプタの非公式の設定CLIです。

`wliconfig`は小さなユーティリティで'WLI'シリーズの端末の設定画面をスクレイピングして接続先のワイヤレスネットワークを変更します。

サポートされる'WLI'シリーズの端末は以下のとおりです。

* WLI-UTX-AG300

## 使い方

### 基本的な使い方

まず準備として以下を行います。

WLIシリーズの設定画面から、端末のIPアドレスを固定します。例えば`192.168.0.1`にします。

WLIシリーズと有線LAN接続したコンピュータの、IPアドレスを設定してWLIシリーズと通信できるようにします。
Linuxで典型的な方法は以下です。

~~~~
ifconfig eth0 192.168.0.2
~~~~

準備は以上です。
この状態で`wliconfig`コマンドを実行します。

WLIシリーズのIPアドレス、BASIC認証のユーザ名とパスワード、接続したいSSID、認証方式、キーを指定しています。

~~~~
wliconfig -a 192.168.0.1 -u admin -p password -s your-ssid -m wpa2_aes -k your-key
~~~~

成功時の出力は以下のとおりです。

~~~~
Start processing...
Configuration file /home/xmisao/.wliconfig does not exist.
Attempt to access to 'http://192.168.0.1/'.
Begin fetch index page.
End fetch index page.
Begin fetch config page and submit config.
End fetch ocnfig page and submit config.
Begin fetch complete page.
End fetch complete page.
Complete processing successfully.
~~~~

念のためWLIシリーズの画面から、設定が変更できたかを確認して下さい。

WLIシリーズ経由で無線LANに繋ぐため、お使いの無線LANに合わせてIPアドレスや経路を変更します。
DHCPで設定する場合、Linuxなら以下のようにします。

~~~~
dhclient eth0
~~~~

基本的な使い方は以上です。
詳細な使い方は、続きを参照して下さい。

### オプション

`wliconfig`コマンドのオプションは以下のとおりです。すべてのオプションは任意です。
オプションの一覧は`wliconfig --help`で見ることもできます。

~~~~
-f FILE              オプションを指定したYAMLファイルから読み込みます。
-a, --addr ADDR      WLIシリーズのIPアドレスを指定します。(例. 192.168.0.1)
-u, --user USERNAME  BASIC認証のユーザ名を指定します。 (例. admin)
-p, --pass PASSWORD  BASIC認証のパスワードを指定します。 (例. password)
-s, --wlan-ssid SSID 接続するワイヤレスLANのSSIDを指定します。 
-m, --wlan-mode MODE 接続するワイヤレスLANの認証方式を指定します。 (none, wep_hex, wep_char, tkip, aes, wpa2_tkip or wpa2_aes が有効です)
-k, --wlan-key KEY   接続するワイヤレスLANのキーやパスフレーズを指定します。
    --debug          開発者向け。デバッグモードを有効にします。
~~~~

オプションはYAMLファイルから読み込むこともできます。
オプション指定に関わらず、常にホームディレクトリ下の`.wliconfig`ファイルを読み込みます。
また`-f`オプションが指定された場合、指定したYAMLファイルを読み込みます。

同一のオプションが複数の方法で指定された場合の、オプションの優先順位は以下のとおりです。
基本的なオプションをファイルで指定し、差分を追加のファイル、またはオプションで指定する使い方を想定しています。

~~~~
.wliconfigに書かれたオプション < -fオプションで指定したファイルに書かれたオプション < 引数で指定したオプション
~~~~

### 設定ファイル

`.wliconfig`および`-f`オプションで指定するファイルの書式は共通で、YAMLで書きます。
サンプルは以下のとおりです。すべてのキーは、ロングオプションと同じです。
すべてのオプションを書くことも、一部だけ書くこともできます。

~~~~
addr: 192.168.0.1
user: admin
pass: password
wlan-ssid: your-ssid
wlan-mode: wpa2_aes
wlan-key: your-key
~~~~
