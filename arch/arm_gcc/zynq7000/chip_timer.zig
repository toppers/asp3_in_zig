///
///  タイマドライバ（Zynq7000用）
///
usingnamespace @import("../../../kernel/kernel_impl.zig");

///
///  コンフィギュレーションオプションの取り込み
///
const MPCORE_GTC_PS_VALUE = option.target.MPCORE_GTC_PS_VALUE;
const MPCORE_GTC_FREQ = option.target.MPCORE_GTC_FREQ;
const MPCORE_WDG_PS_VALUE = option.target.MPCORE_WDG_PS_VALUE;
const MPCORE_WDG_FREQ = option.target.MPCORE_WDG_FREQ;

///
///  高分解能タイマドライバ
///
///  MPCoreのグローバルタイマを用いて高分解能タイマを実現する．
///
const mpcore_timer = @import("../common/mpcore_timer.zig");

///
///  高分解能タイマドライバのインスタンシエート
///
pub const hrt = mpcore_timer.GTC_HRT(.{
    .GTC_PS_VALUE = MPCORE_GTC_PS_VALUE,
    .GTC_FREQ     = MPCORE_GTC_FREQ,
});

///
///  オーバランタイマドライバ
///
///  MPCoreのウォッチドッグを用いてオーバランタイマを実現する．
///
usingnamespace @import("../common/mpcore_timer.zig");

///
///  オーバランタイマドライバのインスタンシエート
///
pub const ovrtimer = mpcore_timer.WDG_OVRTIMER(.{
    .WDG_PS_VALUE = MPCORE_WDG_PS_VALUE,
    .WDG_FREQ     = MPCORE_WDG_FREQ,
});

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

    //
    //  システムログ機能用の関数
    //
    // 高分解能タイマの現在のカウント値の読出し
    export fn _kernel_target_hrt_get_current() HRTCNT {
        return hrt.get_current();
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
