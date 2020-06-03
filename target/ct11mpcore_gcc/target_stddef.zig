///
///  t_stddef.zigのターゲット依存部（CT11MPCore用）
///

///
///  コンフィギュレーションの定義の取り込み
///
const option = @import("../../include/option.zig");
const abort = option.target.abort;

///
///  SYSTIM型を64ビットにする
///
pub const USE_64BIT_SYSTIM = true;

///
///  アサーションの失敗時の実行中断処理
///
pub fn assert_abort() noreturn {
    abort();
}
