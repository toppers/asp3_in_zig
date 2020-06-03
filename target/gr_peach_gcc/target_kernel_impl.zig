///
///  カーネルのターゲット依存部（GR-PEACH用）
///

///
///  コンフィギュレーションオプションの取り込み
///
const option = @import("../../include/option.zig");
const TOPPERS_OMIT_TECS = option.TOPPERS_OMIT_TECS;
const TOPPERS_RZA1H =
    if (@hasDecl(option.target, "TOPPERS_RZA1H"))
         option.target.TOPPERS_RZA1H
    else false;

///
///  チップ依存部（RZ/A1用）
///
pub usingnamespace @import("../../arch/arm_gcc/rza1/chip_kernel_impl.zig");

///
///  ターゲットのハードウェア資源の定義
///
const gr_peach = @import("gr_peach.zig");
const rza1 = @import("../../arch/arm_gcc/rza1/rza1.zig");

///
///  用いるライブラリ
///
const sil = @import("../../include/sil.zig");
const arm = @import("../../arch/arm_gcc/common/arm.zig");

///
///  L2キャッシュコントローラ（PL310）の操作ライブラリ
///
const pl310 = @import("../../arch/arm_gcc/common/pl310.zig");

///
///  カーネル動作時のメモリマップと関連する定義
///
///  0x18000000 - 0x1fffffff：シリアルフラッシュメモリ（128MB）
///  0x20000000 - 0x209fffff：内蔵SRAM（10MB）
///  0x3fe00000 - 0x3fffffff：I/O領域（2MB），予約領域を含む
///  0xe8000000 - 0xffffffff：I/O領域（384MB），予約領域を含む
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
///  MMUの設定情報（メモリエリアの情報）
///
pub const arm_memory_area = [_]ARM_MMU_CONFIG {
    .{ .vaddr = rza1.SPI_ADDR, .paddr = rza1.SPI_ADDR,
       .size = rza1.SPI_SIZE, .attr = MMU_ATTR_RAM },
    .{ .vaddr = rza1.SRAM_ADDR, .paddr = rza1.SRAM_ADDR,
       .size = rza1.SRAM_SIZE, .attr = MMU_ATTR_RAM },
    .{ .vaddr = rza1.IO1_ADDR, .paddr = rza1.IO1_ADDR,
       .size = rza1.IO1_SIZE, .attr = MMU_ATTR_IODEV },
    .{ .vaddr = rza1.IO2_ADDR, .paddr = rza1.IO2_ADDR,
       .size = rza1.IO2_SIZE, .attr = MMU_ATTR_IODEV },
};

///
///  低消費電力モードの初期化
///
fn lowpower_initialize() void {
    // スタンバイモード時に端子状態を維持する．CoreSight動作
    sil.wrb_mem(rza1.RZA1_STBCR2, 0x6a);
    _ = sil.reb_mem(rza1.RZA1_STBCR2);      // ダミーリード

    // IEBus, irDA, LIN0, LIN1, MTU2, RSCAN2, ASC, PWM動作
    sil.wrb_mem(rza1.RZA1_STBCR3, 0x00);
    _ = sil.reb_mem(rza1.RZA1_STBCR3);      // ダミーリード

    // SCIF0, SCIF1, SCIF2, SCIF3, SCIF4, SCIF5, SCIF6, SCIF7動作
    sil.wrb_mem(rza1.RZA1_STBCR4, 0x00);
    _ = sil.reb_mem(rza1.RZA1_STBCR4);      // ダミーリード

    // SCIM0, SCIM1, SDG0, SDG1, SDG2, SDG3, OSTM0, OSTM1動作
    sil.wrb_mem(rza1.RZA1_STBCR5, 0x00);
    _ = sil.reb_mem(rza1.RZA1_STBCR5);      // ダミーリード

    // A/D, CEU, DISCOM0, DISCOM1, DRC0, DRC1, JCU, RTClock動作
    sil.wrb_mem(rza1.RZA1_STBCR6, 0x00);
    _ = sil.reb_mem(rza1.RZA1_STBCR6);      // ダミーリード

    // DVDEC0, DVDEC1, ETHER, FLCTL, USB0, USB1動作
    sil.wrb_mem(rza1.RZA1_STBCR7, 0x24);
    _ = sil.reb_mem(rza1.RZA1_STBCR7);      // ダミーリード

    // IMR-LS20, IMR-LS21, IMR-LSD, MMCIF, MOST50, SCUX動作
    sil.wrb_mem(rza1.RZA1_STBCR8, 0x05);
    _ = sil.reb_mem(rza1.RZA1_STBCR8);      // ダミーリード

    // I2C0, I2C1, I2C2, I2C3, SPIBSC0, SPIBSC1, VDC50, VDC51動作
    sil.wrb_mem(rza1.RZA1_STBCR9, 0x00);
    _ = sil.reb_mem(rza1.RZA1_STBCR9);      // ダミーリード

    // RSPI0, RSPI1, RSPI2, RSPI3, RSPI4, CD-ROMDEC, RSPDIF, RGPVG動作
    sil.wrb_mem(rza1.RZA1_STBCR10, 0x00);
    _ = sil.reb_mem(rza1.RZA1_STBCR10);     // ダミーリード

    // SSIF0, SSIF1, SSIF2, SSIF3, SSIF4, SSIF5動作
    sil.wrb_mem(rza1.RZA1_STBCR11, 0xc0);
    _ = sil.reb_mem(rza1.RZA1_STBCR11);     // ダミーリード

    // SDHI00, SDHI01, SDHI10, SDHI11動作
    sil.wrb_mem(rza1.RZA1_STBCR12, 0xf0);
    _ = sil.reb_mem(rza1.RZA1_STBCR12);     // ダミーリード
}

