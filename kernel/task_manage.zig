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
///  タスク管理機能
///
usingnamespace @import("kernel_impl.zig");
usingnamespace task;
usingnamespace check;

///
///  タスクの起動［NGKI3529］
///
pub fn act_tsk(tskid: ID) ItronError!void {
    var p_tcb: *TCB = undefined;

    log.actTskEnter(tskid);
    errdefer |err| log.actTskLeave(err);
    try checkContextUnlock();                   //［NGKI1114］
    if (tskid == TSK_SELF and !target_impl.senseContext()) {
        p_tcb = p_runtsk.?;                     //［NGKI1121］
    }
    else {
        p_tcb = try checkAndGetTCB(tskid);      //［NGKI1115］
    }
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (isDormant(p_tcb.tstat)) {
            make_active(p_tcb);                 //［NGKI1118］
            requestTaskDispatch();
        }
        else if ((p_tcb.p_tinib.tskatr & TA_NOACTQUE) != 0
                     or p_tcb.flags.actque == TMAX_ACTCNT) {
            return ItronError.QueueingOverflow; //［NGKI3528］
        }
        else {
            p_tcb.flags.actque += 1;            //［NGKI3527］
        }
    }
    log.actTskLeave(null);
}

///
///  タスク起動要求のキャンセル［NGKI1138］
///
pub fn can_act(tskid: ID) ItronError!c_uint {
    var p_tcb: *TCB = undefined;
    var retval: c_uint = undefined;

    log.canActEnter(tskid);
    errdefer |err| log.canActLeave(err);
    try checkContextTaskUnlock();               //［NGKI1139］［NGKI1140］
    if (tskid == TSK_SELF) {
        p_tcb = p_runtsk.?;                     //［NGKI1146］
    }
    else {
        p_tcb = try checkAndGetTCB(tskid);      //［NGKI1141］
    }
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        retval = p_tcb.flags.actque;            //［NGKI1144］
        p_tcb.flags.actque = 0;                 //［NGKI1144］
    }
    log.canActLeave(retval);
    return retval;
}

///
///  タスク状態の参照［NGKI3613］
///
pub fn get_tst(tskid: ID, p_tskstat: *STAT) ItronError!void {
    var p_tcb: *TCB = undefined;

    log.getTstEnter(tskid, p_tskstat);
    errdefer |err| log.getTstLeave(err, p_tskstat);
    try checkContextTaskUnlock();               //［NGKI3614］［NGKI3615］
    if (tskid == TSK_SELF) {
        p_tcb = p_runtsk.?;                     //［NGKI3621］
    }
    else {
        p_tcb = try checkAndGetTCB(tskid);      //［NGKI3616］
    }
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (isDormant(p_tcb.tstat)) {           //［NGKI3620］
            p_tskstat.* = TTS_DMT;
        }
        else if (isSuspended(p_tcb.tstat)) {
            if (isWaiting(p_tcb.tstat)) {
                p_tskstat.* = TTS_WAS;
            }
            else {
                p_tskstat.* = TTS_SUS;
            }
        }
        else if (isWaiting(p_tcb.tstat)) {
            p_tskstat.* = TTS_WAI;
        }
        else if (p_tcb == p_runtsk) {
            p_tskstat.* = TTS_RUN;
        }
        else {
            p_tskstat.* = TTS_RDY;
        }
    }
    log.getTstLeave(null, p_tskstat);
}

///
///  タスクのベース優先度の変更［NGKI1183］
///
pub fn chg_pri(tskid: ID, tskpri: PRI) ItronError!void {
    var p_tcb: *TCB = undefined;
    var newbprio: TaskPrio = undefined;
    
    log.chgPriEnter(tskid, tskpri);
    errdefer |err| log.chgPriLeave(err);
    try checkContextTaskUnlock();               //［NGKI1184］［NGKI1185］
    if (tskid == TSK_SELF) {
        p_tcb = p_runtsk.?;                     //［NGKI1198］
    }
    else {
        p_tcb = try checkAndGetTCB(tskid);      //［NGKI1187］
    }
    if (tskpri == TPRI_INI) {                   //［NGKI1199］
        newbprio = @intCast(TaskPrio, p_tcb.p_tinib.ipri);
    }
    else {
        try checkParameter(validTaskPri(tskpri));   //［NGKI1188］
        newbprio = internalTaskPrio(tskpri);
    }
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (isDormant(p_tcb.tstat)) {           //［NGKI1191］
            return ItronError.ObjectStateError;
        }
        else if ((p_tcb.p_lastmtx != null or isWaitingMtx(p_tcb.tstat))
                     and !mtxhook_check_ceilpri.?(p_tcb, newbprio)) {
            return ItronError.IllegalUse;       //［NGKI1201］
        }
        else {
            p_tcb.bprio = newbprio;             //［NGKI1192］
            if (p_tcb.p_lastmtx == null or !mtxhook_scan_ceilmtx.?(p_tcb)) {
                change_priority(p_tcb, newbprio, false);    //［NGKI1193］
                taskDispatch();
            }                                   //［NGKI1197］
        }
    }
    log.chgPriLeave(null);
}

///
///  タスク優先度の参照［NGKI1202］
///
pub fn get_pri(tskid: ID, p_tskpri: *PRI) ItronError!void {
    var p_tcb: *TCB = undefined;

    log.getPriEnter(tskid, p_tskpri);
    errdefer |err| log.getPriLeave(err, p_tskpri);
    try checkContextTaskUnlock();               //［NGKI1203］［NGKI1204］
    if (tskid == TSK_SELF) {
        p_tcb = p_runtsk.?;                     //［NGKI1211］
    }
    else {
        p_tcb = try checkAndGetTCB(tskid);      //［NGKI1205］
    }
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (isDormant(p_tcb.tstat)) {           //［NGKI1209］
            return ItronError.ObjectStateError;
        }
        else {                                  //［NGKI1210］
            p_tskpri.* = externalTaskPrio(p_tcb.prio);
        }
    }
    log.getPriLeave(null, p_tskpri);
}

/// 自タスクの拡張情報の参照
pub fn get_inf(p_exinf: *EXINF) ItronError!void {
    log.getInfEnter(p_exinf);
    errdefer |err| log.getInfLeave(err, p_exinf);
    try checkContextTaskUnlock();               //［NGKI1213］［NGKI1214］

    p_exinf.* = p_runtsk.?.p_tinib.exinf;       //［NGKI1216］
    log.getInfLeave(null, p_exinf);
}
