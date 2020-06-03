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
///  タスク付属同期機能
///
usingnamespace @import("kernel_impl.zig");
usingnamespace task;
usingnamespace wait;
usingnamespace time_event;
usingnamespace check;

///
///  起床待ち［NGKI1252］
///
pub fn slp_tsk() ItronError!void {
    var winfo: WINFO = undefined;

    log.slpTskEnter();
    errdefer |err| log.slpTskLeave(err);
    try checkDispatch();                        //［NGKI1254］
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        var p_selftsk = p_runtsk.?;
        if (p_selftsk.flags.raster) {           //［NGKI3455］
            return ItronError.TerminationRequestRaised;
        }
        else if (p_selftsk.flags.wupque > 0) {
            p_selftsk.flags.wupque -= 1;        //［NGKI1259］
        }
        else {
            make_wait(TS_WAITING_SLP, &winfo);  //［NGKI1260］
            log.taskStateChange(p_selftsk);
            target_impl.dispatch();
            if (winfo.werror) |werror| {
                return werror;
            }
        }
    }
    log.slpTskLeave(null);
}

///
///  起床待ち（タイムアウトあり）［NGKI1253］
/// 
pub fn tslp_tsk(tmout: TMO) ItronError!void {
    var winfo: WINFO = undefined;
    var tmevtb: TMEVTB = undefined;

    log.tSlpTskEnter(tmout);
    errdefer |err| log.tSlpTskLeave(err);
    try checkDispatch();                        //［NGKI1254］
    try checkParameter(validTimeout(tmout));    //［NGKI1256］
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        var p_selftsk = p_runtsk.?;
        if (p_selftsk.flags.raster) {           //［NGKI3455］
            return ItronError.TerminationRequestRaised;
        }
        else if (p_selftsk.flags.wupque > 0) {
            p_selftsk.flags.wupque -= 1;        //［NGKI1259］
        }
        else if (tmout == TMO_POL) {
            return ItronError.TimeoutError;     //［NGKI1257］
        }
        else {                                  //［NGKI1260］
            make_wait_tmout(TS_WAITING_SLP, &winfo, &tmevtb, tmout);
            log.taskStateChange(p_selftsk);
            target_impl.dispatch();
            if (winfo.werror) |werror| {
                return werror;
            }
        }
    }
    log.tSlpTskLeave(null);
}

///
///  タスクの起床［NGKI3531］
///
pub fn wup_tsk(tskid: ID) ItronError!void {
    var p_tcb: *TCB = undefined;

    log.wupTskEnter(tskid);
    errdefer |err| log.wupTskLeave(err);
    try checkContextUnlock();                   //［NGKI1265］
    if (tskid == TSK_SELF and !target_impl.senseContext()) {
        p_tcb = p_runtsk.?;                     //［NGKI1275］
    }
    else {
        p_tcb = try checkAndGetTCB(tskid);      //［NGKI1267］
    }
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (isDormant(p_tcb.tstat)) {           //［NGKI1270］
            return ItronError.ObjectStateError;
        }
        else if (isWaitingSlp(p_tcb.tstat)) {
            wait_complete(p_tcb);               //［NGKI1271］
            requestTaskDispatch();
        }
        else if (p_tcb.flags.wupque < TMAX_WUPCNT) {
            p_tcb.flags.wupque += 1;            //［NGKI1273］
        }
        else {
            return ItronError.QueueingOverflow; //［NGKI1274］
        }
    }
    log.wupTskLeave(null);
}

///
///  タスク起床要求のキャンセル［NGKI1276］
///
pub fn can_wup(tskid: ID) ItronError!c_uint {
    var p_tcb: *TCB = undefined;
    var retval: c_uint = undefined;

    log.canWupEnter(tskid);
    errdefer |err| log.canWupLeave(err);
    try checkContextTaskUnlock();               //［NGKI1277］［NGKI1278］
    if (tskid == TSK_SELF) {
        p_tcb = p_runtsk.?;                     //［NGKI1285］
    }
    else {
        p_tcb = try checkAndGetTCB(tskid);      //［NGKI1280］
    }
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (isDormant(p_tcb.tstat)) {           //［NGKI1283］
            return ItronError.ObjectStateError;
        }
        else {
            retval = p_tcb.flags.wupque;        //［NGKI1284］
            p_tcb.flags.wupque = 0;             //［NGKI1284］
        }
    }
    log.canWupLeave(retval);
    return retval;
}

