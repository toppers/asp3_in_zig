///
///  カーネルのターゲット依存部（CT11MPCore用）
///
usingnamespace @import("../../kernel/kernel_impl.zig");

///
///  コンフィギュレーションオプションの取り込み
///
const TOPPERS_OMIT_TECS = option.TOPPERS_OMIT_TECS;
const USE_ARM_FPU = option.target.USE_ARM_FPU;
const MPCORE_PMR_BASE = option.target.MPCORE_PMR_BASE;
const abort = option.target.abort;

///
///  デフォルトの非タスクコンテキスト用のスタック領域の定義
///
pub const DEFAULT_ISTKSZ = 0x2000;

///
///  MPCore依存部
///
pub usingnamespace @import("../../arch/arm_gcc/common/mpcore_kernel_impl.zig");

///
///  ターゲットのハードウェア資源の定義
///
const ct11mpcore = @import("ct11mpcore.zig");

///
///  用いるライブラリ
///
const arm = @import("../../arch/arm_gcc/common/arm.zig");

///
///  カーネル動作時のメモリマップと関連する定義
///
///  0x00000000 - 0x00100000：ベクター領域（1MB）
///  0x00100000 - 0x0FFFFFFF：DRAM（255MB）
///  0x10000000 - 0x100FFFFF：Emulation Baseboard上のリソース（1MB）
///  0x10100000 - 0x101FFFFF：Private Memory Region（1MB）(*)
///  0x48000000 - 0x4BFFFFFF：SRAM（4MB）
///
///  (*) Private Memory Regionの先頭番地は，ボードの設定で変更できる．
///

///
///  MMUへの設定属性（第1レベルディスクリプタ）
///
pub const MMU_ATTR_RAM    = arm.MMU_DSCR1_SHARED | arm.MMU_DSCR1_TEX001
                          | arm.V6_MMU_DSCR1_AP011 | arm.MMU_DSCR1_CB11;
pub const MMU_ATTR_IODEV  = arm.MMU_DSCR1_SHARED | arm.MMU_DSCR1_TEX000
                          | arm.V6_MMU_DSCR1_AP011 | arm.MMU_DSCR1_CB01
                          | arm.V6_MMU_DSCR1_NOEXEC;
pub const MMU_ATTR_VECTOR = arm.MMU_DSCR1_TEX001 | arm.V6_MMU_DSCR1_AP011
                          | arm.MMU_DSCR1_CB11;

///
///  メモリ領域の先頭番地とサイズ
///
pub const SDRAM_ADDR = 0x00100000;
pub const SDRAM_SIZE = 0x0ff00000;      // 255MB
pub const SDRAM_ATTR = MMU_ATTR_RAM;

pub const SRAM_ADDR = 0x48000000;
pub const SRAM_ATTR = MMU_ATTR_RAM;     // 16MB
pub const SRAM_SIZE = 0x04000000;

///
///  デバイスレジスタ領域の先頭番地とサイズ
///
pub const EB_ADDR = ct11mpcore.EB_BASE;
pub const EB_SIZE = 0x00100000;     // 1MB
pub const EB_ATTR = MMU_ATTR_IODEV;

pub const PMR_ADDR = MPCORE_PMR_BASE;
pub const PMR_SIZE = 0x00100000;        // 1MB
pub const PMR_ATTR = MMU_ATTR_IODEV;

///
///  ベクタテーブルを置くメモリ領域
///
pub const VECTOR_ADDR = 0x01000000;
pub const VECTOR_SIZE = 0x00100000;     // 1MB
pub const VECTOR_ATTR = MMU_ATTR_VECTOR;

///
///  MMUの設定情報（メモリエリアの情報）
///
pub const arm_memory_area = [_]ARM_MMU_CONFIG {
    .{ .vaddr = 0x00000000, .paddr = VECTOR_ADDR,
       .size = VECTOR_SIZE, .attr = VECTOR_ATTR },
    .{ .vaddr = SRAM_ADDR, .paddr = SRAM_ADDR,
       .size = SRAM_SIZE, .attr = SRAM_ATTR },
    .{ .vaddr = EB_ADDR, .paddr = EB_ADDR,
       .size = EB_SIZE, .attr = EB_ATTR },
    .{ .vaddr = PMR_ADDR, .paddr = PMR_ADDR,
       .size = PMR_SIZE, .attr = PMR_ATTR },
    .{ .vaddr = SDRAM_ADDR, .paddr = SDRAM_ADDR,
       .size = SDRAM_SIZE, .attr = SDRAM_ATTR },
};

///
///  システムログの低レベル出力のための初期化
///
///  セルタイプtPutLogSIOPort内に実装されている関数を直接呼び出す．
///
extern fn tPutLogSIOPort_initialize() void;

///
///  ターゲット依存の初期化
///
pub fn initialize() void {
    var reg: u32 = undefined;

    // MPCore依存の初期化
    mpcore_initialize();

    // Emulation Baseboardの割込みモードの設定
    sil.wrw_mem(ct11mpcore.EB_LOCK, ct11mpcore.EB_LOCK_UNLOCK); // ロック解除
    reg = sil.rew_mem(ct11mpcore.EB_PLD_CTRL1);
    reg &= ~@as(u32, ct11mpcore.EB_PLD_CTRL1_INTMODE_MASK);
    reg |= ct11mpcore.EB_PLD_CTRL1_INTMODE_NEW_NODCC;
    sil.wrw_mem(ct11mpcore.EB_PLD_CTRL1, reg);
    sil.wrw_mem(ct11mpcore.EB_LOCK, ct11mpcore.EB_LOCK_LOCK);   // ロック

    // UARTを初期化
    if (!TOPPERS_OMIT_TECS) {
        tPutLogSIOPort_initialize();
    }
}    

///
///  ターゲット依存の終了処理
///
extern fn software_term_hook() void;

pub fn exit() noreturn {
    // software_term_hookの呼び出し
    // 最適化の抑止のために，インラインアセンブラを使っている．
    if (asm("" : [_]"=r"(-> u32) : [_]"0"(software_term_hook)) != 0) {
        software_term_hook();
    }

    // MPCore依存の終了処理
    mpcore_terminate();

    // ターゲット依存の終了処理
    abort();
}

///
///  ターゲット依存部からexportする関数
///
pub const ExportDefs = struct {
    ///
    ///  ハードウェアの初期化
    ///
    export fn hardware_init_hook() void {
        // FPUの初期化
        if (USE_ARM_FPU) {
            arm_fpu_initialize();
        }
    }

    ///
    ///  コア依存部からexportする関数
    ///
    usingnamespace CoreExportDefs;
};
