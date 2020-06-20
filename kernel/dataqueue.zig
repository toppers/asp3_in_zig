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
///  データキュー機能
///
usingnamespace @import("kernel_impl.zig");
usingnamespace task;
usingnamespace wait;
usingnamespace time_event;
usingnamespace check;

///
///  データ管理ブロック
///
const DTQMB = struct {
    data: usize,        // データ本体
};

///
///  データキュー初期化ブロック
///
///  この構造体は，同期・通信オブジェクトの初期化ブロックの共通部分
///  （WOBJINIB）を拡張（オブジェクト指向言語の継承に相当）したもので，
///  最初のフィールドが共通になっている．
///
pub const DTQINIB = struct {
    wobjatr: ATR,               // データキュー属性
    dtqcnt: c_uint,             // データキューの容量
    p_dtqmb: ?[*]DTQMB,         // データキュー管理領域
};

// データキュー初期化ブロックのチェック
comptime {
    checkWobjIniB(DTQINIB);
}

///
///  データキュー管理ブロック
///
///  この構造体は，同期・通信オブジェクトの管理ブロックの共通部分
///  （WOBJCB）を拡張（オブジェクト指向言語の継承に相当）したもので，
///  最初の2つのフィールドが共通になっている．
///
const DTQCB = struct {
    swait_queue: queue.Queue,   // データキュー送信待ちキュー
    p_wobjinib: *const DTQINIB, // 初期化ブロックへのポインタ
    rwait_queue: queue.Queue,   // データキュー受信待ちキュー
    count: c_uint,              // データキュー中のデータの数
    head: c_uint,               // 最初のデータの格納場所
    tail: c_uint,               // 最後のデータの格納場所の次
};

// データキュー管理ブロックのチェック
comptime {
    checkWobjCB(DTQCB);
}

///
///  データキュー待ち情報ブロックの定義
///
///  この構造体は，同期・通信オブジェクトの待ち情報ブロックの共通部分
///  （WINFO_WOBJ）を拡張（オブジェクト指向言語の継承に相当）したもの
///  で，最初の2つのフィールドが共通になっている．
///
const WINFO_SDTQ = struct {
    winfo: WINFO,               // 標準の待ち情報ブロック
    p_wobjcb: *DTQCB,           // 待っているデータキューの管理ブロック
    data: usize,                // 送信データ
};

const WINFO_RDTQ = struct {
    winfo: WINFO,               // 標準の待ち情報ブロック
    p_wobjcb: *DTQCB,           // 待っているデータキューの管理ブロック
    data: usize,                // 受信データ
};

// データキュー待ち情報ブロックのチェック
comptime {
    checkWinfoWobj(WINFO_SDTQ);
    checkWinfoWobj(WINFO_RDTQ);
}

///
///  データキューに関するコンフィギュレーションデータの取り込み
///
pub const ExternDtqCfg = struct {
    ///
    ///  データキュー初期化ブロック（スライス）
    ///
    pub extern const _kernel_dtqinib_table: []DTQINIB;

    ///
    ///  データキュー管理ブロックのエリア
    ///
    // Zigの制限事項の回避：十分に大きいサイズの配列とする
    pub extern var _kernel_dtqcb_table: [1000]DTQCB;
};

///
///  データキューIDの最大値
///
fn maxDtqId() ID {
    return @intCast(ID, TMIN_DTQID + cfg._kernel_dtqinib_table.len - 1);
}

///
///  データキューIDからデータキュー管理ブロックを取り出すための関数
///
fn indexDtq(dtqid: ID) usize {
    return @intCast(usize, dtqid - TMIN_DTQID);
}
fn checkAndGetDtqCB(dtqid: ID) ItronError!*DTQCB {
    try checkId(TMIN_DTQID <= dtqid and dtqid <= maxDtqId());
    return &cfg._kernel_dtqcb_table[indexDtq(dtqid)];
}

///
///  データキュー管理ブロックからデータキューIDを取り出すための関数
///
pub fn getDtqIdFromDtqCB(p_dtqcb: *DTQCB) ID {
    return @intCast(ID, (@ptrToInt(p_dtqcb)
                             - @ptrToInt(&cfg._kernel_dtqcb_table))
                        / @sizeOf(DTQCB)) + TMIN_DTQID;
}

///
///  データキュー待ち情報ブロックを取り出すための関数
///
pub fn getWinfoSDtq(p_winfo: *WINFO) *WINFO_SDTQ {
    return @fieldParentPtr(WINFO_SDTQ, "winfo", p_winfo);
}
pub fn getWinfoRDtq(p_winfo: *WINFO) *WINFO_RDTQ {
    return @fieldParentPtr(WINFO_RDTQ, "winfo", p_winfo);
}

