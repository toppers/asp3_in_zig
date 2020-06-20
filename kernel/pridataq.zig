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
///  優先度優先度データキュー機能
///
usingnamespace @import("kernel_impl.zig");
usingnamespace task;
usingnamespace wait;
usingnamespace time_event;
usingnamespace check;

///
///  優先度データ管理ブロック
///
const PDQMB = struct {
    p_next: ?*PDQMB,    // 次のデータ
    data: usize,        // データ本体
    datapri: PRI,       // データ優先度
};

///
///  優先度データキュー初期化ブロック
///
///  この構造体は，同期・通信オブジェクトの初期化ブロックの共通部分
///  （WOBJINIB）を拡張（オブジェクト指向言語の継承に相当）したもので，
///  最初のフィールドが共通になっている．
///
pub const PDQINIB = struct {
    wobjatr: ATR,               // 優先度データキュー属性
    pdqcnt: c_uint,             // 優先度データキューの容量
    maxdpri: PRI,               // データ優先度の最大値
    p_pdqmb: ?[*]PDQMB,         // 優先度データキュー管理領域
};

// 優先度データキュー初期化ブロックのチェック
comptime {
    checkWobjIniB(PDQINIB);
}

///
///  優先度データキュー管理ブロック
///
///  この構造体は，同期・通信オブジェクトの管理ブロックの共通部分
///  （WOBJCB）を拡張（オブジェクト指向言語の継承に相当）したもので，
///  最初の2つのフィールドが共通になっている．
///
const PDQCB = struct {
    swait_queue: queue.Queue,   // 優先度データキュー送信待ちキュー
    p_wobjinib: *const PDQINIB, // 初期化ブロックへのポインタ
    rwait_queue: queue.Queue,   // 優先度データキュー受信待ちキュー
    count: c_uint,              // 優先度データキュー中のデータの数
    p_head: ?*PDQMB,            // 最初のデータ
    unused: c_uint,             // 未使用データ管理ブロックの先頭
    p_freelist: ?*PDQMB,        // 未割当てデータ管理ブロックのリスト
};

// 優先度データキュー管理ブロックのチェック
comptime {
    checkWobjCB(PDQCB);
}

///
///  優先度データキュー待ち情報ブロックの定義
///
///  この構造体は，同期・通信オブジェクトの待ち情報ブロックの共通部分
///  （WINFO_WOBJ）を拡張（オブジェクト指向言語の継承に相当）したもの
///  で，最初の2つのフィールドが共通になっている．
///
const WINFO_SPDQ = struct {
    winfo: WINFO,               // 標準の待ち情報ブロック
    p_wobjcb: *PDQCB,           // 待っている優先度データキューの管理ブロック
    data: usize,                // 送信データ
    datapri: PRI,               // データ優先度
};

const WINFO_RPDQ = struct {
    winfo: WINFO,               // 標準の待ち情報ブロック
    p_wobjcb: *PDQCB,           // 待っている優先度データキューの管理ブロック
    data: usize,                // 受信データ
    datapri: PRI,               // データ優先度
};

// 優先度データキュー待ち情報ブロックのチェック
comptime {
    checkWinfoWobj(WINFO_SPDQ);
    checkWinfoWobj(WINFO_RPDQ);
}

///
///  優先度データキューに関するコンフィギュレーションデータの取り込み
///
pub const ExternPdqCfg = struct {
    ///
    ///  優先度データキュー初期化ブロック（スライス）
    ///
    pub extern const _kernel_pdqinib_table: []PDQINIB;

    ///
    ///  優先度データキュー管理ブロックのエリア
    ///
    // Zigの制限事項の回避：十分に大きいサイズの配列とする
    pub extern var _kernel_pdqcb_table: [1000]PDQCB;
};

///
///  優先度データIDの最大値
///
fn maxPdqId() ID {
    return @intCast(ID, TMIN_PDQID + cfg._kernel_pdqinib_table.len - 1);
}

