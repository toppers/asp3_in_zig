///
///  RZ/A1のハードウェア資源の定義
///
usingnamespace @import("../../../kernel/kernel_impl.zig");

///
///  コンフィギュレーションオプションの取り込み
///
const TOPPERS_RZA1H = isTrue(option.target, "TOPPERS_RZA1H");
const TOPPERS_RZA1L = isTrue(option.target, "TOPPERS_RZA1L");
const RZA1_CLK_P0 = option.target.RZA1_CLK_P0;
const RZA1_CLK_P1 = option.target.RZA1_CLK_P1;

comptime {
    if (!TOPPERS_RZA1H and !TOPPERS_RZA1L) {
        @compileError("Either TOPPERS_RZA1H or TOPPERS_RZA1L must be true.");
    }
}

///
///  メモリマップの定義（MMUに設定するために必要）
///
pub const SPI_ADDR = 0x18000000;        // シリアルフラッシュメモリ
pub const SPI_SIZE = 0x08000000;        // 128MB

pub const SRAM_ADDR = 0x20000000;       // 内蔵RAM
pub const SRAM_SIZE =
    if (TOPPERS_RZA1H) 0x00a00000       // 10MB
    else 0x00300000;                    // 3MB

pub const IO1_ADDR = 0x3fe00000;        // I/O領域（予約領域を含む）
pub const IO1_SIZE = 0x00200000;        // 2MB
pub const IO2_ADDR = 0xe8000000;        // I/O領域（予約領域を含む）
pub const IO2_SIZE = 0x18000000;        // 384MB

///
///  各クロック周波数の定義
///
pub const OSTM_CLK = RZA1_CLK_P0;
pub const SCIF_CLK = RZA1_CLK_P1;

///
///  MPCore Private Memory Regionの先頭番地
///
pub const MPCORE_PMR_BASE = 0xf0000000;

///
///  GIC依存部を使用するための定義
///
pub const GIC_TNUM_INTNO =
    if (TOPPERS_RZA1H) 587
    else 537;
pub const GIC_ARM11MPCORE = true;

///
///  割込みコントローラのベースアドレスとレジスタ（RZ/A1固有のもの）
///
pub const GICC_BASE = 0xe8202000;
pub const GICD_BASE = 0xe8201000;

pub const RZA1_ICR0  = @intToPtr(*u16, 0xfcfef800);
pub const RZA1_ICR1  = @intToPtr(*u16, 0xfcfef802);
pub const RZA1_IRQRR = @intToPtr(*u16, 0xfcfef804);

///
///  OSタイマのベースアドレス
///
pub const OSTM0_BASE = 0xfcfec000;
pub const OSTM1_BASE = 0xfcfec400;

///
///  L2キャッシュコントローラ（PL310）のベースアドレス
///
pub const PL310_BASE = 0x3ffff000;

///
///  クロックパルスジェネレータのベースアドレスとレジスタ
///
pub const RZA1_CPG_BASE = 0xfcfe0000;
pub const RZA1_FRQCR    = @intToPtr(*u16, RZA1_CPG_BASE + 0x010);
pub const RZA1_FRQCR2   = @intToPtr(*u16, RZA1_CPG_BASE + 0x014);

///
///  バスステートコントローラのベースアドレスとレジスタ
///
pub const RZA1_BSC_BASE = 0x3FFFC000;
pub const RZA1_CMNCR    = @intToPtr(*u32, RZA1_BSC_BASE);
pub const RZA1_CS0BCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x0004);
pub const RZA1_CS1BCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x0008);
pub const RZA1_CS2BCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x000c);
pub const RZA1_CS3BCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x0010);
pub const RZA1_CS4BCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x0014);
pub const RZA1_CS5BCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x0018);
pub const RZA1_CS0WCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x0028);
pub const RZA1_CS1WCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x002c);
pub const RZA1_CS2WCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x0030);
pub const RZA1_CS3WCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x0034);
pub const RZA1_CS4WCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x0038);
pub const RZA1_CS5WCR   = @intToPtr(*u32, RZA1_BSC_BASE + 0x003c);
pub const RZA1_SDCR     = @intToPtr(*u32, RZA1_BSC_BASE + 0x004c);
pub const RZA1_RTCSR    = @intToPtr(*u32, RZA1_BSC_BASE + 0x0050);
pub const RZA1_RTCNT    = @intToPtr(*u32, RZA1_BSC_BASE + 0x0054);
pub const RZA1_RTCOR    = @intToPtr(*u32, RZA1_BSC_BASE + 0x0058);

