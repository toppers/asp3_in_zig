///
///  タイマドライバ（CT11MPCore用）
///
usingnamespace @import("../../kernel/kernel_impl.zig");

///
///  コンフィギュレーションの定義の取り込み
///
const TOPPERS_USE_QEMU = option.target.TOPPERS_USE_QEMU;
const MPCORE_TMR_PS_VALUE = option.target.MPCORE_TMR_PS_VALUE;
const MPCORE_WDG_PS_VALUE = option.target.MPCORE_WDG_PS_VALUE;
const EB_TIMER0_BASE = option.target.EB_TIMER0_BASE;
const EB_IRQNO_TIMER01 = option.target.EB_IRQNO_TIMER01;

///
///  高分解能タイマドライバ
///
///  MPCoreのプライベートタイマとウォッチドッグを用いて高分解能タイマ
///  を実現する．
///
const mpcore_timer = @import("../../arch/arm_gcc/common/mpcore_timer.zig");

///
///  高分解能タイマドライバのインスタンシエート
///
pub const hrt = mpcore_timer.TMRWDG_HRT(.{
    .TMR_PS_VALUE = MPCORE_TMR_PS_VALUE,
    .WDG_PS_VALUE = MPCORE_WDG_PS_VALUE,
});

///
///  ARM Dual-Timer Module（SP804）の番地の定義
///
fn SP804_LR(base: usize) *u32 {
    return @intToPtr(*u32, base + 0x00);
}
fn SP804_CVR(base: usize) *u32 {
    return @intToPtr(*u32, base + 0x04);
}
fn SP804_CR(base: usize) *u32 {
    return @intToPtr(*u32, base + 0x08);
}
fn SP804_ICR(base: usize) *u32 {
    return @intToPtr(*u32, base + 0x0c);
}
fn SP804_RIS(base: usize) *u32 {
    return @intToPtr(*u32, base + 0x10);
}
fn SP804_MIS(base: usize) *u32 {
    return @intToPtr(*u32, base + 0x14);
}
fn SP804_BGLR(base: usize)*u32 {
    return @intToPtr(*u32, base + 0x18);
}

///
///  制御レジスタ（SP804_CR）の設定値
///
const SP804_DISABLE       = 0x00;       // タイマディスエーブル
const SP804_ENABLE        = 0x80;       // タイマイネーブル
const SP804_INT_ENABLE    = 0x20;       // タイマ割込みイネーブル
const SP804_MODE_FREERUN  = 0x00;       // フリーランニングモード
const SP804_MODE_PERIODIC = 0x40;       // 周期モード
const SP804_MODE_ONESHOT  = 0x01;       // ワンショットモード
const SP804_SIZE_32       = 0x02;       // 32ビット
const SP804_PRESCALE_1    = 0x00;       // プリスケーラ ×1
const SP804_PRESCALE_16   = 0x04;       // プリスケーラ ×16
const SP804_PRESCALE_256  = 0x08;       // プリスケーラ ×256

