///
///  タイマドライバ（RZ/A1 OSタイマ用）
///
///  RZ/A1は2チャンネルのOSタイマを持つが，その内の1つを用いて高分解能
///  タイマを，もう1つを用いてオーバランタイマを実現する．
///
usingnamespace @import("../../../kernel/kernel_impl.zig");

///
///  RZ/A1のハードウェア資源の定義
///
const rza1 = @import("rza1.zig");

//
//  OSタイマの周波数の想定値のチェック
//
//  現在の実装は，クロックが33.33…MHzの場合のみに対応している．
//
comptime {
    if (rza1.OSTM_CLK != 33333333) {
        @compileError("Unsupported OS time clock.");
    }
}

///
///  OSタイマレジスタの番地の定義
///
fn OSTM_CMP(base: usize) *u32 {
    return @intToPtr(*u32, base + 0x00);
}
fn OSTM_CNT(base: usize) *u32 {
    return @intToPtr(*u32, base + 0x04);
}
fn OSTM_TE(base: usize) *u8 {
    return @intToPtr(*u8, base + 0x10);
}
fn OSTM_TS(base: usize) *u8 {
    return @intToPtr(*u8, base + 0x14);
}
fn OSTM_TT(base: usize) *u8 {
    return @intToPtr(*u8, base + 0x18);
}
fn OSTM_CTL(base: usize) *u8 {
    return @intToPtr(*u8, base + 0x20);
}

///
///  OSタイマ カウント開始トリガレジスタの設定値の定義
///
const OSTM_TS_START = 0x01;

///
///  OSタイマ カウント停止トリガレジスタの設定値の定義
///
const OSTM_TT_STOP = 0x01;

///
///  OSタイマ 制御レジスタの設定値の定義
///
const OSTM_CTL_INTERVAL = 0x00;     // インターバルタイマモード
const OSTM_CTL_FRCMP    = 0x02;     // フリーランニングコンペアモード

///
///  高分解能タイマドライバ
///
pub const hrt = struct {
    ///
    ///  高分解能タイマ割込みハンドラ登録のための定数
    ///
    pub const INHNO_HRT  = rza1.INTNO_OSTM0;        // 割込みハンドラ番号
    pub const INTNO_HRT  = rza1.INTNO_OSTM0;        // 割込み番号
    pub const INTPRI_HRT = TMAX_INTPRI - 1;         // 割込み優先度
    pub const INTATR_HRT = TA_EDGE;                 // 割込み属性

    // TCYC_HRTCNTの定義のチェック
    comptime {
        if (TCYC_HRTCNT == null or TCYC_HRTCNT.? != 128_849_019) {
            @compileError("unexpected TCYC_HRTCNT value.");
        }
    }

    ///
    ///  タイマの起動処理
    ///
    pub fn initialize() void {
        // OSタイマをフリーランニングコンペアモードに設定する．
        sil.wrb_mem(OSTM_CTL(rza1.OSTM0_BASE), OSTM_CTL_FRCMP);

        // OSタイマの設定値を最大値にしておく．
        sil.wrw_mem(OSTM_CMP(rza1.OSTM0_BASE), 0xffffffff);

        // OSタイマを動作開始する．
        sil.wrb_mem(OSTM_TS(rza1.OSTM0_BASE), OSTM_TS_START);

        // タイマ割込み要求をクリアする．
        target_impl.clearInt(rza1.INTNO_OSTM0);
    }

    ///
    ///  タイマの停止処理
    ///
    pub fn terminate() void {
        // OSタイマを停止する．
        sil.wrb_mem(OSTM_TT(rza1.OSTM0_BASE), OSTM_TT_STOP);

        // タイマ割込み要求をクリアする．
        target_impl.clearInt(rza1.INTNO_OSTM0);
    }

    ///
    ///  高分解能タイマの現在のカウント値の読出し
    ///
    pub fn get_current() HRTCNT {
        const cnt = sil.rew_mem(OSTM_CNT(rza1.OSTM0_BASE));

        // μ秒単位に変換（クロックが33.33…MHzである前提）
        const cnt1 = cnt / 1000000000;
        return @intCast(HRTCNT, (cnt - cnt1 * 999999999) * 3 / 100
                            + cnt1 * 30000000);
    }

    ///
    ///  高分解能タイマへの割込みタイミングの設定
    ///
    ///  高分解能タイマを，hrtcntで指定した値カウントアップしたら割込みを
    ///  発生させるように設定する．
    ///
    pub fn set_event(hrtcnt: HRTCNT) void {
        const cnt = @intCast(u32, hrtcnt * 33 + hrtcnt / 3 + 1);

        // 現在のカウント値を読み，hrtcnt後に割込みが発生するように設定する．
        const current = sil.rew_mem(OSTM_CNT(rza1.OSTM0_BASE));
        sil.wrw_mem(OSTM_CMP(rza1.OSTM0_BASE), current + cnt);

        // 上で現在のカウント値を読んで以降に，cnt以上カウントアップしてい
        // た場合には，割込みを発生させる．
        if (sil.rew_mem(OSTM_CNT(rza1.OSTM0_BASE)) - current >= cnt) {
            target_impl.raiseInt(rza1.INTNO_OSTM0);
        }
    }

    ///
    ///  高分解能タイマ割込みの要求
    ///
    pub fn raise_event() void {
        target_impl.raiseInt(rza1.INTNO_OSTM0);
    }

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
    pub const HRTCNT_BOUND = 100000002;
};