///
///  優先度データキューIDから優先度データキュー管理ブロックを取り出すための関数
///
pub fn indexPdq(pdqid: ID) usize {
    return @intCast(usize, pdqid - TMIN_PDQID);
}
pub fn checkAndGetPdqCB(pdqid: ID) ItronError!*PDQCB {
    try checkId(TMIN_PDQID <= pdqid and pdqid <= maxPdqId());
    return &cfg._kernel_pdqcb_table[indexPdq(pdqid)];
}

///
///  優先度データキュー管理ブロックから優先度データキューIDを取り出すための関数
///
fn getPdqIdFromPdqCB(p_pdqcb: *PDQCB) ID {
    return @intCast(ID, (@ptrToInt(p_pdqcb)
                             - @ptrToInt(&cfg._kernel_pdqcb_table))
                        / @sizeOf(PDQCB)) + TMIN_PDQID;
}

///
///  優先度データキュー待ち情報ブロックを取り出すための関数
///
pub fn getWinfoSPdq(p_winfo: *WINFO) *WINFO_SPDQ {
    return @fieldParentPtr(WINFO_SPDQ, "winfo", p_winfo);
}
pub fn getWinfoRPdq(p_winfo: *WINFO) *WINFO_RPDQ {
    return @fieldParentPtr(WINFO_RPDQ, "winfo", p_winfo);
}

///
///  待ち情報ブロックから優先度データキューIDを取り出すための関数
///
pub fn getPdqIdFromWinfoSPdq(p_winfo: *WINFO) ID {
    return getPdqIdFromPdqCB(getWinfoSPdq(p_winfo).p_wobjcb);
}
pub fn getPdqIdFromWinfoRPdq(p_winfo: *WINFO) ID {
    return getPdqIdFromPdqCB(getWinfoRPdq(p_winfo).p_wobjcb);
}

///
///  優先度の範囲チェック
///
fn validDataPri(datapri: PRI, maxdpri: PRI) bool {
    return TMIN_DPRI <= datapri and datapri <= maxdpri;
}

///
///  優先度データキュー機能の初期化
///
pub fn initialize_pridataq() void {
    for (cfg._kernel_pdqcb_table[0 .. cfg._kernel_pdqinib_table.len])
                                                        |*p_pdqcb, i| {
        p_pdqcb.swait_queue.initialize();
        p_pdqcb.p_wobjinib = &cfg._kernel_pdqinib_table[i];
        p_pdqcb.rwait_queue.initialize();
        p_pdqcb.count = 0;
        p_pdqcb.p_head = null;
        p_pdqcb.unused = 0;
        p_pdqcb.p_freelist = null;
    }
}

///
///  優先度データキュー管理領域へのデータの格納
///
fn enqueuePridata(p_pdqcb: *PDQCB, data: usize, datapri: PRI) void {
    var p_pdqmb: *PDQMB = undefined;
    var pp_prev_next: *?*PDQMB = &p_pdqcb.p_head;

    if (p_pdqcb.p_freelist) |p_freelist| {
        p_pdqmb = p_freelist;
        p_pdqcb.p_freelist = p_pdqmb.p_next;
    }
    else {
        p_pdqmb = &p_pdqcb.p_wobjinib.p_pdqmb.?[p_pdqcb.unused];
        p_pdqcb.unused += 1;
    }

    p_pdqmb.data = data;
    p_pdqmb.datapri = datapri;

    while (pp_prev_next.*) |p_next| : (pp_prev_next = &p_next.p_next) {
        if (p_next.datapri > datapri) {
            p_pdqmb.p_next = p_next;
            break;
        }
    }
    else {
        p_pdqmb.p_next = null;
    }
    pp_prev_next.* = p_pdqmb;
    p_pdqcb.count += 1;
}

///
///  優先度データキュー管理領域からのデータの取出し
///
fn dequeuePridata(p_pdqcb: *PDQCB, p_data: *usize, p_datapri: *PRI) void {
    var p_pdqmb: *PDQMB = p_pdqcb.p_head.?;

    p_pdqcb.p_head = p_pdqmb.p_next;
    p_pdqcb.count -= 1;

    p_data.* = p_pdqmb.data;
    p_datapri.* = p_pdqmb.datapri;

    p_pdqmb.p_next = p_pdqcb.p_freelist;
    p_pdqcb.p_freelist = p_pdqmb;
}

