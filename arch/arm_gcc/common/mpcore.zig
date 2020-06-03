///
///  MPCoreサポートモジュール
///

///
///  コンフィギュレーションオプションの取り込み
///
const option = @import("../../../include/option.zig");
const MPCORE_PMR_BASE = option.target.MPCORE_PMR_BASE;

///
///  用いるライブラリ
///
const sil = @import("../../../include/sil.zig");
const arm = @import("arm.zig");

///
///  MMUの使用に関する設定
///
pub const USE_ARM_MMU = true;
pub const USE_ARM_SSECTION = true;

///
///  CP15の補助制御レジスタ（ACTLR）の設定値
///
pub const CP15_ACTLR_SMP =
    if (comptime arm.isEnabled(arm.Feature.has_v7)) 0x00000040
    else 0x00000020;
pub const CP15_ACTLR_FW =
    if (comptime arm.isEnabled(arm.Feature.has_v7)) 0x00000001
    else @compileError("not supported.");

///
///  SCU（スヌープ制御ユニット）関連の定義
///

///
///  SCUレジスタの番地の定義
///
pub const SCU_BASE    = MPCORE_PMR_BASE + 0x0000;
pub const SCU_CTRL    = @intToPtr(*u32, SCU_BASE + 0x00);
pub const SCU_CONFIG  = @intToPtr(*u32, SCU_BASE + 0x04);
pub const SCU_CPUSTAT = @intToPtr(*u32, SCU_BASE + 0x08);
pub const SCU_INVALL  = @intToPtr(*u32, SCU_BASE + 0x0c);

///
///  SCU制御レジスタ（SCU_CTRL）の設定値
///
pub const SCU_CTRL_ENABLE = 0x00000001;

///
///  SCUパワーステータスレジスタ（SCU_CPUSTAT）の設定値
///
pub const SCU_CPUSTAT_ALLNORMAL = 0x00000000;

///
///  SCUインバリデートオールレジスタ（SCU_INVALL）の設定値
///
pub const SCU_INVALL_ALLWAYS = 0x0000ffff;

///
///  GIC関連の定義
///

///
///  GICレジスタのベースアドレスの定義
///
pub const GICC_BASE = MPCORE_PMR_BASE + 0x0100;
pub const GICD_BASE = MPCORE_PMR_BASE + 0x1000;

///
///  割込み番号の定義
///
pub const IRQNO_GTC = 27;       // グローバルタイマの割込み番号
pub const IRQNO_TMR = 29;       // プライベートタイマの割込み番号
pub const IRQNO_WDG = 30;       // ウォッチドッグの割込み番号

///
///  プライベートタイマとウォッチドッグ関連の定義
///

///
///  プライベートタイマとウォッチドッグレジスタの番地の定義
///
pub const TMR_BASE = MPCORE_PMR_BASE + 0x0600;
pub const TMR_LR   = @intToPtr(*u32, TMR_BASE + 0x00);
pub const TMR_CNT  = @intToPtr(*u32, TMR_BASE + 0x04);
pub const TMR_CTRL = @intToPtr(*u32, TMR_BASE + 0x08);
pub const TMR_ISR  = @intToPtr(*u32, TMR_BASE + 0x0c);
pub const WDG_LR   = @intToPtr(*u32, TMR_BASE + 0x20);
pub const WDG_CNT  = @intToPtr(*u32, TMR_BASE + 0x24);
pub const WDG_CTRL = @intToPtr(*u32, TMR_BASE + 0x28);
pub const WDG_ISR  = @intToPtr(*u32, TMR_BASE + 0x2c);
pub const WDG_RST  = @intToPtr(*u32, TMR_BASE + 0x30);
pub const WDG_DIS  = @intToPtr(*u32, TMR_BASE + 0x34);

///
///  プライベートタイマ制御レジスタ（TMR_CTRL）の設定値
///
pub const TMR_CTRL_DISABLE    = 0x00;
pub const TMR_CTRL_ENABLE     = 0x01;
pub const TMR_CTRL_AUTORELOAD = 0x02;
pub const TMR_CTRL_ENAINT     = 0x04;
pub const TMR_CTRL_PS_SHIFT   = 8;

///
///  プライベートタイマ割込みステータスレジスタ（TMR_ISR）の設定値
///
pub const TMR_ISR_EVENTFLAG = 0x01;

///
///  ウォッチドッグ制御レジスタ（WDG_CTRL）の参照値
///
pub const WDG_CTRL_DISABLE    = 0x00;
pub const WDG_CTRL_ENABLE     = 0x01;
pub const WDG_CTRL_AUTORELOAD = 0x02;
pub const WDG_CTRL_ENAINT     = 0x04;
pub const WDG_CTRL_WDGMODE    = 0x08;
pub const WDG_CTRL_PS_SHIFT   = 8;

///
///  ウォッチドッグ割込みステータスレジスタ（WDG_ISR）の参照値
///
pub const WDG_ISR_EVENTFLAG = 0x01;

///
///  グローバルタイマ関連の定義（ARMv7のr1以降）
///

///
///  グローバルタイマレジスタの番地の定義
///
pub const GTC_BASE     = MPCORE_PMR_BASE + 0x0200;
pub const GTC_COUNT_L  = @intToPtr(*u32, GTC_BASE + 0x00);
pub const GTC_COUNT_U  = @intToPtr(*u32, GTC_BASE + 0x04);
pub const GTC_CTRL     = @intToPtr(*u32, GTC_BASE + 0x08);
pub const GTC_ISR      = @intToPtr(*u32, GTC_BASE + 0x0c);
pub const GTC_CVR_L    = @intToPtr(*u32, GTC_BASE + 0x10);
pub const GTC_CVR_U    = @intToPtr(*u32, GTC_BASE + 0x14);
pub const GTC_AUTOINCR = @intToPtr(*u32, GTC_BASE + 0x18);

///
///  グローバルタイマ制御レジスタ（GTC_CTRL）の設定値
///
pub const GTC_CTRL_DISABLE  = 0x00;
pub const GTC_CTRL_ENABLE   = 0x01;
pub const GTC_CTRL_ENACOMP  = 0x02;
pub const GTC_CTRL_ENAINT   = 0x04;
pub const GTC_CTRL_AUTOINCR = 0x08;
pub const GTC_CTRL_PS_SHIFT = 8;

///
///  グローバルタイマ割込みステータスレジスタ（GTC_ISR）の設定値
///
pub const GTC_ISR_EVENTFLAG = 0x01;

///
///  SMPモードに設定
///
pub fn enable_smp() void {
    var reg: u32 = arm.CP15_READ_ACTLR();
    reg |= CP15_ACTLR_SMP;
    if (comptime arm.isEnabled(arm.Feature.has_v7)) {
        reg |= CP15_ACTLR_FW;
    }
    arm.CP15_WRITE_ACTLR(reg);
}

///
///  SCU（スヌープ制御ユニット）の操作
///

///
///  SCUのイネーブル
///
pub fn enable_scu() void {
    // すべてのプロセッサをノーマルモードにする．
    sil.wrw_mem(SCU_CPUSTAT, SCU_CPUSTAT_ALLNORMAL);

    // SCUのすべてのタグを無効化する．
    sil.wrw_mem(SCU_INVALL, SCU_INVALL_ALLWAYS);

    // SCUを有効にする．
    var reg = sil.rew_mem(SCU_CTRL);
    reg |= SCU_CTRL_ENABLE;
    sil.wrw_mem(SCU_CTRL, reg);
    arm.data_sync_barrier();
}
