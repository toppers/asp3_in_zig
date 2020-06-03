///
///  TOPPERS/ASP Kernel
///      Toyohashi Open Platform for Embedded Real-Time Systems/
///      Advanced Standard Profile Kernel
/// 
///  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
///                                 Toyohashi Univ. of Technology, JAPAN
///  Copyright (C) 2005-2020 by Embedded and Real-Time Systems Laboratory
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
///  アラーム通知機能
///
usingnamespace @import("kernel_impl.zig");
usingnamespace time_event;
usingnamespace check;

///
///  アラーム通知初期化ブロック
///
pub const ALMINIB = struct {
    almatr: ATR,                // アラーム通知属性
    exinf: EXINF,               // 通知ハンドラの拡張情報
    nfyhdr: NFYHDR,             // 通知ハンドラの起動番地
};

///
///  アラーム通知管理ブロック
///
pub const ALMCB = struct {
    p_alminib: *const ALMINIB,  // 初期化ブロックへのポインタ
    almsta: bool,               // アラーム通知の動作状態
    tmevtb: TMEVTB,             // タイムイベントブロック
};

///
///  アラーム通知に関するコンフィギュレーションデータの取り込み
///
pub const ExternAlmCfg = struct {
    ///
    ///  アラーム通知IDの最大値
    ///
    pub extern const _kernel_tmax_almid: ID;

    ///
    ///  アラーム通知初期化ブロックのエリア
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern const _kernel_alminib_table: [100]ALMINIB;

    ///
    ///  アラーム通知管理ブロックのエリア
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern var _kernel_almcb_table: [100]ALMCB;
};

///
///  アラーム通知の数
///
fn numOfAlm() usize {
    return @intCast(usize, cfg._kernel_tmax_almid - TMIN_ALMID + 1);
}

///
///  アラーム通知IDからアラーム通知管理ブロックを取り出すための関数
///
fn indexAlm(almid: ID) usize {
    return @intCast(usize, almid - TMIN_ALMID);
}
fn checkAndGetAlmCB(almid: ID) ItronError!*ALMCB {
    try checkId(TMIN_ALMID <= almid and almid <= cfg._kernel_tmax_almid);
    return &cfg._kernel_almcb_table[indexAlm(almid)];
}

///
///  アラーム通知機能の初期化
///
pub fn initialize_alarm() void {
    for (cfg._kernel_almcb_table[0 .. numOfAlm()]) |*p_almcb, i| {
        p_almcb.p_alminib = &cfg._kernel_alminib_table[i];
        p_almcb.almsta = false;
        p_almcb.tmevtb.callback = callAlarm;
        p_almcb.tmevtb.arg = @ptrToInt(p_almcb);
    }
}

///
///  アラーム通知の動作開始
///
pub fn sta_alm(almid: ID, almtim: RELTIM) ItronError!void {
    traceLog("staAlmEnter", .{ almid, almtim });
    errdefer |err| traceLog("staAlmLeave", .{ err });
    try checkContextUnlock();
    const p_almcb = try checkAndGetAlmCB(almid);
    try checkParameter(validRelativeTime(almtim));
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (p_almcb.almsta) {
            tmevtb_dequeue(&p_almcb.tmevtb);
        }
        else {
            p_almcb.almsta = true;
        }
        tmevtb_enqueue_reltim(&p_almcb.tmevtb, almtim);
    }
    traceLog("staAlmLeave", .{ null });
}

///
///  アラーム通知の動作停止
///
pub fn stp_alm(almid: ID) ItronError!void {
    traceLog("stpAlmEnter", .{ almid });
    errdefer |err| traceLog("stpAlmLeave", .{ err });
    try checkContextUnlock();
    const p_almcb = try checkAndGetAlmCB(almid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (p_almcb.almsta) {
            p_almcb.almsta = false;
            tmevtb_dequeue(&p_almcb.tmevtb);
        }
    }
    traceLog("stpAlmLeave", .{ null });
}

///
///  アラーム通知の状態参照
///
pub fn ref_alm(almid: ID, pk_ralm: *T_RALM) ItronError!void {
    traceLog("refAlmEnter", .{ almid, pk_ralm });
    errdefer |err| traceLog("refAlmLeave", .{ err, pk_ralm });
    try checkContextTaskUnlock();
    const p_almcb = try checkAndGetAlmCB(almid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (p_almcb.almsta) {
            pk_ralm.almstat = TALM_STA;
            pk_ralm.lefttim = tmevt_lefttim(&p_almcb.tmevtb);
        }
        else {
            pk_ralm.almstat = TALM_STP;
        }
    }
    traceLog("refAlmLeave", .{ null, pk_ralm });
}

///
///  アラーム通知起動ルーチン
///
fn callAlarm(arg: usize) void {
    const p_almcb = @intToPtr(*ALMCB, arg);

    // アラーム通知を停止状態にする．
    p_almcb.almsta = false;

    // 通知ハンドラを，CPUロック解除状態で呼び出す．
    target_impl.unlockCpu();

    traceLog("alarmEnter", .{ p_almcb });
    p_almcb.p_alminib.nfyhdr(p_almcb.p_alminib.exinf);
    traceLog("alarmLeave", .{ p_almcb });

    if (!target_impl.senseLock()) {
        target_impl.lockCpu();
    }
}

///
///  アラーム通知の生成（静的APIの処理）
///
pub fn cre_alm(comptime calm: T_CALM) ItronError!ALMINIB {
    // almatrが無効の場合（E_RSATR）［NGKI2491］［NGKI3423］［NGKI3424］
    //（TA_NULLでない場合）
    try checkValidAtr(calm.almatr, TA_NULL);

    // アラーム通知初期化ブロックの生成
    return ALMINIB{ .almatr = calm.almatr | notify.genFlag(calm.nfyinfo),
                    .exinf = notify.genExinf(calm.nfyinfo),
                    .nfyhdr = notify.genHandler(calm.nfyinfo), };
}

///
///  アラーム通知に関するコンフィギュレーションデータの生成（静的APIの
///  処理）
///
pub fn ExportAlmCfg(alminib_table: []ALMINIB) type {
    // チェック処理用の定義の生成
    exportCheck(@sizeOf(ALMINIB), "sizeof_ALMINIB");
    exportCheck(@byteOffsetOf(ALMINIB, "almatr"), "offsetof_ALMINIB_almatr");
    exportCheck(@byteOffsetOf(ALMINIB, "exinf"), "offsetof_ALMINIB_exinf");
    exportCheck(@byteOffsetOf(ALMINIB, "nfyhdr"), "offsetof_ALMINIB_nfyhdr");

    const tnum_alm = alminib_table.len;
    return struct {
        pub export const _kernel_tmax_almid: ID = tnum_alm;
        pub export const _kernel_alminib_table = alminib_table[0 .. tnum_alm].*;
        pub export var _kernel_almcb_table: [tnum_alm]ALMCB = undefined;
    };
}
