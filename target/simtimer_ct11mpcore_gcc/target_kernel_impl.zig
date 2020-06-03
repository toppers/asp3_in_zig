///
///  カーネルのターゲット依存部に関する定義
///  （CT11MPCore＋タイマドライバシミュレータ用）
///

pub usingnamespace @import("../ct11mpcore_gcc/target_kernel_impl.zig");

///
///  カーネルのアイドル処理でタイマドライバシミュレータを動作させる
///
pub const CUSTOM_IDLE = " msr cpsr_c, %[cpsr_svc_unlock]\n"
                     ++ " bl _kernel_target_custom_idle";
