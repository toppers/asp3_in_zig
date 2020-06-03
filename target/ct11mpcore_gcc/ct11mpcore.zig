///
///  CT11MPcore with RealView Emulation Baseboard サポートモジュール
///

///
///  コンフィギュレーションオプションの取り込み
///
const option = @import("../../include/option.zig");
const TOPPERS_USE_QEMU = @hasDecl(option.target, "TOPPERS_USE_QEMU");

///
///  DICがサポートする割込みの数
///
pub const DIC_TNUM_INTNO = 48;

///
///  GIC依存部を使用するための定義
///
pub const GIC_TNUM_INTNO = DIC_TNUM_INTNO;
pub const GIC_SUPPORT_DISABLE_SGI = true;
pub const GIC_ARM11MPCORE = true;

///
///  割込み番号
///
pub const EB_IRQNO_TIMER01 = 33;
pub const EB_IRQNO_TIMER23 = 34;
pub const EB_IRQNO_UART0   = 36;
pub const EB_IRQNO_UART1   = 37;
pub const EB_IRQNO_UART2   = 44;    // 要検討
pub const EB_IRQNO_UART3   = 45;    // 要検討

///
///  MPCore Private Memory Regionの先頭番地
///
///  ARM11 MPCoreの制御レジスタには，MPCore Private Memory Regionと呼
///  ばれるメモリ領域によりアクセスする．この領域の先頭番地は，コア外
///  部から設定可能となっている．CT11MPCoreでは，ボードで設定できるよ
///  うになっており，デフォルトでは，0x1f000000になっている．
///
///  QEMUでは，この領域の先頭番地は，0x10100000に設定されている
///  （qemu-2.1.0/hw/arm/realview.c）．
///
pub const MPCORE_PMR_BASE =
    if (TOPPERS_USE_QEMU) 0x10100000 else 0x1f000000;

///
///  MPCore内蔵のタイマとウォッチドッグを1MHzで動作させるためのプリスケー
///  ラの設定値（コアのクロックが200MHzの場合）
///
pub const MPCORE_TMR_PS_VALUE = 99;
pub const MPCORE_WDG_PS_VALUE = 99;

///
///  Emulation Board上のリソース
///
pub const EB_BASE = 0x10000000;
pub const EB_LOCK = @intToPtr(*u32, EB_BASE + 0x0020);
pub const EB_PLD_CTRL1 = @intToPtr(*u32, EB_BASE + 0x0074);
pub const EB_PLD_CTRL2 = @intToPtr(*u32, EB_BASE + 0x0078);

///
///  ロックレジスタ（EB_LOCK）の設定値
///
pub const EB_LOCK_LOCK = 0x0000;
pub const EB_LOCK_UNLOCK = 0xa05f;

///
///  システム制御レジスタ1（EB_PLD_CTRL1）の設定値
///
pub const EB_PLD_CTRL1_INTMODE_LEGACY = 0x00000000;
pub const EB_PLD_CTRL1_INTMODE_NEW_DCC = 0x00400000;
pub const EB_PLD_CTRL1_INTMODE_NEW_NODCC = 0x00800000;
pub const EB_PLD_CTRL1_INTMODE_EN_FIQ = 0x01000000;
pub const EB_PLD_CTRL1_INTMODE_MASK = 0x01c00000;

///
///  UART関連の定義
///

/// 
///  UARTレジスタのベースアドレス
///
pub const EB_UART0_BASE = EB_BASE + 0x9000;
pub const EB_UART1_BASE = EB_BASE + 0xa000;
pub const EB_UART2_BASE = EB_BASE + 0xb000;
pub const EB_UART3_BASE = EB_BASE + 0xc000;

///
///  ボーレート設定（38400bps）
/// 
pub const EB_UART_IBRD_38400 = 0x27;
pub const EB_UART_FBRD_38400 = 0x04;

///
///  タイマ関連の定義
///

/// 
///  タイマレジスタのベースアドレス
///
pub const EB_TIMER0_BASE = EB_BASE + 0x11000;
pub const EB_TIMER1_BASE = EB_BASE + 0x11020;
pub const EB_TIMER2_BASE = EB_BASE + 0x12000;
pub const EB_TIMER3_BASE = EB_BASE + 0x12020;
