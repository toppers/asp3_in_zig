///
///  コンフィギュレーションオプションのターゲット依存部（ZYBO用）
///

///
///  コンパイルオプションによるマクロ定義の取り込み
///
const opt = @cImport({});
pub const TOPPERS_USE_QEMU = @hasDecl(opt, "TOPPERS_USE_QEMU");
pub const TOPPERS_OMIT_QEMU_SEMIHOSTING =
            @hasDecl(opt, "TOPPERS_OMIT_QEMU_SEMIHOSTING");
pub const OMIT_XLOG_SYS = @hasDecl(opt, "OMIT_XLOG_SYS");

///
///  コア依存部（チップ依存部は飛ばす）
///
usingnamespace @import("../../arch/arm_gcc/common/core_option.zig");

///
///  ターゲットのハードウェア資源の定義
///
const zybo_z7 = @import("zybo_z7.zig");
const zynq7000 = @import("../../arch/arm_gcc/zynq7000/zynq7000.zig");
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
pub const MPCORE_PMR_BASE = zynq7000.MPCORE_PMR_BASE;

// GIC依存部向け
pub const GIC_TNUM_INTNO = zynq7000.GIC_TNUM_INTNO;
pub const GICC_BASE = mpcore.GICC_BASE;
pub const GICD_BASE = mpcore.GICD_BASE;

// PL310操作ライブラリ向け
pub const PL310_BASE = zynq7000.PL310_BASE;

// Zynq7000用タイマドライバ向け
pub const MPCORE_GTC_PS_VALUE = zybo_z7.MPCORE_GTC_PS_VALUE;
pub const MPCORE_GTC_FREQ = zybo_z7.MPCORE_GTC_FREQ;
pub const MPCORE_WDG_PS_VALUE = zybo_z7.MPCORE_WDG_PS_VALUE;
pub const MPCORE_WDG_FREQ = zybo_z7.MPCORE_WDG_FREQ;

///
///  実行終了
///
pub fn abort() noreturn {
    if (TOPPERS_USE_QEMU and !TOPPERS_OMIT_QEMU_SEMIHOSTING) {
        // QEMUを終了させる．
        asm volatile("svc 0x00123456" :: [code] "{r0}" (@as(u32, 24)));
    }

    // 無限ループに入る
    while (true) {}
}

///
///  サンプルプログラム／テストプログラムのための定義
///
pub const _test = struct {
    usingnamespace @import("../../include/kernel.zig");

    // コアで共通な定義の取り込み
    usingnamespace core_test;

    // サンプルプログラム／テストプログラムで使用する割込みに関する定義
    pub const INTNO1 = 35;              // USBからの割込み
    pub const INTNO1_INTATR = TA_ENAINT | TA_EDGE;
    pub const INTNO1_INTPRI = -15;
    pub fn intno1_clear() void {}
};
