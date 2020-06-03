///
///  Zynq7000のハードウェア資源の定義
///

///
///  MPCore Private Memory Regionの先頭番地
///
pub const MPCORE_PMR_BASE = 0xf8f00000;

///
///  L2キャッシュコントローラ（PL310）のベースアドレス
///
pub const PL310_BASE = 0xf8f02000;

///
///  GICがサポートする割込みの数
///
pub const GIC_TNUM_INTNO = 96;

///
///  UARTのベースアドレスと割込み番号
///
pub const ZYNQ_UART0_BASE = 0xe0000000;
pub const ZYNQ_UART1_BASE = 0xe0001000;

pub const ZYNQ_UART0_IRQ = 59;
pub const ZYNQ_UART1_IRQ = 82;
