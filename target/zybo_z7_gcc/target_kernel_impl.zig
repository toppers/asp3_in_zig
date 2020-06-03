///
///  カーネルのターゲット依存部（ZYBO用）
///

///
///  コンフィギュレーションオプションの取り込み
///
const option = @import("../../include/option.zig");
const TOPPERS_OMIT_TECS = option.TOPPERS_OMIT_TECS;
const abort = option.target.abort;

///
///  チップ依存部（Zynq7000用）
///
pub usingnamespace @import("../../arch/arm_gcc/zynq7000/chip_kernel_impl.zig");

///
///  用いるライブラリ
///
const arm = @import("../../arch/arm_gcc/common/arm.zig");

///
///  L2キャッシュコントローラ（PL310）の操作ライブラリ
///
const pl310 = @import("../../arch/arm_gcc/common/pl310.zig");

///
///  カーネル動作時のメモリマップと関連する定義
///
///  0x00000000 - 0x1fffffff：外付けDDR（512MB）
///  0x40000000 - 0xbfffffff：プログラマブルロジック領域
///  0xe0000000 - 0xfdffffff：周辺デバイス等
///  0xfffc0000 - 0xffffffff：オンチップメモリ（OCM）領域
///                           （上位番地にマッピングした場合）
///

///
///  MMUへの設定属性（第1レベルディスクリプタ）
///
pub const MMU_ATTR_RAM   = arm.MMU_DSCR1_SHARED | arm.MMU_DSCR1_TEX001
                         | arm.V6_MMU_DSCR1_AP011 | arm.MMU_DSCR1_CB11;
pub const MMU_ATTR_IODEV = arm.MMU_DSCR1_SHARED | arm.MMU_DSCR1_TEX000
                         | arm.V6_MMU_DSCR1_AP011 | arm.MMU_DSCR1_CB01
                         | arm.V6_MMU_DSCR1_NOEXEC;

///
///  外付けDDR領域の先頭番地，サイズ，属性
///
pub const DDR_ADDR = 0x00000000;
pub const DDR_SIZE = 0x20000000;        // 512MB
pub const DDR_ATTR = MMU_ATTR_RAM;

///
///  プログラマブルロジック領域の先頭番地，サイズ，属性
///
pub const PL_ADDR = 0x40000000;
pub const PL_SIZE = 0x80000000;         // 2GB
pub const PL_ATTR = MMU_ATTR_IODEV;

///
///  周辺デバイス等領域の先頭番地，サイズ，属性
///
pub const PERI_ADDR = 0xe0000000;
pub const PERI_SIZE = 0x1e000000;
pub const PERI_ATTR = MMU_ATTR_IODEV;

///
///  オンチップメモリ領域の先頭番地，サイズ，属性
///
///  オンチップメモリの実際のサイズは256KBであるが，セクションテーブル
///  では1MB単位でしか設定できないため，1MB単位に丸めて登録する．
///
pub const OCM_ADDR = 0xfff00000;
pub const OCM_SIZE = 0x00100000;        // 1MB
pub const OCM_ATTR = MMU_ATTR_RAM;

///
///  MMUの設定情報（メモリエリアの情報）
///
pub const arm_memory_area = [_]ARM_MMU_CONFIG {
    .{ .vaddr = DDR_ADDR, .paddr = DDR_ADDR,
       .size = DDR_SIZE, .attr = DDR_ATTR },
    .{ .vaddr = PL_ADDR, .paddr = PL_ADDR,
       .size = PL_SIZE, .attr = PL_ATTR },
    .{ .vaddr = PERI_ADDR, .paddr = PERI_ADDR,
       .size = PERI_SIZE, .attr = PERI_ATTR },
    .{ .vaddr = OCM_ADDR, .paddr = OCM_ADDR,
       .size = OCM_SIZE, .attr = OCM_ATTR },
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
    // チップ依存の初期化
    chip_initialize();

    // ベクタテーブルの設定
    arm.CP15_WRITE_VBAR(@intCast(u32, @ptrToInt(vector_table)));

    // SIOを初期化
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

    // チップ依存の終了処理
    chip_terminate();

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
        //
        // コンパイラがFPUを使用する命令を出すため，USE_ARM_FPUであるか否
        // かにかかわらず，FPUをイネーブルする．
        //
        arm_fpu_initialize();

        arm.disable_dcache();
        pl310.disable();
        arm.disable_icache();
    }

    ///
    ///  コア依存部からexportする関数
    ///
    usingnamespace CoreExportDefs;
};
