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
### Ruby
Ruby2.0以上で動作することを目指して開発しています。
しかし2020年4月5日にRuby 2.4の公式サポートが終了しました。

[Ruby 2\.4 公式サポート終了](https://www.ruby-lang.org/ja/news/2020/04/05/support-of-ruby-2-4-has-ended/)

現在公式サポートがあるのは、Ruby 2.5, 2.6, 2.7系列です。

また、Rubyはオープンソースですが、昔のソースが現在の一般的な開発環境でそのままコンパイルできない場合もあります。

入手しやすさからも、公式サポートされているバージョンをお勧めします。
### クロスコンパイラに対応したCPP
tecsgenはCヘッダファイルを解析するために、クロスコンパイラに対応するCPPを利用します。

asp3_in_zigのMakefileではarm-none-eabi-gccを-Eオプションを指定してCPPとして利用しています。

## バージョンについて
公開されているTECS個別パッケージの最新版は1.7に同梱されているtecsgenは1.7です。TECS個別パッケージにはtecsgen以外の各種ユーティリティも含まれています。
公開されているASP3簡易パッケージに同梱されているtecsgenは、1.6以上です。公開時期により異なります。
asp3_in_zigでは、1.6以上であれば利用できます。
## 
## 入手方法
### TECS個別パッケージから
[TOPPERSプロジェクト／TECS](https://www.toppers.jp/tecs.html)

[tecsgen-1.7.0.tgz](https://www.toppers.jp/download.cgi/tecsgen-1.7.0.tgz)

    tar xf tecsgen-1.7.0.tgz
    cd tecsgen-1.7.0
    ディレクトリtecsgenをリポジトリasp_in_zigに作成したOBJ-ARMディレクトリと同じ階層にコピーする

### ASP3簡易パッケージから
[TOPPERSプロジェクト／ASP3カーネル](https://www.toppers.jp/asp3-e-download.html)

[asp3_arm_gcc-20191006.tar.gz](https://www.toppers.jp/download.cgi/asp3_arm_gcc-20191006.tar.gz)


    tar xf asp3_arm_gcc-20191006.tar.gz
    cd asp3
    ディレクトリtecsgenをリポジトリasp_in_zigに作成したOBJ-ARMディレクトリと同じ階層にコピーする

# 注意点
## Zig言語はソースファイルにハードタブを含められません。
[Documentation \- The Zig Programming Language](https://ziglang.org/documentation/master/#Source-Encoding)
## Zig言語はソースファイルにハードタブを含められません。
## Zig言語はソースファイルには、以下の行に示す例外を除いて、ASCIIのコントロールキャラクタを含めれません。
### U+000a (LF): U+0000 - U+0009, U+000b - U+0001f, U+007
### Windowsの改行文字(CRLF)を含めれません。
### ハードタブを含めれません。