///
///  汎用入出力ポートの初期化（ポート／ペリフェラル兼用ピンのアサインの設定）
///
fn port_initialize() void {
    // ポート6:ビット3（TxD2）の設定
    rza1.config_port(rza1.RZA1_PORT_PIBC(6),  3, false);
    rza1.config_port(rza1.RZA1_PORT_PBDC(6),  3, false);
    rza1.config_port(rza1.RZA1_PORT_PIPC(6),  3, true);
    // 第7兼用機能（TxD2），出力
    rza1.config_port(rza1.RZA1_PORT_PMC(6),   3, true);
    rza1.config_port(rza1.RZA1_PORT_PFCAE(6), 3, true);
    rza1.config_port(rza1.RZA1_PORT_PFCE(6),  3, true);
    rza1.config_port(rza1.RZA1_PORT_PFC(6),   3, false);
    rza1.config_port(rza1.RZA1_PORT_PM(6),    3, false);

    // ポート6:ビット2（RxD2）の設定
    rza1.config_port(rza1.RZA1_PORT_PIBC(6),  2, false);
    rza1.config_port(rza1.RZA1_PORT_PBDC(6),  2, false);
    rza1.config_port(rza1.RZA1_PORT_PIPC(6),  2, true);
    // 第7兼用機能（RxD2），入力
    rza1.config_port(rza1.RZA1_PORT_PMC(6),   2, true);
    rza1.config_port(rza1.RZA1_PORT_PFCAE(6), 2, true);
    rza1.config_port(rza1.RZA1_PORT_PFCE(6),  2, true);
    rza1.config_port(rza1.RZA1_PORT_PFC(6),   2, false);
    rza1.config_port(rza1.RZA1_PORT_PM(6),    2, true);

    // ポート6:ビット13（LED1／赤）の設定
    rza1.config_port(rza1.RZA1_PORT_PIBC(6),  13, false);
    rza1.config_port(rza1.RZA1_PORT_PBDC(6),  13, false);
    // ポートモード，出力
    rza1.config_port(rza1.RZA1_PORT_PMC(6),   13, false);
    rza1.config_port(rza1.RZA1_PORT_PM(6),    13, false);

    // ポート6:ビット14（LED2／緑）の設定
    rza1.config_port(rza1.RZA1_PORT_PIBC(6),  14, false);
    rza1.config_port(rza1.RZA1_PORT_PBDC(6),  14, false);
    // ポートモード，出力
    rza1.config_port(rza1.RZA1_PORT_PMC(6),   14, false);
    rza1.config_port(rza1.RZA1_PORT_PM(6),    14, false);

    // ポート6:ビット15（LED3／青）の設定
    rza1.config_port(rza1.RZA1_PORT_PIBC(6),  15, false);
    rza1.config_port(rza1.RZA1_PORT_PBDC(6),  15, false);
    // ポートモード，出力
    rza1.config_port(rza1.RZA1_PORT_PMC(6),   15, false);
    rza1.config_port(rza1.RZA1_PORT_PM(6),    15, false);

    // ポート6:ビット12（LED4／ユーザ）の設定
    rza1.config_port(rza1.RZA1_PORT_PIBC(6),  12, false);
    rza1.config_port(rza1.RZA1_PORT_PBDC(6),  12, false);
    // ポートモード，出力
    rza1.config_port(rza1.RZA1_PORT_PMC(6),   12, false);
    rza1.config_port(rza1.RZA1_PORT_PM(6),    12, false);

    // ポート6:ビット0（ユーザボタン）の設定
    rza1.config_port(rza1.RZA1_PORT_PIBC(6),  0, true);
    rza1.config_port(rza1.RZA1_PORT_PBDC(6),  0, false);
    // 第6兼用機能（IRQ5），入力
    rza1.config_port(rza1.RZA1_PORT_PMC(6),   0, true);
    rza1.config_port(rza1.RZA1_PORT_PFCAE(6), 0, true);
    rza1.config_port(rza1.RZA1_PORT_PFCE(6),  0, false);
    rza1.config_port(rza1.RZA1_PORT_PFC(6),   0, true);
    rza1.config_port(rza1.RZA1_PORT_PM(6),    0, true);
}

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
    // Low exception vectorsを使用
    arm.set_low_vectors();

    // チップ依存の初期化
    chip_initialize();

    // 低消費電力モードの初期化
    lowpower_initialize();

    // 汎用入出力ポートの初期化（ポート／ペリフェラル兼用ピンのアサインの設定）
    port_initialize();

    // ベクタテーブルの設定
    arm.CP15_WRITE_VBAR(@intCast(u32, @ptrToInt(vector_table)));

    // LEDを青色に点灯させる
    gr_peach.set_led(gr_peach.LED_BLUE, true);

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

    // bkpt命令によりデバッガに制御を移す（パラメータが何が良いか未検討）
    asm volatile("bkpt #0");
    unreachable;
}