///
///  優先度データキューへのデータ送信
///
fn sendPridata(p_pdqcb: *PDQCB, data: usize, datapri: PRI) bool {
    if (!p_pdqcb.rwait_queue.isEmpty()) {
        const p_tcb = getTCBFromQueue(p_pdqcb.rwait_queue.deleteNext());
        getWinfoRPdq(p_tcb.p_winfo).data = data;
        getWinfoRPdq(p_tcb.p_winfo).datapri = datapri;
        wait_complete(p_tcb);
        return true;
    }
    else if (p_pdqcb.count < p_pdqcb.p_wobjinib.pdqcnt) {
        enqueuePridata(p_pdqcb, data, datapri);
        return true;
    }
    else {
        return false;
    }
}

///
///  優先度データキューからのデータ受信
///
fn receivePridata(p_pdqcb: *PDQCB, p_data: *usize, p_datapri: *PRI) bool {
    if (p_pdqcb.count > 0) {
        dequeuePridata(p_pdqcb, p_data, p_datapri);
        if (!p_pdqcb.swait_queue.isEmpty()) {
            const p_tcb = getTCBFromQueue(p_pdqcb.swait_queue.deleteNext());
            const data = getWinfoSPdq(p_tcb.p_winfo).data;
            const datapri = getWinfoSPdq(p_tcb.p_winfo).datapri;
            enqueuePridata(p_pdqcb, data, datapri);
            wait_complete(p_tcb);
        }
        return true;
    }
    else if (!p_pdqcb.swait_queue.isEmpty()) {
        const p_tcb = getTCBFromQueue(p_pdqcb.swait_queue.deleteNext());
        p_data.* = getWinfoSPdq(p_tcb.p_winfo).data;
        p_datapri.* = getWinfoSPdq(p_tcb.p_winfo).datapri;
        wait_complete(p_tcb);
        return true;
    }
    else {
        return false;
    }
}

///
///  優先度データキューへの送信
///
pub fn snd_pdq(pdqid: ID, data: usize, datapri: PRI) ItronError!void {
    traceLog("sndPdqEnter", .{ pdqid, data, datapri });
    errdefer |err| traceLog("sndPdqLeave", .{ err });
    try checkDispatch();
    const p_pdqcb = try checkAndGetPdqCB(pdqid);
    try checkParameter(validDataPri(datapri, p_pdqcb.p_wobjinib.maxdpri));
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (sendPridata(p_pdqcb, data, datapri)) {
            taskDispatch();
        }
        else {
            var winfo_spdq: WINFO_SPDQ = undefined;
            winfo_spdq.data = data;
            winfo_spdq.datapri = datapri;
            wobj_make_wait(p_pdqcb, TS_WAITING_SPDQ, &winfo_spdq);
            target_impl.dispatch();
            if (winfo_spdq.winfo.werror) |werror| {
                return werror;
            }
        }
    }
    traceLog("sndPdqLeave", .{ null });
}

///
///  優先度データキューへの送信（ポーリング）
///
pub fn psnd_pdq(pdqid: ID, data: usize, datapri: PRI) ItronError!void {
    traceLog("psndPdqEnter", .{ pdqid, data, datapri });
    errdefer |err| traceLog("psndPdqLeave", .{ err });
    try checkContextUnlock();
    const p_pdqcb = try checkAndGetPdqCB(pdqid);
    try checkParameter(validDataPri(datapri, p_pdqcb.p_wobjinib.maxdpri));
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (sendPridata(p_pdqcb, data, datapri)) {
            requestTaskDispatch();
        }
        else {
            return ItronError.TimeoutError;
        }
    }
    traceLog("psndPdqLeave", .{ null });
}

