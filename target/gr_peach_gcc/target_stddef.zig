///
///  t_stddef.hのターゲット依存部（GR-PEACH用）
///

///
///  チップ依存部（RZ/A1用）
///
pub usingnamespace @import("../../arch/arm_gcc/rza1/chip_stddef.zig");

///
///  アサーションの失敗時の実行中断処理
///
pub fn assert_abort() noreturn {
    // bkpt命令によりデバッガに制御を移す（パラメータが何が良いか未検討）
    asm volatile("bkpt #0");
    unreachable;
}
