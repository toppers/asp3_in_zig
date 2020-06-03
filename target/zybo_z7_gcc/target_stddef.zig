///
///  t_stddef.zigのターゲット依存部（ZYBO用）
///

///
///  コンフィギュレーションオプションの取り込み
///
const option = @import("../../include/option.zig");
const abort = option.target.abort;

///
///  チップ依存部（Zynq7000用）
///
pub usingnamespace @import("../../arch/arm_gcc/zynq7000/chip_stddef.zig");

///
///  アサーションの失敗時の実行中断処理
///
pub fn assert_abort() noreturn {
    abort();
}
