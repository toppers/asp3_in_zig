///
///  kernel.zigのターゲット依存部（GR-PEACH用）
///

///
///  チップ依存部（RZ/A1用）
///
usingnamespace @import("../../arch/arm_gcc/rza1/chip_kernel.zig");

///
///  高分解能タイマのタイマ周期
///
///  2^32 / 33.33…を丸めた値とする．
///
pub const TCYC_HRTCNT = 128_849_019;

///
///  高分解能タイマのカウント値の進み幅
///
pub const TSTEP_HRTCNT = 1;

///
///  オーバランハンドラの残りプロセッサ時間に指定できる最大値
///
///  この値をOSタイマへの設定値に変換してタイマに設定した後，タイマの
///  現在値を読み出してμ秒単位に変換できる値としている．タイマの現在
///  値をμ秒単位に変換する時に34を加えるため，以下の条件を満たす最大
///  の値とする．
///		(TMAX_OVRTIM * 33 + TMAX_OVRTIM / 3 + 1) + 34 < 2^32
///
pub const TMAX_OVRTIM = 128849017;

///
///  アプリケーションに直接見せる定義
///
pub const publish = struct {
    ///
    ///  コアで共通な定義の取り込み
    ///
    pub usingnamespace chip_publish;
};
