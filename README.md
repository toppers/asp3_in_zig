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

    tecsgen          1.8.RC2
    ruby             2.6.3p62
    make             GNU Make 3.81
    qemu-system-arm  version 5.0.0
