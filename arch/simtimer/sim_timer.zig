///
///  TOPPERS Software
///      Toyohashi Open Platform for Embedded Real-Time Systems
/// 
///  Copyright (C) 2018-2020 by Embedded and Real-Time Systems Laboratory
///                 Graduate School of Informatics, Nagoya Univ., JAPAN
///
///  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
///  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
///  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
///  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
///      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
///      スコード中に含まれていること．
///  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
///      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
///      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
///      の無保証規定を掲載すること．
///  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
///      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
///      と．
///    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
///        作権表示，この利用条件および下記の無保証規定を掲載すること．
///    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
///        報告すること．
///  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
///      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
///      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
///      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
///      免責すること．
///
///  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
///  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
///  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
///  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
///  の責任を負わない．
///
///  $Id$
///

///
///  タイマドライバシミュレータ
///
usingnamespace @import("../../kernel/kernel_impl.zig");

///
///  コンパイルオプションによるマクロ定義の取り込み
///
const opt = @cImport({});
const HRT_CONFIG1 = @hasDecl(opt, "HRT_CONFIG1");
const HRT_CONFIG2 = @hasDecl(opt, "HRT_CONFIG2");
const HRT_CONFIG3 = @hasDecl(opt, "HRT_CONFIG3");
const HOOK_HRT_EVENT = @hasDecl(opt, "HOOK_HRT_EVENT");

///
///  シミュレート時間の初期値
///
const SIMTIM_INIT_CURRENT =
    if (@hasDecl(target_impl, "SIMTIM_INIT_CURRENT"))
         target_impl.SIMTIM_INIT_CURRENT
    else 10;

///
///  高分解能タイマ割込みの受付オーバヘッド
///
const SIMTIM_OVERHEAD_HRTINT =
    if (@hasDecl(target_impl, "SIMTIM_OVERHEAD_HRTINT"))
         target_impl.SIMTIM_OVERHEAD_HRTINT
    else 10;

///
///  オーバランタイマ割込みの受付オーバヘッド
///
const SIMTIM_OVERHEAD_OVRINT =
    if (@hasDecl(target_impl, "SIMTIM_OVERHEAD_OVRINT"))
         target_impl.SIMTIM_OVERHEAD_OVRINT
    else 10;

///
///  テストのためのフックルーチン
///
extern fn _kernel_hook_hrt_set_event(hrtcnt: HRTCNT) void;
extern fn _kernel_hook_hrt_clear_event() void;
extern fn _kernel_hook_hrt_raise_event() void;

///
///  シミュレーション時間のデータ型の定義
///
const SIMTIM = u64;

///
///  タイマ割込みの発生時刻の設定状況
///
const INT_EVENT = struct {
    enable: bool,               // 発生時刻が設定されているか？
    simtim: SIMTIM,             // 発生時刻
    raise: fn() void,           // タイマ割込みの要求
} ;

///
///  現在のシミュレーション時刻
///
var current_simtim: SIMTIM = undefined;

///
///  高分解能タイマ割込みの発生時刻
///
var hrt_event: INT_EVENT = undefined;

///
///  シミュレーション時刻の丸め処理
///
fn truncate_simtim(simtim: SIMTIM) SIMTIM {
    return simtim / TSTEP_HRTCNT * TSTEP_HRTCNT;
}
fn roundup_simtim(simtim: SIMTIM) SIMTIM {
    return (simtim + TSTEP_HRTCNT - 1) / TSTEP_HRTCNT * TSTEP_HRTCNT;
}