///
///  優先度データキューへの送信（タイムアウトあり）
///
pub fn tsnd_pdq(pdqid: ID, data: usize, datapri: PRI,
                tmout: TMO) ItronError!void {
    traceLog("tSndPdqEnter", .{ pdqid, data, datapri, tmout });
    errdefer |err| traceLog("tSndPdqLeave", .{ err });
    try checkDispatch();
    const p_pdqcb = try checkAndGetPdqCB(pdqid);
    try checkParameter(validDataPri(datapri, p_pdqcb.p_wobjinib.maxdpri));
    try checkParameter(validTimeout(tmout));
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (sendPridata(p_pdqcb, data, datapri)) {
            taskDispatch();
        }
        else if (tmout == TMO_POL) {
            return ItronError.TimeoutError;
        }
        else {
            var winfo_spdq: WINFO_SPDQ = undefined;
            var tmevtb: TMEVTB = undefined;
            winfo_spdq.data = data;
            winfo_spdq.datapri = datapri;
            wobj_make_wait_tmout(p_pdqcb, TS_WAITING_SPDQ, &winfo_spdq,
                                 &tmevtb, tmout);
            target_impl.dispatch();
            if (winfo_spdq.winfo.werror) |werror| {
                return werror;
            }
        }
    }
    traceLog("tSndPdqLeave", .{ null });
}

///
///  優先度データキューからの受信
///
pub fn rcv_pdq(pdqid: ID, p_data: *usize, p_datapri: *PRI) ItronError!void {
    traceLog("rcvPdqEnter", .{ pdqid, p_data, p_datapri });
    errdefer |err| traceLog("rcvPdqLeave", .{ err, p_data, p_datapri });
    try checkDispatch();
    const p_pdqcb = try checkAndGetPdqCB(pdqid);
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (receivePridata(p_pdqcb, p_data, p_datapri)) {
            taskDispatch();
        }
        else {
            var winfo_rpdq: WINFO_RPDQ = undefined;
            wobj_make_rwait(p_pdqcb, TS_WAITING_RPDQ, &winfo_rpdq);
            target_impl.dispatch();
            if (winfo_rpdq.winfo.werror) |werror| {
                return werror;
            }
            p_data.* = winfo_rpdq.data;
            p_datapri.* = winfo_rpdq.datapri;
        }
    }
    traceLog("rcvPdqLeave", .{ null, p_data, p_datapri });
}

///
///  優先度データキューからの受信（ポーリング）
///
pub fn prcv_pdq(pdqid: ID, p_data: *usize, p_datapri: *PRI) ItronError!void {
    traceLog("pRcvPdqEnter", .{ pdqid, p_data, p_datapri });
    errdefer |err| traceLog("pRcvPdqLeave", .{ err, p_data, p_datapri });
    try checkContextTaskUnlock();
    const p_pdqcb = try checkAndGetPdqCB(pdqid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (receivePridata(p_pdqcb, p_data, p_datapri)) {
            taskDispatch();
        }
        else {
            return ItronError.TimeoutError;
        }
    }
    traceLog("pRcvPdqLeave", .{ null, p_data, p_datapri });
}

///
///  優先度データキューからの受信（タイムアウトあり）
///
pub fn trcv_pdq(pdqid: ID, p_data: *usize, p_datapri: *PRI,
                tmout: TMO) ItronError!void {
    traceLog("tRcvPdqEnter", .{ pdqid, p_data, p_datapri, tmout });
    errdefer |err| traceLog("tRcvPdqLeave", .{ err, p_data, p_datapri });
    try checkDispatch();
    const p_pdqcb = try checkAndGetPdqCB(pdqid);
    try checkParameter(validTimeout(tmout));
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (receivePridata(p_pdqcb, p_data, p_datapri)) {
            taskDispatch();
        }
        else if (tmout == TMO_POL) {
            return ItronError.TimeoutError;
        }
        else {
            var winfo_rpdq: WINFO_RPDQ = undefined;
            var tmevtb: TMEVTB = undefined;
            wobj_make_rwait_tmout(p_pdqcb, TS_WAITING_RPDQ, &winfo_rpdq,
                                  &tmevtb, tmout);
            target_impl.dispatch();
            if (winfo_rpdq.winfo.werror) |werror| {
                return werror;
            }
            p_data.* = winfo_rpdq.data;
            p_datapri.* = winfo_rpdq.datapri;
        }
    }
    traceLog("tRcvPdqLeave", .{ null, p_data, p_datapri });
}

