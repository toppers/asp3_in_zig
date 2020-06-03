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
///  タスク終了機能
///
usingnamespace @import("kernel_impl.zig");
usingnamespace task;
usingnamespace wait;
usingnamespace check;

///
///  自タスクの終了［NGKI1162］
///
pub fn ext_tsk() ItronError!void {
    traceLog("extTskEnter", .{});
    errdefer |err| traceLog("extTskLeave", .{ err });
    try checkContextTask();                     //［NGKI1164］

    if (target_impl.senseLock()) {
        // CPUロック状態でext_tskが呼ばれた場合は，CPUロックを解除して
        // からタスクを終了する．実装上は，サービスコール内でのCPUロッ
        // クを省略すればよいだけ．［NGKI1168］
    }
    else {
        target_impl.lockCpu();
    }
    if (!dspflg) {
        if (!enadsp) {
            // ディスパッチ禁止状態でext_tskが呼ばれた場合は，ディスパッ
            // チ許可状態にしてからタスクを終了する．［NGKI1168］
            enadsp = true;
        }
        if (target_impl.getIpm() != TIPM_ENAALL) {
            // 割込み優先度マスク（IPM）がTIPM_ENAALL以外の状態で
            // ext_tskが呼ばれた場合は，IPMをTIPM_ENAALLにしてからタス
            // クを終了する．［NGKI1168］
            target_impl.setIpm(TIPM_ENAALL);
        }
        set_dspflg();
    }
    if (TOPPERS_SUPPORT_OVRHDR) {
        if (p_runtsk.?.flags.staovr) {
            _ = target_timer.ovrtimer.stop();
        }
    }
    task_terminate(p_runtsk.?);                 //［NGKI3449］
    target_impl.exitAndDispatch();              //［NGKI1169］
}

///
///  タスクの終了要求［NGKI3469］
///
pub fn ras_ter(tskid : ID) ItronError!void {
    traceLog("rasTerEnter", .{ tskid });
    errdefer |err| traceLog("rasTerLeave", .{ err });
    try checkContextTaskUnlock();               //［NGKI3470］［NGKI3471］
    const p_tcb = try checkAndGetTCB(tskid);    //［NGKI3472］
    try checkIllegalUse(p_tcb != p_runtsk);     //［NGKI3475］
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (isDormant(p_tcb.tstat)) {           //［NGKI3476］
            return ItronError.ObjectStateError;
        }
        else if (p_tcb.flags.enater) {
            task_terminate(p_tcb);              //［NGKI3477］
            if (p_runtsk != p_schedtsk) {
                target_impl.dispatch();
            }
        }
        else {
            p_tcb.flags.raster = true;          //［NGKI3478］
            if (!isRunnable(p_tcb.tstat)) {
                if (isWaiting(p_tcb.tstat)) {
                    wait_dequeue_wobj(p_tcb);   //［NGKI3479］
                    wait_dequeue_tmevtb(p_tcb);
                    p_tcb.p_winfo.* = WINFO{ .werror =
                                      ItronError.TerminationRequestRaised };
                }                               //［NGKI3480］
                p_tcb.tstat = TS_RUNNABLE;      //［NGKI3606］
                traceLog("taskStateChange", .{ p_tcb });
                make_runnable(p_tcb);
                if (p_runtsk != p_schedtsk) {
                    target_impl.dispatch();
                }
            }
        }
    }
    traceLog("rasTerLeave", .{ null });
}

///
///  タスク終了の禁止［NGKI3482］
///
pub fn dis_ter() ItronError!void {
    traceLog("disTerEnter", .{});
    errdefer |err| traceLog("disTerLeave", .{ err });
    try checkContextTaskUnlock();               //［NGKI3483］［NGKI3484］
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        p_runtsk.?.flags.enater = false;        //［NGKI3486］
    }
    traceLog("disTerLeave", .{ null });
}

///
///  タスク終了の許可
///
pub fn ena_ter() ItronError!void {
    traceLog("enaTerEnter", .{});
    errdefer |err| traceLog("enaTerLeave", .{ err });
    try checkContextTaskUnlock();               //［NGKI3488］［NGKI3489］
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (p_runtsk.?.flags.raster and dspflg) {
            if (TOPPERS_SUPPORT_OVRHDR) {
                if (p_runtsk.?.flags.staovr) {
                    _ = target_timer.ovrtimer.stop();
                }
            }
            task_terminate(p_runtsk.?);
            target_impl.exitAndDispatch();
        }
        else {
            p_runtsk.?.flags.enater = true;     //［NGKI3491］
        }
    }
    traceLog("enaTerLeave", .{ null });
}

///
///  タスク終了禁止状態の参照［NGKI3494］
///
pub fn sns_ter() bool {
    traceLog("snsTerEnter", .{});
    // enaterを変更できるのは自タスクのみであるため，排他制御せずに読
    // んでも問題ない．
    var state = if (p_runtsk) |p_tcb| !p_tcb.flags.enater else true;
    traceLog("snsTerLeave", .{ state });
    return state;
}

///
///  タスクの強制終了［NGKI1170］
///
pub fn ter_tsk(tskid : ID) ItronError!void {
    traceLog("terTskEnter", .{ tskid });
    errdefer |err| traceLog("terTskLeave", .{ err });
    try checkContextTaskUnlock();               //［NGKI1171］［NGKI1172］
    const p_tcb = try checkAndGetTCB(tskid);    //［NGKI1173］
    try checkIllegalUse(p_tcb != p_runtsk);     //［NGKI1176］
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (isDormant(p_tcb.tstat)) {           //［NGKI1177］
            return ItronError.ObjectStateError;
        }
        else {
            task_terminate(p_tcb);              //［NGKI3450］
            if (p_runtsk != p_schedtsk) {
                target_impl.dispatch();
            }
        }
    }
    traceLog("terTskLeave", .{ null });
}
