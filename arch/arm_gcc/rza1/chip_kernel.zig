///
///  kernel.zigのチップ依存部（RZ/A1用）
///

///
///  コア依存部
///
usingnamespace @import("../common/core_kernel.zig");

///
///  サポートできる機能の定義
///
///  ena_int／dis_int／clr_int／ras_int／prb_intとオーバランハンドラを
///  サポートすることができる．
///
pub const TOPPERS_SUPPORT_ENA_INT = true;       // ena_int
pub const TOPPERS_SUPPORT_DIS_INT = true;       // dis_int
pub const TOPPERS_SUPPORT_CLR_INT = true;       // clr_int
pub const TOPPERS_SUPPORT_RAS_INT = true;       // ras_int
pub const TOPPERS_SUPPORT_PRB_INT = true;       // prb_int
pub const TOPPERS_SUPPORT_OVRHDR = true;

///
///  割込み優先度の範囲
///
pub const TMIN_INTPRI = -31;    // 割込み優先度の最小値（最高値）
pub const TMAX_INTPRI = -1;     // 割込み優先度の最大値（最低値）

///
///  ターゲット定義の割込み要求ライン属性
///
pub const TA_NEGEDGE  = 0x04;   // ネガティブエッジトリガ
pub const TA_POSEDGE  = 0x08;   // ポジティブエッジトリガ
pub const TA_BOTHEDGE = 0x0c;   // 両エッジトリガ

///
///  アプリケーションに直接見せる定義
///
pub const chip_publish = struct {
    ///
    ///  コアで共通な定義の取り込み
    ///
    pub usingnamespace core_publish;
};
