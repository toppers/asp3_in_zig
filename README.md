# asp3_in_zig
TOPPERS/ASP3 Kernel written in Zig Programming Language

このレポジトリには，asp3_in_zigをビルドするために必要なファイルの中で，TECSジェネレータは含んでいません。ビルドするためには，TECSジェネレータを，tecsgenディレクトリに置くか，リンクを貼ってください。

ビルド&実行方法（例）

    % mkdir OBJ-ARM
    % cd OBJ-ARM
    % ../configure.rb -T ct11mpcore_gcc -O "-DTOPPERS_USE_QEMU"
    % make
    % qemu-system-arm -M realview-eb-mpcore -semihosting -m 128M -nographic -kernel asp

Zigのコンパイラは，最新版を利用してください（動作確認は，2020年8月16日版）。古い版では動作しません。

その他の依存しているソフトウェアの動作確認バージョンは，次の通りです。

    arm-none-eabi-gcc      9.3.1 20200408
    arm-none-eabi-objcopy  2.34.0.20200428
    tecsgen                1.8.RC2
    ruby                   2.6.3p62
    make                   GNU Make 3.81
    qemu-system-arm        version 5.0.0
    
# Zig
## [The Zig Programming Language](https://ziglang.org/)
## [Releases · The Zig Programming Language](https://ziglang.org/download/)
最初のmasterが最新版です。毎日(あるいはコミット毎?)更新されます。
## [Documentation \- The Zig Programming Language](https://ziglang.org/documentation/master/)
# tecsgen
## 必要条件
tecsgenはRubyスクリプトであり、Ruby2.0
## バージョンについて
公開されているTECS個別パッケージの最新版は1.7に同梱されているtecsgenは1.7です。TECS個別パッケージにはtecsgen以外の各種ユーティリティも含まれています。
公開されているASP3簡易パッケージに同梱されているtecsgenは、1.6以上です。公開時期により異なります。
asp3_in_zigでは、1.6以上であれば利用できます。
## 入手方法
### TECS個別パッケージから
[TOPPERSプロジェクト／TECS](https://www.toppers.jp/tecs.html)

[tecsgen-1.7.0.tgz](https://www.toppers.jp/download.cgi/tecsgen-1.7.0.tgz)

tar xf tecsgen-1.7.0.tgz
cd tecsgen-1.7.0
ディレクトリtecsgenをリポジトリasp_in_zigに作成したOBJ-ARMディレクトリと同じ階層にコピーする
### ASP3簡易パッケージから
[TOPPERSプロジェクト／ASP3カーネル](https://www.toppers.jp/asp3-e-download.html)