///
///  シリアルコミュニケーションインタフェースのベースアドレス
///
pub const SCIF0_BASE = 0xe8007000;
pub const SCIF1_BASE = 0xe8007800;
pub const SCIF2_BASE = 0xe8008000;
pub const SCIF3_BASE = 0xe8008800;
pub const SCIF4_BASE = 0xe8009000;
pub const SCIF5_BASE = 0xe8009800;
pub const SCIF6_BASE = 0xe800a000;
pub const SCIF7_BASE = 0xe800a800;

///
///  低消費電力モード関連のベースアドレスとレジスタ
///
pub const RZA1_LOWPWR_BASE = 0xfcfe0000;
pub const RZA1_STBCR1      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x020);
pub const RZA1_STBCR2      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x024);
pub const RZA1_STBCR3      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x420);
pub const RZA1_STBCR4      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x424);
pub const RZA1_STBCR5      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x428);
pub const RZA1_STBCR6      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x42c);
pub const RZA1_STBCR7      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x430);
pub const RZA1_STBCR8      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x434);
pub const RZA1_STBCR9      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x438);
pub const RZA1_STBCR10     = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x43c);
pub const RZA1_STBCR11     = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x440);
pub const RZA1_STBCR12     = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x444);
pub const RZA1_STBCR13     = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x470);
pub const RZA1_SYSCR1      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x400);
pub const RZA1_SYSCR2      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x404);
pub const RZA1_SYSCR3      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x408);
pub const RZA1_CPUSTS      = @intToPtr(*u8, RZA1_LOWPWR_BASE + 0x018);

///
///  汎用入出力ポートのベースアドレスとレジスタ
///
pub const RZA1_PORT_BASE = 0xfcfe3000;
pub fn RZA1_PORT_P(n: c_uint) *u16 {
    return @intToPtr(*u16, RZA1_PORT_BASE + 0x0000 +  n * 4);
}
pub fn RZA1_PORT_PSR(n: c_uint) *u32 {
    return @intToPtr(*u32, RZA1_PORT_BASE + 0x0100 +  n * 4);
}
pub fn RZA1_PORT_PPR(n: c_uint) *u16 {
    return @intToPtr(*u16, RZA1_PORT_BASE + 0x0200 + n * 4);
}
pub fn RZA1_PORT_PM(n: c_uint) *u16 {
    return @intToPtr(*u16, RZA1_PORT_BASE + 0x0300 + n * 4);
}
pub fn RZA1_PORT_PMC(n: c_uint) *u16 {
    return @intToPtr(*u16, RZA1_PORT_BASE + 0x0400 + n * 4);
}
pub fn RZA1_PORT_PFC(n: c_uint) *u16 {
    return @intToPtr(*u16, RZA1_PORT_BASE + 0x0500 + n * 4);
}
pub fn RZA1_PORT_PFCE(n: c_uint) *u16 {
    return @intToPtr(*u16, RZA1_PORT_BASE + 0x0600 + n * 4);
}
pub fn RZA1_PORT_PFCAE(n: c_uint) *u16 {
    return @intToPtr(*u16, RZA1_PORT_BASE + 0x0a00 + n * 4);
}
pub fn RZA1_PORT_PIBC(n: c_uint) *u16 {
    return @intToPtr(*u16, RZA1_PORT_BASE + 0x4000 + n * 4);
}
pub fn RZA1_PORT_PBDC(n: c_uint) *u16 {
    return @intToPtr(*u16, RZA1_PORT_BASE + 0x4100 + n * 4);
}
pub fn RZA1_PORT_PIPC(n: c_uint) *u16 {
    return @intToPtr(*u16, RZA1_PORT_BASE + 0x4200 + n * 4);
}

