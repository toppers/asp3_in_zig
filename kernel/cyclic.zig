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
///  周期通知機能
///
usingnamespace @import("kernel_impl.zig");
usingnamespace time_event;
usingnamespace check;

///
///  周期通知初期化ブロック
///
pub const CYCINIB = struct {
    cycatr: ATR,                // 周期通知属性
    exinf: EXINF,               // 通知ハンドラの拡張情報
    nfyhdr: NFYHDR,             // 通知ハンドラの起動番地
    cyctim: RELTIM,             // 周期通知の起動周期
    cycphs: RELTIM,             // 周期通知の起動位相
};

///
///  周期通知管理ブロック
///
///  次に周期通知を起動する時刻は，タイムイベントブロック（tmevtb）中
///  のタイムイベントの発生時刻（evttim）で保持する．
///
pub const CYCCB = struct {
    p_cycinib: *const CYCINIB,  // 初期化ブロックへのポインタ
    cycsta: bool,               // 周期通知の動作状態
    tmevtb: TMEVTB,             // タイムイベントブロック
};

///
///  周期通知に関するコンフィギュレーションデータの取り込み
///
pub const ExternCycCfg = struct {
    ///
    ///  周期通知IDの最大値
    ///
    pub extern const _kernel_tmax_cycid: ID;

    ///
    ///  周期通知初期化ブロックのエリア
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern const _kernel_cycinib_table: [100]CYCINIB;

    ///
    ///  周期通知管理ブロックのエリア
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern var _kernel_cyccb_table: [100]CYCCB;
};

///
///  周期通知の数
///
fn numOfCyc() usize {
    return @intCast(usize, cfg._kernel_tmax_cycid - TMIN_CYCID + 1);
}

///
///  周期通知IDから周期通知管理ブロックを取り出すための関数
///
fn indexCyc(cycid: ID) usize {
    return @intCast(usize, cycid - TMIN_CYCID);
}
fn checkAndGetCycCB(cycid: ID) ItronError!*CYCCB {
    try checkId(TMIN_CYCID <= cycid and cycid <= cfg._kernel_tmax_cycid);
    return &cfg._kernel_cyccb_table[indexCyc(cycid)];
}

///
///  周期通知機能の初期化
///
pub fn initialize_cyclic() void {
    for (cfg._kernel_cyccb_table[0 .. numOfCyc()]) |*p_cyccb, i| {
        p_cyccb.p_cycinib = &cfg._kernel_cycinib_table[i];
        p_cyccb.tmevtb.callback = callCyclic;
        p_cyccb.tmevtb.arg = @ptrToInt(p_cyccb);
        if ((p_cyccb.p_cycinib.cycatr & TA_STA) != 0) {
            // 初回の起動のためのタイムイベントを登録する［ASPD1035］
            // ［ASPD1062］．
            p_cyccb.cycsta = true;
            p_cyccb.tmevtb.evttim = @intCast(EVTTIM,
                                             p_cyccb.p_cycinib.cycphs);
            tmevtb_register(&p_cyccb.tmevtb);
        }
        else {
            p_cyccb.cycsta = false;
        }
    }
}

///
///  周期通知の動作開始
///
pub fn sta_cyc(cycid: ID) ItronError!void {
    traceLog("staCycEnter", .{ cycid });
    errdefer |err| traceLog("staCycLeave", .{ err });
    try checkContextTaskUnlock();
    const p_cyccb = try checkAndGetCycCB(cycid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (p_cyccb.cycsta) {
            tmevtb_dequeue(&p_cyccb.tmevtb);
        }
        else {
            p_cyccb.cycsta = true;
        }

        // 初回の起動のためのタイムイベントを登録する［ASPD1036］．
        tmevtb_enqueue_reltim(&p_cyccb.tmevtb, p_cyccb.p_cycinib.cycphs);
    }
    traceLog("staCycLeave", .{ null });
}

///
/// 周期通知の動作停止
///
pub fn stp_cyc(cycid: ID) ItronError!void {
    traceLog("stpCycEnter", .{ cycid });
    errdefer |err| traceLog("stpCycLeave", .{ err });
    try checkContextTaskUnlock();
    const p_cyccb = try checkAndGetCycCB(cycid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (p_cyccb.cycsta) {
            p_cyccb.cycsta = false;
            tmevtb_dequeue(&p_cyccb.tmevtb);
        }
    }
    traceLog("stpCycLeave", .{ null });
}

