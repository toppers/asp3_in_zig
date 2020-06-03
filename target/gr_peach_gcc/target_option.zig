///
///  コンフィギュレーションオプションのターゲット依存部（GR-PEACH用）
///

///
///  コンパイルオプションによるマクロ定義の取り込み
///
const opt = @cImport({});
pub const OMIT_XLOG_SYS = @hasDecl(opt, "OMIT_XLOG_SYS");

///
///  コア依存部（チップ依存部は飛ばす）
///
usingnamespace @import("../../arch/arm_gcc/common/core_option.zig");

///
///  ターゲットのハードウェア資源の定義
///
const gr_peach = @import("gr_peach.zig");
const rza1 = @import("../../arch/arm_gcc/rza1/rza1.zig");
const mpcore = @import("../../arch/arm_gcc/common/mpcore.zig");

///
///  ターゲットのコンフィギュレーション
///
// ARM依存部向け
pub const USE_ARM_MMU = mpcore.USE_ARM_MMU;
pub const USE_ARM_SSECTION = mpcore.USE_ARM_SSECTION;
pub const USE_ARM_FPU = @hasDecl(opt, "USE_ARM_FPU");
pub const USE_ARM_FPU_D32 = @hasDecl(opt, "USE_ARM_FPU_D32");
pub const USE_ARM_PMCNT = @hasDecl(opt, "USE_ARM_PMCNT");
pub const USE_ARM_PMCNT_DIV64 = @hasDecl(opt, "USE_ARM_PMCNT_DIV64");
pub const TNUM_INHNO = GIC_TNUM_INTNO;
pub const TNUM_INTNO = GIC_TNUM_INTNO;

// MPCore依存部向け
pub const MPCORE_PMR_BASE = rza1.MPCORE_PMR_BASE;

// GIC依存部向け
pub const GIC_TNUM_INTNO = rza1.GIC_TNUM_INTNO;
pub const GICC_BASE = rza1.GICC_BASE;
pub const GICD_BASE = rza1.GICD_BASE;
pub const GIC_ARM11MPCORE = rza1.GIC_ARM11MPCORE;

// PL310操作ライブラリ向け
pub const PL310_BASE = rza1.PL310_BASE;

// RZ/A1依存部向け
pub const TOPPERS_RZA1H = true;
pub const RZA1_CLK_P0 = gr_peach.RZA1_CLK_P0;
pub const RZA1_CLK_P1 = gr_peach.RZA1_CLK_P1;

///
///  サンプルプログラム／テストプログラムのための定義
///
pub const _test = struct {
    usingnamespace @import("../../include/kernel.zig");

    // コアで共通な定義の取り込み
    usingnamespace core_test;

    // サンプルプログラム／テストプログラムで使用する割込みに関する定義
    pub const INTNO1 = rza1.INTNO_IRQ5;
    pub const INTNO1_INTATR = TA_ENAINT | TA_EDGE;
    pub const INTNO1_INTPRI = -15;
    pub fn intno1_clear() void { rza1.clear_irq(rza1.INTNO_IRQ5); }
};