///
///  割込み番号
///
pub const INTNO_IRQ0      = 32;         // IRQ0
pub const INTNO_IRQ1      = 33;         // IRQ1
pub const INTNO_IRQ2      = 34;         // IRQ2
pub const INTNO_IRQ3      = 35;         // IRQ3
pub const INTNO_IRQ4      = 36;         // IRQ4
pub const INTNO_IRQ5      = 37;         // IRQ5
pub const INTNO_IRQ6      = 38;         // IRQ6
pub const INTNO_IRQ7      = 39;         // IRQ7
pub const INTNO_OSTM0     = 134;        // OSタイマ0
pub const INTNO_OSTM1     = 135;        // OSタイマ1
pub const INTNO_SCIF0_BRI = 221;        // SCIF0 ブレーク割込み
pub const INTNO_SCIF0_ERI = 222;        // SCIF0 エラー割込み
pub const INTNO_SCIF0_RXI = 223;        // SCIF0 受信割込み
pub const INTNO_SCIF0_TXI = 224;        // SCIF0 送信割込み
pub const INTNO_SCIF1_BRI = 225;        // SCIF1 ブレーク割込み
pub const INTNO_SCIF1_ERI = 226;        // SCIF1 エラー割込み
pub const INTNO_SCIF1_RXI = 227;        // SCIF1 受信割込み
pub const INTNO_SCIF1_TXI = 228;        // SCIF1 送信割込み
pub const INTNO_SCIF2_BRI = 229;        // SCIF2 ブレーク割込み
pub const INTNO_SCIF2_ERI = 230;        // SCIF2 エラー割込み
pub const INTNO_SCIF2_RXI = 231;        // SCIF2 受信割込み
pub const INTNO_SCIF2_TXI = 232;        // SCIF2 送信割込み
pub const INTNO_SCIF3_BRI = 233;        // SCIF3 ブレーク割込み
pub const INTNO_SCIF3_ERI = 234;        // SCIF3 エラー割込み
pub const INTNO_SCIF3_RXI = 235;        // SCIF3 受信割込み
pub const INTNO_SCIF3_TXI = 236;        // SCIF3 送信割込み
pub const INTNO_SCIF4_BRI = 237;        // SCIF4 ブレーク割込み
pub const INTNO_SCIF4_ERI = 238;        // SCIF4 エラー割込み
pub const INTNO_SCIF4_RXI = 239;        // SCIF4 受信割込み
pub const INTNO_SCIF4_TXI = 240;        // SCIF4 送信割込み
pub const INTNO_SCIF5_BRI = 241;        // SCIF5 ブレーク割込み
pub const INTNO_SCIF5_ERI = 242;        // SCIF5 エラー割込み
pub const INTNO_SCIF5_RXI = 243;        // SCIF5 受信割込み
pub const INTNO_SCIF5_TXI = 244;        // SCIF5 送信割込み
pub const INTNO_SCIF6_BRI = 245;        // SCIF6 ブレーク割込み
pub const INTNO_SCIF6_ERI = 246;        // SCIF6 エラー割込み
pub const INTNO_SCIF6_RXI = 247;        // SCIF6 受信割込み
pub const INTNO_SCIF6_TXI = 248;        // SCIF6 送信割込み
pub const INTNO_SCIF7_BRI = 249;        // SCIF7 ブレーク割込み
pub const INTNO_SCIF7_ERI = 250;        // SCIF7 エラー割込み
pub const INTNO_SCIF7_RXI = 251;        // SCIF7 受信割込み
pub const INTNO_SCIF7_TXI = 252;        // SCIF7 送信割込み

///
///  IRQ割込み要求のクリア
///
pub fn clear_irq(intno: INTNO) void {
    var reg = sil.reh_mem(RZA1_IRQRR);
    reg &= ~(1 << @intCast(u4, intno - INTNO_IRQ0));
    sil.swrh_mem(RZA1_IRQRR, reg);
}

///
///  汎用入出力ポートの設定
///
///  汎用入出力ポートの制御レジスタの特定のビットを，セット（setがtrue
///  の時）またはクリア（setがfalseの時）する．
///
pub fn config_port(reg: *u16, bit: u4, set: bool) void {
    const mask = (@as(u16, 1) << bit);
    var val = sil.reh_mem(reg);
    if (set) {
        val |= mask;
    }
    else {
        val &= ~mask;
    }
    sil.wrh_mem(reg, val);
}
