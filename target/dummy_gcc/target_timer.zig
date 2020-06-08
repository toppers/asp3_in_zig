///
///  タイマドライバ（ダミーターゲット用）
///
usingnamespace @import("../../kernel/kernel_impl.zig");

///
///  ハードウェア資源の定義
///
const dummy = @import("dummy.zig");

///
///  高分解能タイマドライバ
///
pub const hrt = struct {
    ///
    ///  高分解能タイマ割込みハンドラ登録のための定数
    ///
    pub const INHNO_HRT = dummy.TINTNO_HRT;     // 割込みハンドラ番号
    pub const INTNO_HRT = dummy.TINTNO_HRT;     // 割込み番号
    pub const INTPRI_HRT = TMAX_INTPRI - 1;     // 割込み優先度
    pub const INTATR_HRT = TA_EDGE;             // 割込み属性

    ///
    ///  タイマの起動処理
    ///
    pub fn initialize() void {}

    ///
    ///  タイマの停止処理
    ///
    pub fn terminate() void {}

    ///
    ///  高分解能タイマの現在のカウント値の読出し
    ///
    pub fn get_current() HRTCNT { return 0; }

    ///
    ///  高分解能タイマへの割込みタイミングの設定
    ///
    pub fn set_event(hrtcnt: HRTCNT) void {}

    ///
    ///  高分解能タイマ割込みの要求
    ///
    pub fn raise_event() void {}

    ///
    ///  タイマ割込みハンドラ
    ///
    pub fn handler() void {
        // 高分解能タイマ割込みを処理する．
        time_event.signal_time();
    }

    ///
    ///  割込みタイミングに指定する最大値
    ///
    pub const HRTCNT_BOUND = 4_000_000_002;
};

///
///  オーバランタイマドライバ
///
pub const ovrtimer = struct {
    ///
    ///  オーバランタイマ割込みハンドラ登録のための定数
    ///
    pub const INHNO_OVRTIMER = dummy.TINTNO_OVRTIMER;   // 割込みハンドラ番号
    pub const INTNO_OVRTIMER = dummy.TINTNO_OVRTIMER;   // 割込み番号
    pub const INTPRI_OVRTIMER = TMAX_INTPRI;            // 割込み優先度
    pub const INTATR_OVRTIMER = TA_EDGE;                // 割込み属性

    ///
    ///  オーバランタイマの初期化処理
    ///
    pub fn initialize() void {}

    ///
    ///  オーバランタイマの停止処理
    ///
    pub fn terminate() void {}

    ///
    ///  オーバランタイマの動作開始
    ///
    pub fn start(ovrtim: PRCTIM) void {}

    ///
    ///  オーバランタイマの停止
    ///
    pub fn stop() PRCTIM { return 0; }

    ///
    ///  オーバランタイマの現在値の読出し
    ///
    pub fn get_current() PRCTIM { return 0; }

    ///
    ///  オーバランタイマ割込みハンドラ
    ///
    pub fn handler() void {
        // オーバランハンドラの起動処理
        overrun.call_ovrhdr();
    }
};

///
///  システムコンフィギュレーションファイルに記述する関数
///

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
