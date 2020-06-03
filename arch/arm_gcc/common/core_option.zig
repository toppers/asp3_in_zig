///
///  コンフィギュレーションオプションのコア依存部（ARM用）
///

///
///  コアのハードウェア資源の定義
///
const arm = @import("arm.zig");

///
///  サンプルプログラム／テストプログラムのための定義
///
pub const core_test = struct {
    usingnamespace @import("../../../include/kernel.zig");

    ///
    /// ★未完成
    ///

    // 不正アドレスの定義（メモリのない番地に設定する）
    //pub const ILLEGAL_IADDR = 0xd0000000;       // 不正命令アドレス
    //pub const ILLEGAL_DADDR = 0xd0000000;       // 不正データアドレス

    ///
    ///  未定義命令によるCPU例外の発生
    ///
    ///  未定義命令によりCPU例外を発生させる．使用している未定義命令は，
    ///  "Multiply and multiply accumulate"命令群のエンコーディング内
    ///  における未定義命令である．CPU例外ハンドラからそのままリターン
    ///  することで，未定義命令の次の命令から実行が継続する（ARMモード
    ///  で使うことを想定している）．
    ///
    pub const CPUEXC1 = EXCNO_UNDEF;            // 未定義命令
    pub fn raiseCpuException() void {
        asm volatile(".word 0xf0500090");
    }
    pub fn prepareReturnCpuException() void {}
};
