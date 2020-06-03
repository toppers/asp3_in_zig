///
///  t_stddef.zigのターゲット依存部（ダミーターゲット用）
///

///
///  SYSTIM型を64ビットにする
///
pub const USE_64BIT_SYSTIM = true;

///
///  アサーションの失敗時の実行中断処理
///
pub fn assert_abort() noreturn {
    while (true) {}
}
