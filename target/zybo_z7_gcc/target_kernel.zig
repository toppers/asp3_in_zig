///
///  kernel.zigのターゲット依存部（ZYBO用）
///

///
///  チップ依存部（Zynq7000用）
///
usingnamespace @import("../../arch/arm_gcc/zynq7000/chip_kernel.zig");

///
///  高分解能タイマのタイマ周期
///
///  TCYC_HRTCNTは定義しない．

///
///  高分解能タイマのカウント値の進み幅
///
pub const TSTEP_HRTCNT = 1;

///
///  オーバランハンドラの残りプロセッサ時間に指定できる最大値
///
pub const TMAX_OVRTIM = 858993459;      // floor(2^32/5) 

///
///  アプリケーションに直接見せる定義
///
pub const publish = struct {
    ///
    ///  チップで共通な定義の取り込み
    ///
    pub usingnamespace chip_publish;
};