///
///  待ち情報ブロックからデータキューIDを取り出すための関数
///
pub fn getDtqIdFromWinfoSDtq(p_winfo: *WINFO) ID {
    return getDtqIdFromDtqCB(getWinfoSDtq(p_winfo).p_wobjcb);
}
pub fn getDtqIdFromWinfoRDtq(p_winfo: *WINFO) ID {
    return getDtqIdFromDtqCB(getWinfoRDtq(p_winfo).p_wobjcb);
}

///
///  データキュー機能の初期化
///
pub fn initialize_dataqueue() void {
    for (cfg._kernel_dtqcb_table[0 .. cfg._kernel_dtqinib_table.len])
                                                        |*p_dtqcb, i| {
        p_dtqcb.swait_queue.initialize();
        p_dtqcb.p_wobjinib = &cfg._kernel_dtqinib_table[i];
        p_dtqcb.rwait_queue.initialize();
        p_dtqcb.count = 0;
        p_dtqcb.head = 0;
        p_dtqcb.tail = 0;
    }
}

///
///  データキュー管理領域へのデータの格納
///
fn enqueueData(p_dtqcb: *DTQCB, data: usize) void {
    p_dtqcb.p_wobjinib.p_dtqmb.?[p_dtqcb.tail].data = data;
    p_dtqcb.count += 1;
    p_dtqcb.tail += 1;
    if (p_dtqcb.tail >= p_dtqcb.p_wobjinib.dtqcnt) {
        p_dtqcb.tail = 0;
    }
}

///
///  データキュー管理領域へのデータの強制格納
///
fn forceEnqueueData(p_dtqcb: *DTQCB, data: usize) void {
    p_dtqcb.p_wobjinib.p_dtqmb.?[p_dtqcb.tail].data = data;
    p_dtqcb.tail += 1;
    if (p_dtqcb.tail >= p_dtqcb.p_wobjinib.dtqcnt) {
        p_dtqcb.tail = 0;
    }
    if (p_dtqcb.count < p_dtqcb.p_wobjinib.dtqcnt) {
        p_dtqcb.count += 1;
    }
    else {
        p_dtqcb.head = p_dtqcb.tail;
    }
}

///
///  データキュー管理領域からのデータの取出し
///
fn dequeueData(p_dtqcb: *DTQCB, p_data: *usize) void {
    p_data.* = p_dtqcb.p_wobjinib.p_dtqmb.?[p_dtqcb.head].data;
    p_dtqcb.count -= 1;
    p_dtqcb.head += 1;
    if (p_dtqcb.head >= p_dtqcb.p_wobjinib.dtqcnt) {
        p_dtqcb.head = 0;
    }
}

///
///  データキューへのデータ送信
///
fn sendData(p_dtqcb: *DTQCB, data: usize) bool {
    if (!p_dtqcb.rwait_queue.isEmpty()) {
        const p_tcb = getTCBFromQueue(p_dtqcb.rwait_queue.deleteNext());
        getWinfoRDtq(p_tcb.p_winfo).data = data;
        wait_complete(p_tcb);
        return true;
    }
    else if (p_dtqcb.count < p_dtqcb.p_wobjinib.dtqcnt) {
        enqueueData(p_dtqcb, data);
        return true;
    }
    else {
        return false;
    }
}

///
///  データキューへのデータ強制送信
///
fn forceSendData(p_dtqcb: *DTQCB, data: usize) void {

    if (!p_dtqcb.rwait_queue.isEmpty()) {
        const p_tcb = getTCBFromQueue(p_dtqcb.rwait_queue.deleteNext());
        getWinfoRDtq(p_tcb.p_winfo).data = data;
        wait_complete(p_tcb);
    }
    else {
        forceEnqueueData(p_dtqcb, data);
    }
}

///
///  データキューからのデータ受信
///
fn receiveData(p_dtqcb: *DTQCB, p_data: *usize) bool {
    if (p_dtqcb.count > 0) {
        dequeueData(p_dtqcb, p_data);
        if (!p_dtqcb.swait_queue.isEmpty()) {
            const p_tcb = getTCBFromQueue(p_dtqcb.swait_queue.deleteNext());
            const data = getWinfoSDtq(p_tcb.p_winfo).data;
            enqueueData(p_dtqcb, data);
            wait_complete(p_tcb);
        }
        return true;
    }
    else if (!p_dtqcb.swait_queue.isEmpty()) {
        const p_tcb = getTCBFromQueue(p_dtqcb.swait_queue.deleteNext());
        p_data.* = getWinfoSDtq(p_tcb.p_winfo).data;
        wait_complete(p_tcb);
        return true;
    }
    else {
        return false;
    }
}