///
///  周期通知の状態参照
///
pub fn ref_cyc(cycid: ID, pk_rcyc: *T_RCYC) ItronError!void {
    traceLog("refCycEnter", .{ cycid, pk_rcyc });
    errdefer |err| traceLog("refCycLeave", .{ err, pk_rcyc });
    try checkContextTaskUnlock();
    const p_cyccb = try checkAndGetCycCB(cycid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (p_cyccb.cycsta) {
            pk_rcyc.cycstat = TCYC_STA;
            pk_rcyc.lefttim = tmevt_lefttim(&p_cyccb.tmevtb);
        }
        else {
            pk_rcyc.cycstat = TCYC_STP;
        }
    }
    traceLog("refCycLeave", .{ null, pk_rcyc });
}

///
///  周期通知起動ルーチン
///
fn callCyclic(arg: usize) void {
    const p_cyccb = @intToPtr(*CYCCB, arg);

    // 次回の起動のためのタイムイベントを登録する［ASPD1037］．
    p_cyccb.tmevtb.evttim += p_cyccb.p_cycinib.cyctim;      //［ASPD1038］
    tmevtb_register(&p_cyccb.tmevtb);

    // 通知ハンドラを，CPUロック解除状態で呼び出す．
    target_impl.unlockCpu();

    traceLog("cyclicEnter", .{ p_cyccb });
    p_cyccb.p_cycinib.nfyhdr(p_cyccb.p_cycinib.exinf);
    traceLog("cyclicLeave", .{ p_cyccb });

    if (!target_impl.senseLock()) {
        target_impl.lockCpu();
    }
}

///
///  周期通知の生成（静的APIの処理）
///
pub fn cre_cyc(comptime ccyc: T_CCYC) ItronError!CYCINIB {
    // cycatrが無効の場合（E_RSATR）［NGKI2383］［NGKI2370］［ASPS0172］
    //（TA_STA以外のビットがセットされている場合）
    try checkValidAtr(ccyc.cycatr, TA_STA);

    // cyctimが有効範囲外の場合（E_PAR）［NGKI2397］
    //（0 < cyctim && cyctim <= TMAX_RELTIMでない場合）
    try checkParameter(0 < ccyc.cyctim and validRelativeTime(ccyc.cyctim));

    // cycphsが有効範囲外の場合（E_PAR）［NGKI2399］
    //（0 <= cycphs && cycphs <= TMAX_RELTIMでない場合）
    try checkParameter(validRelativeTime(ccyc.cycphs));

    // 周期通知初期化ブロックの生成
    return CYCINIB{ .cycatr = ccyc.cycatr | notify.genFlag(ccyc.nfyinfo),
                    .exinf = notify.genExinf(ccyc.nfyinfo),
                    .nfyhdr = notify.genHandler(ccyc.nfyinfo),
                    .cyctim = ccyc.cyctim,
                    .cycphs = ccyc.cycphs, };
}

///
///  周期通知に関するコンフィギュレーションデータのの生成（静的APIの処理）
///
pub fn ExportCycCfg(cycinib_table: []CYCINIB) type {
    // チェック処理用の定義の生成
    exportCheck(@sizeOf(CYCINIB), "sizeof_CYCINIB");
    exportCheck(@byteOffsetOf(CYCINIB, "cycatr"), "offsetof_CYCINIB_cycatr");
    exportCheck(@byteOffsetOf(CYCINIB, "exinf"), "offsetof_CYCINIB_exinf");
    exportCheck(@byteOffsetOf(CYCINIB, "nfyhdr"), "offsetof_CYCINIB_nfyhdr");

    const tnum_cyc = cycinib_table.len;
    return struct {
        pub export const _kernel_tmax_cycid: ID = tnum_cyc;
        pub export const _kernel_cycinib_table = cycinib_table[0 .. tnum_cyc].*;
        pub export var _kernel_cyccb_table: [tnum_cyc]CYCCB = undefined;
    };
}
