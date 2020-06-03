///
///  sil.zigのターゲット依存部（ダミーターゲット用）
///

///
///  全割込みロック状態の制御
///
pub fn PRE_LOC() u32 {
    return 0;
}
pub fn LOC_INT(p_lock: *u32) void {
    p_lock.* += 1;
}
pub fn UNL_INT(p_lock: *u32) void {
    p_lock.* -= 1;
}

///
///  微少時間待ち
///
pub fn dly_nse(dlytim: usize) void {}

///
///  メモリ同期バリア
///
pub fn write_sync() void {}
