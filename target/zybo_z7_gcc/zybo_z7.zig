///
///  ZYBOのハードウェア資源の定義
///

///
///  各クロック周波数の定義
///
pub const ZYNQ_CPU_6X4X_MHZ = 667;      // 667MHz
pub const ZYNQ_CPU_3X2X_MHZ = 356;      // 356MHz
pub const ZYNQ_CPU_2X_MHZ   = 222;      // 222MHz
pub const ZYNQ_CPU_1X_MHZ   = 111;      // 111MHz

///
///  各タイマのプリスケール値と周波数の定義
///
///  周辺デバイス向けクロック（ZYNQ_CPU_3X2X_MZ，325MHz）を65分周して，
///  5MHzの周波数で使用する．
///
pub const MPCORE_TMR_PS_VALUE = 64;
pub const MPCORE_TMR_FREQ     = 5;

pub const MPCORE_WDG_PS_VALUE = 64;
pub const MPCORE_WDG_FREQ     = 5;

pub const MPCORE_GTC_PS_VALUE = 64;
pub const MPCORE_GTC_FREQ     = 5;

///
///  UARTの設定値の定義（115.2Kbpsで動作させる場合）
///
pub const XUARTPS_BAUDGEN_115K = 0x7c;
pub const XUARTPS_BAUDDIV_115K = 0x06;