///
///  ターゲット依存部からexportする関数
///
pub const ExportDefs = struct {
    ///
    ///  ハードウェアの初期化
    ///
    export fn hardware_init_hook() void {
        // 内蔵RAMへのアクセス／書込み許可
        sil.wrb_mem(rza1.RZA1_SYSCR3, 0x0f);
        _ = sil.reb_mem(rza1.RZA1_SYSCR3);      // ダミーリード

        // クロック関係の初期化
        //
        // 以下の設定とする．
        //      入力周波数：13.33MHz，CKIO：66.67MHz
        //      CPUクロック（Iφ）：400.00MHz
        //      画像処理クロック（Gφ）：266.67MHz
        //      内部バスクロック（Bφ）：133.33MHz
        //      周辺クロック1（P1φ）：66.67MHz
        //      周辺クロック0（P0φ）：33.33MHz

        //  L2キャッシュのスタンバイモードをイネーブル（周波数変更時に必要）
        {
            const reg = sil.rew_mem(pl310.POWER_CTRL);
            sil.wrw_mem(pl310.POWER_CTRL, reg | 0x01);
        }

        // CPUクロックを「×1倍」に（400MHz）
        while (true) {
            sil.wrh_mem(rza1.RZA1_FRQCR, 0x1035);
            const reg = sil.reh_mem(rza1.RZA1_FRQCR);
            if (reg == 0x1035) break;
        }

        // 画像処理クロックを「×2/3」に（266.67MHz）
        if (TOPPERS_RZA1H) {
            while (true) {
                sil.wrh_mem(rza1.RZA1_FRQCR2, 0x0001);
                const reg = sil.reh_mem(rza1.RZA1_FRQCR2);
                if (reg == 0x0001) break;
            }
        }

        // ソフトウェアスタンバイ復帰中でなくなるまで待つ
        while (true) {
            const reg = sil.reb_mem(rza1.RZA1_CPUSTS);
            if ((reg & 0x10) == 0) break;
        }

        // L2キャッシュのスタンバイモードをディスエーブル
        {
            const reg = sil.rew_mem(pl310.POWER_CTRL);
            sil.wrw_mem(pl310.POWER_CTRL, reg & ~@as(u32, 0x01));
        }

        // FPUの初期化
        //
        // コンパイラがFPUを使用する命令を出すため，USE_ARM_FPUであるか否
        // かにかかわらず，FPUをイネーブルする．
        //
        arm_fpu_initialize();
    }

    ///
    ///  コア依存部からexportする関数
    ///
    usingnamespace CoreExportDefs;
};