///
///  オーバランタイマドライバ
///
pub const ovrtimer = struct {
    ///
    ///  オーバランタイマ割込みハンドラ登録のための定数
    ///
    pub const INHNO_OVRTIMER  = rza1.INTNO_OSTM1;   // 割込みハンドラ番号
    pub const INTNO_OVRTIMER  = rza1.INTNO_OSTM1;   // 割込み番号
    pub const INTPRI_OVRTIMER = TMAX_INTPRI;        // 割込み優先度
    pub const INTATR_OVRTIMER = TA_EDGE;            // 割込み属性

    ///
    ///  オーバランタイマの初期化処理
    ///
    pub fn initialize() void {
        // OSタイマをインターバルタイマモードに設定する．
        sil.wrb_mem(OSTM_CTL(rza1.OSTM1_BASE), OSTM_CTL_INTERVAL);

        // オーバランタイマ割込み要求をクリアする．
        target_impl.clearInt(rza1.INTNO_OSTM1);
    }

    ///
    ///  オーバランタイマの停止処理
    ///
    pub fn terminate() void {
        // OSタイマを停止する．
        sil.wrb_mem(OSTM_TT(rza1.OSTM1_BASE), OSTM_TT_STOP);

        // オーバランタイマ割込み要求をクリアする．
        target_impl.clearInt(rza1.INTNO_OSTM1);
    }

    ///
    ///  オーバランタイマの動作開始
    ///
    pub fn start(ovrtim: PRCTIM) void {
        const cnt = @intCast(u32, ovrtim * 33 + ovrtim / 3 + 1);
        sil.wrw_mem(OSTM_CMP(rza1.OSTM1_BASE), cnt);
        sil.wrb_mem(OSTM_TS(rza1.OSTM1_BASE), OSTM_TS_START);
    }

    ///
    ///  オーバランタイマの停止
    ///
    pub fn stop() PRCTIM {
        // OSタイマを停止する．
        sil.wrb_mem(OSTM_TT(rza1.OSTM1_BASE), OSTM_TT_STOP);

        if (target_impl.probeInt(rza1.INTNO_OSTM1)) {
            // 割込み要求が発生している場合
            target_impl.clearInt(rza1.INTNO_OSTM1);
            return 0;
        }
        else {
            const cnt = sil.rew_mem(OSTM_CNT(rza1.OSTM1_BASE));
            return @intCast(PRCTIM, (cnt + 34) / 5 * 3 / 20);
        }
    }

    ///
    ///  オーバランタイマの現在値の読出し
    ///
    pub fn get_current() PRCTIM {
        if (target_impl.probeInt(rza1.INTNO_OSTM1)) {
            // 割込み要求が発生している場合
            return 0;
        }
        else {
            const cnt = sil.rew_mem(OSTM_CNT(rza1.OSTM1_BASE));
            return @intCast(PRCTIM, (cnt + 34) / 5 * 3 / 20);
        }
    }

    ///
    ///  オーバランタイマ割込みハンドラ
    ///
    ///  このルーチンに来るまでに，stopが呼ばれているため，OSタイマを
    ///  停止する必要はない．
    ///
    pub fn handler() void {
        // オーバランハンドラの起動処理
        if (TOPPERS_SUPPORT_OVRHDR) {
            overrun.call_ovrhdr();
        }
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