///
///  データキューへの送信
///
pub fn snd_dtq(dtqid: ID, data: usize) ItronError!void {
    traceLog("sndDtqEnter", .{ dtqid, data });
    errdefer |err| traceLog("sndDtqLeave", .{ err });
    try checkDispatch();
    const p_dtqcb = try checkAndGetDtqCB(dtqid);
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (sendData(p_dtqcb, data)) {
            taskDispatch();
        }
        else {
            var winfo_sdtq: WINFO_SDTQ = undefined;
            winfo_sdtq.data = data;
            wobj_make_wait(p_dtqcb, TS_WAITING_SDTQ, &winfo_sdtq);
            target_impl.dispatch();
            if (winfo_sdtq.winfo.werror) |werror| {
                return werror;
            }
        }
    }
    traceLog("sndDtqLeave", .{ null });
}

///
///  データキューへの送信（ポーリング）
///
pub fn psnd_dtq(dtqid: ID, data: usize) ItronError!void {
    traceLog("pSndDtqEnter", .{ dtqid, data });
    errdefer |err| traceLog("pSndDtqLeave", .{ err });
    try checkContextUnlock();
    const p_dtqcb = try checkAndGetDtqCB(dtqid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (sendData(p_dtqcb, data)) {
            requestTaskDispatch();
        }
        else {
            return ItronError.TimeoutError;
        }
    }
    traceLog("pSndDtqLeave", .{ null });
}

///
///  データキューへの送信（タイムアウトあり）
///
pub fn tsnd_dtq(dtqid: ID, data: usize, tmout: TMO) ItronError!void {
    traceLog("tSndDtqEnter", .{ dtqid, data, tmout });
    errdefer |err| traceLog("tSndDtqLeave", .{ err });
    try checkDispatch();
    const p_dtqcb = try checkAndGetDtqCB(dtqid);
    try checkParameter(validTimeout(tmout));
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (sendData(p_dtqcb, data)) {
            taskDispatch();
        }
        else if (tmout == TMO_POL) {
            return ItronError.TimeoutError;
        }
        else {
            var winfo_sdtq: WINFO_SDTQ = undefined;
            var tmevtb: TMEVTB = undefined;
            winfo_sdtq.data = data;
            wobj_make_wait_tmout(p_dtqcb, TS_WAITING_SDTQ, &winfo_sdtq,
                                 &tmevtb, tmout);
            target_impl.dispatch();
            if (winfo_sdtq.winfo.werror) |werror| {
                return werror;
            }
        }
    }
    traceLog("tSndDtqLeave", .{ null });
}

///
///  データキューへの強制送信
///
pub fn fsnd_dtq(dtqid: ID, data: usize) ItronError!void {
    traceLog("fSndDtqEnter", .{ dtqid, data });
    errdefer |err| traceLog("fSndDtqLeave", .{ err });
    try checkContextUnlock();
    const p_dtqcb = try checkAndGetDtqCB(dtqid);
    try checkIllegalUse(p_dtqcb.p_wobjinib.dtqcnt > 0);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        forceSendData(p_dtqcb, data);
        requestTaskDispatch();
    }
    traceLog("fSndDtqLeave", .{ null });
}

///
///  データキューからの受信
///
pub fn rcv_dtq(dtqid: ID, p_data: *usize) ItronError!void {
    traceLog("rcvDtqEnter", .{ dtqid, p_data });
    errdefer |err| traceLog("rcvDtqLeave", .{ err, p_data });
    try checkDispatch();
    const p_dtqcb = try checkAndGetDtqCB(dtqid);
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (receiveData(p_dtqcb, p_data)) {
            taskDispatch();
        }
        else {
            var winfo_rdtq: WINFO_RDTQ = undefined;
            wobj_make_rwait(p_dtqcb, TS_WAITING_RDTQ, &winfo_rdtq);
            target_impl.dispatch();
            if (winfo_rdtq.winfo.werror) |werror| {
                return werror;
            }
            p_data.* = winfo_rdtq.data;
        }
    }
    traceLog("rcvDtqLeave", .{ null, p_data });
}