///
///  優先度データキューの再初期化
///
pub fn ini_pdq(pdqid: ID) ItronError!void {
    traceLog("iniPdqEnter", .{ pdqid });
    errdefer |err| traceLog("iniPdqLeave", .{ err });
    try checkContextTaskUnlock();
    const p_pdqcb = try checkAndGetPdqCB(pdqid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        init_wait_queue(&p_pdqcb.swait_queue);
        init_wait_queue(&p_pdqcb.rwait_queue);
        p_pdqcb.count = 0;
        p_pdqcb.p_head = null;
        p_pdqcb.unused = 0;
        p_pdqcb.p_freelist = null;
        taskDispatch();
    }
    traceLog("iniPdqLeave", .{ null });
}

///
///  優先度データキューの状態参照
///
pub fn ref_pdq(pdqid: ID, pk_rpdq: *T_RPDQ) ItronError!void {
    traceLog("refPdqEnter", .{ pdqid, pk_rpdq });
    errdefer |err| traceLog("refPdqLeave", .{ err, pk_rpdq });
    try checkContextTaskUnlock();
    const p_pdqcb = try checkAndGetPdqCB(pdqid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        pk_rpdq.stskid = wait_tskid(&p_pdqcb.swait_queue);
        pk_rpdq.rtskid = wait_tskid(&p_pdqcb.rwait_queue);
        pk_rpdq.spdqcnt = p_pdqcb.count;
    }
    traceLog("refPdqLeave", .{ null, pk_rpdq });
}

///
///  優先度データキューの生成（静的APIの処理）
///
pub fn cre_pdq(comptime cpdq: T_CPDQ) ItronError!PDQINIB {
    // pdqatrが無効の場合（E_RSATR）［NGKI1804］［NGKI1795］
    //（TA_TPRI以外のビットがセットされている場合）
    try checkValidAtr(cpdq.pdqatr, TA_TPRI);

    // maxdpriが有効範囲外の場合（E_PAR）［NGKI1819］
    //（TMIN_DPRI <= maxdpri && maxdpri <= TMAX_DPRIでない場合）
    try checkParameter(TMIN_DPRI <= cpdq.maxdpri and cpdq.maxdpri <= TMAX_DPRI);

    // pdqmbがNULLでない場合（E_NOSPT）［ASPS0142］
    try checkNotSupported(cpdq.pdqmb == null);

    // 優先度データキュー管理領域の確保
    comptime const p_pdqmb = if (cpdq.pdqcnt == 0) null
        else &struct {
            var pdqmb: [cpdq.pdqcnt]PDQMB = undefined;
        }.pdqmb;

    // 優先度データキュー初期化ブロックを返す
    return PDQINIB{ .wobjatr = cpdq.pdqatr,
                    .pdqcnt = cpdq.pdqcnt,
                    .maxdpri = cpdq.maxdpri,
                    .p_pdqmb = p_pdqmb, };
}

///
///  優先度データキューに関するコンフィギュレーションデータの生成（静
///  的APIの処理）
///
pub fn ExportPdqCfg(pdqinib_table: []PDQINIB) type {
    const tnum_pdq = pdqinib_table.len;
    return struct {
        pub export const _kernel_pdqinib_table = pdqinib_table;

        // Zigの制限の回避：BIND_CFG != nullの場合に，サイズ0の配列が
        // 出ないようにする
        pub export var _kernel_pdqcb_table:
            [if (option.BIND_CFG == null or tnum_pdq > 0) tnum_pdq
                 else 1]PDQCB = undefined;
    };
}