///
///  オーバランタイマドライバ
///
pub const ovrtimer = struct {
    ///
    ///  オーバランタイマドライバで使用するタイマに関する指定
    ///
    const TIMER_BASE  = EB_TIMER0_BASE;
    const TIMER_IRQNO = EB_IRQNO_TIMER01;

    const SP804_CONFIG = SP804_INT_ENABLE | SP804_MODE_ONESHOT
                       | SP804_SIZE_32 | SP804_PRESCALE_1;

    ///
    ///  オーバランタイマ割込みハンドラ登録のための定数
    ///
    pub const INHNO_OVRTIMER  = TIMER_IRQNO;    // 割込みハンドラ番号
    pub const INTNO_OVRTIMER  = TIMER_IRQNO;    // 割込み番号
    pub const INTPRI_OVRTIMER = TMAX_INTPRI;    // 割込み優先度
    pub const INTATR_OVRTIMER = TA_NULL;        // 割込み属性

    ///
    ///  オーバランタイマの初期化処理
    ///
    pub fn initialize() void {
        sil.wrw_mem(SP804_CR(TIMER_BASE), SP804_DISABLE | SP804_CONFIG);
        sil.wrw_mem(SP804_ICR(TIMER_BASE), 0);
    }

    ///
    ///  オーバランタイマの停止処理
    ///
    pub fn terminate() void {
        sil.wrw_mem(SP804_CR(TIMER_BASE), SP804_DISABLE);
        sil.wrw_mem(SP804_ICR(TIMER_BASE), 0);
    }

    ///
    ///  オーバランタイマの動作開始
    ///
    ///  QEMUでは，ロードレジスタに0を設定すると警告メッセージが出るため，
    ///  1を設定するようにしている．
    ///
    pub fn start(ovrtim: PRCTIM) void {
        if (TOPPERS_USE_QEMU and ovrtim == 0) {
            sil.wrw_mem(SP804_LR(TIMER_BASE), 1);
        }
        else {
            sil.wrw_mem(SP804_LR(TIMER_BASE), @as(u32, ovrtim));
        }
        sil.wrw_mem(SP804_CR(TIMER_BASE), SP804_ENABLE | SP804_CONFIG);
    }

    ///
    ///  オーバランタイマの停止
    ///
    pub fn stop() PRCTIM {
        sil.wrw_mem(SP804_CR(TIMER_BASE), SP804_DISABLE | SP804_CONFIG);
        sil.wrw_mem(SP804_ICR(TIMER_BASE), 0);
        return @as(PRCTIM, sil.rew_mem(SP804_CVR(TIMER_BASE)));
    }

    ///
    ///  オーバランタイマの現在値の読出し
    ///
    pub fn get_current() PRCTIM {
        return @as(PRCTIM, sil.rew_mem(SP804_CVR(TIMER_BASE)));
    }

    ///
    ///  オーバランタイマ割込みハンドラ
    ///
    pub fn handler() void {
        sil.wrw_mem(SP804_ICR(TIMER_BASE), 0);
        overrun.call_ovrhdr();      // オーバランハンドラの起動処理
    }
};

///
///  タイマモジュールからexportする関数
///
pub const ExportDefs = struct {
    //
    //  システムコンフィギュレーションファイルに記述する関数
    //
    // 高分解能タイマの起動処理
    export fn _kernel_target_hrt_initialize(exinf: EXINF) void {
        hrt.initialize();
    }

    // 高分解能タイマの停止処理
    export fn _kernel_target_hrt_terminate(exinf: EXINF) void {
        hrt.terminate();
    }

    // 高分解能タイマ割込みハンドラ
    export fn _kernel_target_hrt_handler() void {
        hrt.handler();
    }

    // オーバランタイマの初期化処理
    export fn _kernel_target_ovrtimer_initialize(exinf: EXINF) void {
        ovrtimer.initialize();
    }

    // オーバランタイマの停止処理
    export fn _kernel_target_ovrtimer_terminate(exinf: EXINF) void {
        ovrtimer.terminate();
    }

    // オーバランタイマ割込みハンドラ
    export fn _kernel_target_ovrtimer_handler() void {
        ovrtimer.handler();
    }
};

///
///  タイマモジュールからexportする関数を参照するための定義
///
pub const ExternDefs = struct {
    pub extern fn _kernel_target_hrt_initialize(exinf: EXINF) void;
    pub extern fn _kernel_target_hrt_terminate(exinf: EXINF) void;
    pub extern fn _kernel_target_hrt_handler() void;
    pub extern fn _kernel_target_ovrtimer_initialize(exinf: EXINF) void;
    pub extern fn _kernel_target_ovrtimer_terminate(exinf: EXINF) void;
    pub extern fn _kernel_target_ovrtimer_handler() void;
};