///
///  高分解能タイマの操作関数
///
pub const hrt = struct {
    ///
    ///  高分解能タイマ割込みハンドラ登録のための定数
    ///
    pub const INHNO_HRT  = target_timer.INHNO_HRT;
    pub const INTNO_HRT  = target_timer.INTNO_HRT;
    pub const INTPRI_HRT = target_timer.INTPRI_HRT;
    pub const INTATR_HRT = target_timer.INTATR_HRT;

    ///
    ///  高分解能タイマの現在のカウント値の読出し
    ///
    pub fn get_current() HRTCNT {
        if (TCYC_HRTCNT) |tcyc_hrtcnt| {
            return @truncate(HRTCNT, truncate_simtim(current_simtim)
                                         % tcyc_hrtcnt);
        }
        else {
            return @truncate(HRTCNT, truncate_simtim(current_simtim));
        }
    }

    ///
    ///  高分解能タイマへの割込みタイミングの設定
    ///
    pub fn set_event(hrtcnt: HRTCNT) void {
        if (HOOK_HRT_EVENT) {
            _kernel_hook_hrt_set_event(hrtcnt);
        }
        hrt_event.enable = true;
        hrt_event.simtim = roundup_simtim(current_simtim + hrtcnt);
        select_event();
    }

    ///
    ///  高分解能タイマへの割込みタイミングのクリア
    ///
    pub fn clear_event() void {
        if (HOOK_HRT_EVENT) {
            _kernel_hook_hrt_clear_event();
        }
        hrt_event.enable = false;
        select_event();
    }

    ///
    ///  高分解能タイマ割込みの要求
    ///
    pub fn raise_event() void {
        if (HOOK_HRT_EVENT) {
            _kernel_hook_hrt_raise_event();
        }
        target_timer.raise_hrt_int();
    }

    ///
    ///  シミュレートされた高分解能タイマ割込みハンドラ
    ///
    pub fn handler() void {
        current_simtim += SIMTIM_OVERHEAD_HRTINT;
        time_event.signal_time();
    }

    ///
    ///  割込みタイミングに指定する最大値
    ///
    pub const HRTCNT_BOUND: ?comptime_int =
        if (HRT_CONFIG1) 4000000002
        else if (HRT_CONFIG2) 0x10000 * 9
        else if (HRT_CONFIG3) null
        else @compileError("");
};

///
///  オーバランタイマ割込みの発生時刻
///
var ovr_event: INT_EVENT = undefined;

///
///  オーバランタイマの操作関数
///
pub const ovrtimer = struct {
    ///
    ///  オーバランタイマ割込みハンドラ登録のための定数
    ///
    pub const INHNO_OVRTIMER  = target_timer.INHNO_OVRTIMER;
    pub const INTNO_OVRTIMER  = target_timer.INTNO_OVRTIMER;
    pub const INTPRI_OVRTIMER = target_timer.INTPRI_OVRTIMER;
    pub const INTATR_OVRTIMER = target_timer.INTATR_OVRTIMER;

    ///
    ///  オーバランタイマの動作開始
    ///
    pub fn start(ovrtim: PRCTIM) void {
        if (ovrtim == 0) {
            ovr_event.enable = false;
            select_event();
            target_timer.raise_ovrtimer_int();
        }
        else {
            ovr_event.enable = true;
            ovr_event.simtim = current_simtim + ovrtim;
            select_event();
        }
    }

    ///
    ///  オーバランタイマの停止
    ///
    ///  ここでオーバランタイマ割込み要求をクリアすると，割込み源の特定に失
    ///  敗する（QEMUで確認．QEMUだけの問題か，実機にもある問題かは未確認）
    ///  ため，クリアしない．
    ///
    pub fn stop() PRCTIM {
        var ovrtim: PRCTIM = undefined;

        if (ovr_event.simtim <= current_simtim) {
            ovrtim = 0;
        }
        else {
            ovrtim = @intCast(PRCTIM, ovr_event.simtim - current_simtim);
        }
        ovr_event.enable = false;
        select_event();
        target_timer.clear_ovrtimer_int();
        return ovrtim;
    }

    ///
    ///  オーバランタイマの現在値の読出し
    ///
    pub fn get_current() PRCTIM {
        if (ovr_event.simtim <= current_simtim) {
            return 0;
        }
        else {
            return @intCast(PRCTIM, ovr_event.simtim - current_simtim);
        }
    }

    ///
    ///  シミュレートされたオーバランタイマ割込みハンドラ
    ///
    pub fn handler() void {
        current_simtim += SIMTIM_OVERHEAD_OVRINT;
        overrun.call_ovrhdr();
    }
};

///
///  最初に発生するタイマ割込みの情報
///
var p_next_event: ?*INT_EVENT = undefined;

///
///  タイマの起動処理
///
pub fn initialize() void {
    current_simtim = SIMTIM_INIT_CURRENT;
    hrt_event.enable = false;
    hrt_event.raise = target_timer.raise_hrt_int;
    if (TOPPERS_SUPPORT_OVRHDR) {
        ovr_event.enable = false;
        ovr_event.raise = target_timer.raise_ovrtimer_int;
    }
    p_next_event = null;
}

///
///  タイマの停止処理
///
pub fn terminate() void {
    hrt_event.enable = false;
    if (TOPPERS_SUPPORT_OVRHDR) {
        ovr_event.enable = false;
    }
}

