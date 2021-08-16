# asp3_in_zig
TOPPERS/ASP3 Kernel written in Zig Programming Language

このレポジトリには，asp3_in_zigをビルドするために必要なファイルの中で，TECSジェネレータは含んでいません。ビルドするためには，TECSジェネレータを，tecsgenディレクトリに置くか，リンクを貼ってください。

ビルド&実行方法（例）

    % mkdir OBJ-ARM
    % cd OBJ-ARM
    % ../configure.rb -T ct11mpcore_gcc -O "-DTOPPERS_USE_QEMU"
    % make
    % qemu-system-arm -M realview-eb-mpcore -semihosting -m 128M -nographic -kernel asp

Zigのコンパイラは，Release 0.8.0を利用してください。古い版では動作しません。最新版で動作するとは限りません。

その他の依存しているソフトウェアの動作確認バージョンは，次の通りです。

    arm-none-eabi-gcc      9.3.1 20200408
    arm-none-eabi-objcopy  2.34.0.20200428
    tecsgen                1.8.RC2
    ruby                   2.6.3p62
    make                   GNU Make 3.81
    qemu-system-arm        version 5.0.0

## 利用条件

このレポジトリに含まれるプログラムの利用条件は，[TOPPERSライセンス](https://www.toppers.jp/license.html)です。

## 参考情報

- 小南さんが，以下のページに，関連するソフトウェアに関する情報を詳細に記述くださっています。

  https://github.com/ykominami/asp3_in_zig/blob/master/README.md