///
///  データキューからの受信（ポーリング）
///
pub fn prcv_dtq(dtqid: ID, p_data: *usize) ItronError!void {
    traceLog("prcvDtqEnter", .{ dtqid, p_data });
    errdefer |err| traceLog("prcvDtqLeave", .{ err, p_data });
    try checkContextTaskUnlock();
    const p_dtqcb = try checkAndGetDtqCB(dtqid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (receiveData(p_dtqcb, p_data)) {
            taskDispatch();
        }
        else {
            return ItronError.TimeoutError;
        }
    }
    traceLog("prcvDtqLeave", .{ null, p_data });
}

///
///  データキューからの受信（タイムアウトあり）
///
pub fn trcv_dtq(dtqid: ID, p_data: *usize, tmout: TMO) ItronError!void {
    traceLog("tRcvDtqEnter", .{ dtqid, p_data, tmout });
    errdefer |err| traceLog("tRcvDtqLeave", .{ err, p_data });
    try checkDispatch();
    const p_dtqcb = try checkAndGetDtqCB(dtqid);
    try checkParameter(validTimeout(tmout));
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (receiveData(p_dtqcb, p_data)) {
            taskDispatch();
        }
        else if (tmout == TMO_POL) {
            return ItronError.TimeoutError;
        }
        else {
            var winfo_rdtq: WINFO_RDTQ = undefined;
            var tmevtb: TMEVTB = undefined;
            wobj_make_rwait_tmout(p_dtqcb, TS_WAITING_RDTQ, &winfo_rdtq,
                                  &tmevtb, tmout);
            target_impl.dispatch();
            if (winfo_rdtq.winfo.werror) |werror| {
                return werror;
            }
            p_data.* = winfo_rdtq.data;
        }
    }
    traceLog("tRcvDtqLeave", .{ null, p_data });
}

///
///  データキューの再初期化
///
pub fn ini_dtq(dtqid: ID) ItronError!void {
    traceLog("iniDtqEnter", .{ dtqid });
    errdefer |err| traceLog("iniDtqLeave", .{ err });
    try checkContextTaskUnlock();
    const p_dtqcb = try checkAndGetDtqCB(dtqid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        init_wait_queue(&p_dtqcb.swait_queue);
        init_wait_queue(&p_dtqcb.rwait_queue);
        p_dtqcb.count = 0;
        p_dtqcb.head = 0;
        p_dtqcb.tail = 0;
        taskDispatch();
    }
    traceLog("iniDtqLeave", .{ null });
}

///
///  データキューの状態参照
///
pub fn ref_dtq(dtqid: ID, pk_rdtq: *T_RDTQ) ItronError!void {
    traceLog("refDtqEnter", .{ dtqid, pk_rdtq });
    errdefer |err| traceLog("refDtqLeave", .{ err, pk_rdtq });
    try checkContextTaskUnlock();
    const p_dtqcb = try checkAndGetDtqCB(dtqid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        pk_rdtq.stskid = wait_tskid(&p_dtqcb.swait_queue);
        pk_rdtq.rtskid = wait_tskid(&p_dtqcb.rwait_queue);
        pk_rdtq.sdtqcnt = p_dtqcb.count;
    }
    traceLog("refDtqLeave", .{ null, pk_rdtq });
}

///
///  データキューの生成（静的APIの処理）
///
pub fn cre_dtq(comptime cdtq: T_CDTQ) ItronError!DTQINIB {
    // dtqatrが無効の場合（E_RSATR）［NGKI1669］［NGKI1661］
    //（TA_TPRI以外のビットがセットされている場合）
    try checkValidAtr(cdtq.dtqatr, TA_TPRI);

    // dtqmbがNULLでない場合（E_NOSPT）［ASPS0132］
    try checkNotSupported(cdtq.dtqmb == null);

    // データキュー管理領域の確保
    comptime const p_dtqmb = if (cdtq.dtqcnt == 0) null
        else &struct {
            var dtqmb: [cdtq.dtqcnt]DTQMB = undefined;
        }.dtqmb;

    // データキュー初期化ブロックを返す
    return DTQINIB{ .wobjatr = cdtq.dtqatr,
                    .dtqcnt = cdtq.dtqcnt,
                    .p_dtqmb = p_dtqmb, };
}

///
///  データキューに関するコンフィギュレーションデータの生成（静的APIの
///  処理）
///
pub fn ExportDtqCfg(dtqinib_table: []DTQINIB) type {
    const tnum_dtq = dtqinib_table.len;
    return struct {
        pub export const _kernel_dtqinib_table = dtqinib_table;

        // Zigの制限の回避：BIND_CFG != nullの場合に，サイズ0の配列が
        // 出ないようにする
        pub export var _kernel_dtqcb_table:
            [if (option.BIND_CFG == null or tnum_dtq > 0) tnum_dtq
                 else 1]DTQCB = undefined;
    };
}