///
///  最初に発生するタイマ割込みの選択
///
fn select_event() void {
    if (hrt_event.enable) {
        p_next_event = &hrt_event;
    }
    else {
        p_next_event = null;
    }
    if (TOPPERS_SUPPORT_OVRHDR
            and ovr_event.enable
            and (p_next_event == null
                     or ovr_event.simtim <= p_next_event.?.simtim)) {
        p_next_event = &ovr_event;
    }
}

///
///  カーネルのアイドル処理
///
fn custom_idle() void {
    target_impl.lockCpu();
    defer target_impl.unlockCpu();

    if (p_next_event) |next_event| {
        current_simtim = next_event.simtim;
        next_event.enable = false;
        next_event.raise();
        select_event();
    }
}

///
///  呼び出すC言語APIの宣言
///
extern fn loc_cpu() ER;
extern fn unl_cpu() ER;
extern fn sns_loc() c_int;

///
///  シミュレーション時刻を進める（テストプログラム用）
///
fn simtim_advance(time: c_uint) void {
    const locked = (sns_loc() != 0);
    if (!locked) {
        _ = loc_cpu();
    }
    defer {
        if (!locked) {
            _ = unl_cpu();
        }
    }

    var remain_time = time;
    while (p_next_event) |next_event| {
        if (next_event.simtim > current_simtim + remain_time) {
            break;
        }

        // 時刻をremain_time進めると，タイマ割込みの発生時刻を過ぎる場合
        if (current_simtim < next_event.simtim) {
            remain_time -= @intCast(c_uint, next_event.simtim - current_simtim);
            current_simtim = next_event.simtim;
        }
        next_event.enable = false;
        next_event.raise();
        select_event();

        // ここで割込みを受け付ける．
        if (!locked) {
            _ = unl_cpu();
            target_impl.delayForInterrupt();
            _ = loc_cpu();
        }
    }
    current_simtim += remain_time;
}

///
///  シミュレーション時刻を強制的に進める（テストプログラム用）
///
fn simtim_add(time: c_uint) void {
    var locked = (sns_loc() != 0);
    if (!locked) {
        _ = loc_cpu();
    }
    defer {
        if (!locked) {
            _ = unl_cpu();
        }
    }
    current_simtim += time;
}

///
///  タイマモジュールからexportする関数
///
pub const ExportDefs = struct {
    //
    //  カーネル内のアセンブリコードから呼び出す関数
    //

    // カーネルのアイドル処理
    export fn _kernel_target_custom_idle() void {
        custom_idle();
    }

    //
    //  システムコンフィギュレーションファイルに記述する関数
    //

    // タイマドライバシミュレータの起動処理
    export fn _kernel_target_timer_initialize(exinf: usize) void {
        initialize();
    }

    // タイマドライバシミュレータの停止処理
    export fn _kernel_target_timer_terminate(exinf: usize) void {
        terminate();
    }

    // 高分解能タイマ割込みハンドラ
    export fn _kernel_target_hrt_handler() void {
        hrt.handler();
    }

    // オーバランタイマ割込みハンドラ
    export fn _kernel_target_ovrtimer_handler() void {
        ovrtimer.handler();
    }

    ///
    ///  システムログ機能用の関数
    ///

    // 高分解能タイマの現在のカウント値の読出し
    export fn _kernel_target_hrt_get_current() HRTCNT {
        return hrt.get_current();
    }

    ///
    ///  テストプログラム用の関数と変数
    ///

    // シミュレーション時刻を進める
    export fn _kernel_simtim_advance(time: c_uint) void {
        simtim_advance(time);
    }

    // シミュレーション時刻を強制的に進める
    export fn _kernel_simtim_add(time: c_uint) void {
        simtim_add(time);
    }

    // シミュレートされた高分解能タイマ割込みの要求 
    export fn _kernel_target_raise_hrt_int() void {
        target_timer.raise_hrt_int();
    }

    // 最後に現在時刻を算出した時点での高分解能タイマのカウント値へのポインタ
    export const _kernel_p_current_hrtcnt: *HRTCNT = &time_event.current_hrtcnt;
};

///
///  タイマモジュールからexportする関数を参照するための定義
///
pub const ExternDefs = struct {
    pub extern fn _kernel_target_timer_initialize(exinf: EXINF) void;
    pub extern fn _kernel_target_timer_terminate(exinf: EXINF) void;
    pub extern fn _kernel_target_hrt_handler() void;
    pub extern fn _kernel_target_ovrtimer_handler() void;
};