///
///  待ち状態の強制解除［NGKI3532］
///
pub fn rel_wai(tskid: ID) ItronError!void {
    var p_tcb: *TCB = undefined;

    log.relWaiEnter(tskid);
    errdefer |err| log.relWaiLeave(err);
    try checkContextUnlock();                   //［NGKI1290］
    p_tcb = try checkAndGetTCB(tskid);          //［NGKI1292］
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (!isWaiting(p_tcb.tstat)) {          //［NGKI1295］
            return ItronError.ObjectStateError;
        }
        else {
            wait_dequeue_wobj(p_tcb);           //［NGKI1296］
            wait_dequeue_tmevtb(p_tcb);         //［NGKI1297］
            p_tcb.p_winfo.* = WINFO{ .werror = ItronError.ReleasedFromWaiting };
            make_non_wait(p_tcb);
            requestTaskDispatch();
        }
    }
    log.relWaiLeave(null);
}

///
///  強制待ち状態への移行［NGKI1298］
///
pub fn sus_tsk(tskid: ID) ItronError!void {
    var p_tcb: *TCB = undefined;

    log.susTskEnter(tskid);
    errdefer |err| log.susTskLeave(err);
    try checkContextTaskUnlock();               //［NGKI1299］［NGKI1300］
    if (tskid == TSK_SELF) {
        p_tcb = p_runtsk.?;                     //［NGKI1310］
    }
    else {
        p_tcb = try checkAndGetTCB(tskid);      //［NGKI1302］
    }
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (p_tcb == p_runtsk and !dspflg) {    //［NGKI1311］［NGKI3604］
            return ItronError.ContextError;
        }
        else if (isDormant(p_tcb.tstat)) {      //［NGKI1305］
            return ItronError.ObjectStateError;
        }
        else if (p_tcb.flags.raster) {                //［NGKI3605］
            return ItronError.TerminationRequestRaised;
        }
        else if (isRunnable(p_tcb.tstat)) {
            // 実行できる状態から強制待ち状態への遷移［NGKI1307］
            p_tcb.tstat = TS_SUSPENDED;
            log.taskStateChange(p_tcb);
            make_non_runnable(p_tcb);
            taskDispatch();
        }
        else if (isSuspended(p_tcb.tstat)) {    //［NGKI1306］
            return ItronError.QueueingOverflow;
        }
        else {
            // 待ち状態から二重待ち状態への遷移［NGKI1308］
            p_tcb.tstat |= @as(u8, TS_SUSPENDED);
            log.taskStateChange(p_tcb);
        }
    }
    log.susTskLeave(null);
}

///
///  強制待ち状態からの再開［NGKI1312］
///
pub fn rsm_tsk(tskid: ID) ItronError!void {
    var p_tcb: *TCB = undefined;

    log.rsmTskEnter(tskid);
    errdefer |err| log.rsmTskLeave(err);
    try checkContextTaskUnlock();               //［NGKI1313］［NGKI1314］
    p_tcb = try checkAndGetTCB(tskid);          //［NGKI1316］
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (!isSuspended(p_tcb.tstat)) {        //［NGKI1319］
            return ItronError.ObjectStateError;
        }
        else {
            // 強制待ちからの再開［NGKI1320］
            if (!isWaiting(p_tcb.tstat)) {
                p_tcb.tstat = TS_RUNNABLE;
                log.taskStateChange(p_tcb);
                make_runnable(p_tcb);
                taskDispatch();
            }
            else {
                p_tcb.tstat &= ~@as(u8, TS_SUSPENDED);
                log.taskStateChange(p_tcb);
            }
        }
    }
    log.rsmTskLeave(null);
}

///
/// 自タスクの遅延［NGKI1348］
///
pub fn dly_tsk(dlytim: RELTIM) ItronError!void {
    var winfo: WINFO = undefined;
    var tmevtb: TMEVTB = undefined;

    log.dlyTskEnter(dlytim);
    errdefer |err| log.dlyTskLeave(err);
    try checkDispatch();                            //［NGKI1349］
    try checkParameter(validRelativeTime(dlytim));  //［NGKI1351］
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        var p_selftsk = p_runtsk.?;
        if (p_selftsk.flags.raster) {               //［NGKI3456］
            return ItronError.TerminationRequestRaised;
        }
        else {                                      //［NGKI1353］
            p_selftsk.tstat = TS_WAITING_DLY;
            make_non_runnable(p_selftsk);
            p_selftsk.p_winfo = &winfo;
            winfo.p_tmevtb = &tmevtb;
            tmevtb.callback = wait_tmout_ok;
            tmevtb.arg = @ptrToInt(p_runtsk);
            tmevtb_enqueue_reltim(&tmevtb, dlytim);
            log.taskStateChange(p_selftsk);
            target_impl.dispatch();
            if (winfo.werror) |werror| {
                return werror;
            }
        }
    }
    log.dlyTskLeave(null);
}
