# asp3_in_zig
TOPPERS/ASP3 Kernel written in Zig Programming Language

asp3_in_zigをビルドするために必要なファイルの中で，以下は含んでいません。
- tecsgen

ビルド&実行方法（例）
 % mkdir OBJ-ARM
 % cd OBJ-ARM
 % ../configure.rb -T ct11mpcore_gcc -O "-DTOPPERS_USE_QEMU"
 % qemu-system-arm -M realview-eb-mpcore -semihosting -m 128M -nographic -kernel asp
