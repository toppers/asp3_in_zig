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
///  システム状態管理機能
///
usingnamespace @import("kernel_impl.zig");
usingnamespace task;
usingnamespace check;

///
///  タスクの優先順位の回転［NGKI3548］
///
pub fn rot_rdq(tskpri: PRI) ItronError!void {
    var prio: TaskPrio = undefined;

    traceLog("rotRdqEnter", .{ tskpri });
    errdefer |err| traceLog("rotRdqLeave", .{ err });
    try checkContextUnlock();                   //［NGKI2684］
    if (tskpri == TPRI_SELF and !target_impl.senseContext()) {
        prio = p_runtsk.?.bprio;                //［NGKI2689］
    }
    else {
        try checkParameter(validTaskPri(tskpri));   //［NGKI2685］
        prio = internalTaskPrio(tskpri);
    }
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        rotate_ready_queue(prio);
        requestTaskDispatch();
    }
    traceLog("rotRdqLeave", .{ null });
}

///
///  実行状態のタスクIDの参照［NGKI3550］
///
pub fn get_tid(p_tskid: *ID) ItronError!void {
    traceLog("getTidEnter", .{ p_tskid });
    errdefer |err| traceLog("getTidLeave", .{ err, p_tskid });
    try checkContextUnlock();                   //［NGKI2707］

    if (p_runtsk) |p_tcb| {
        p_tskid.* = getTskIdFromTCB(p_tcb);    //［NGKI2709］
    }
    else {
        p_tskid.* = TSK_NONE;                   //［NGKI2710］
    }
    traceLog("getTidLeave", .{ null, p_tskid });
}

///
///  実行できるタスクの数の参照［NGKI3623］
///
pub fn get_lod(tskpri: PRI, p_load: *c_uint) ItronError!void {
    var prio: TaskPrio = undefined;
    var load: c_uint = 0;

    traceLog("getLodEnter", .{ tskpri, p_load });
    errdefer |err| traceLog("getLodLeave", .{ err, p_load });
    try checkContextTaskUnlock();               //［NGKI3624］［NGKI3625］
    if (tskpri == TPRI_SELF) {
        prio = p_runtsk.?.bprio;                //［NGKI3631］
    }
    else {
        try checkParameter(validTaskPri(tskpri));   //［NGKI3626］
        prio = internalTaskPrio(tskpri);
    }
    var p_queue = &ready_queue[prio];
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        var p_entry = p_queue.p_next;
        while (p_entry != p_queue): (p_entry = p_entry.p_next) {
            load += 1;
        }
        p_load.* = load;
    }
    traceLog("getLodLeave", .{ null, p_load });
}

///
///  指定した優先順位のタスクIDの参照［NGKI3641］
///
pub fn get_nth(tskpri: PRI, nth: c_uint, p_tskid: *ID) ItronError!void {
    var prio: TaskPrio = undefined;

    traceLog("getNthEnter", .{ tskpri, nth, p_tskid });
    errdefer |err| traceLog("getNthLeave", .{ err, p_tskid });
    try checkContextTaskUnlock();               //［NGKI3642］［NGKI3643］
    if (tskpri == TPRI_SELF) {
        prio = p_runtsk.?.bprio;                //［NGKI3650］
    }
    else {
        try checkParameter(validTaskPri(tskpri));   //［NGKI3644］
        prio = internalTaskPrio(tskpri);
    }
    var p_queue = &ready_queue[prio];
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        var count: c_uint = 0;
        var p_entry = p_queue.p_next;
        while (p_entry != p_queue): (p_entry = p_entry.p_next) {
            if (count == nth) {
                p_tskid.* = getTskIdFromTCB(getTCBFromQueue(p_entry));
                break;
            }
            count += 1;
        }
        else {
            p_tskid.* = TSK_NONE;
        }
    }
    traceLog("getNthLeave", .{ null, p_tskid });
}

///
///  CPUロック状態への遷移［NGKI3538］
///
pub fn loc_cpu() ItronError!void {
    traceLog("locCpuEnter", .{});
    if (!target_impl.senseLock()) {             //［NGKI2731］
        target_impl.lockCpu();                  //［NGKI2730］
    }
    traceLog("locCpuLeave", .{ null });
}

///
///  CPUロック状態の解除［NGKI3539］
///
///  CPUロック中は，ディスパッチが必要となるサービスコールを呼び出すこ
///  とはできないため，CPUロック状態の解除時にディスパッチャを起動する
///  必要はない．
///
pub fn unl_cpu() ItronError!void {
    traceLog("unlCpuEnter", .{});
    if (target_impl.senseLock()) {              //［NGKI2738］
        target_impl.unlockCpu();                //［NGKI2737］
    }
    traceLog("unlCpuLeave", .{ null });
}

///
///  ディスパッチの禁止［NGKI2740］
///
pub fn dis_dsp() ItronError!void {
    traceLog("disDspEnter", .{});
    errdefer |err| traceLog("disDspLeave", .{ err });
    try checkContextTaskUnlock();               //［NGKI2741］［NGKI2742］
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        enadsp = false;
        dspflg = false;
    }
    traceLog("disDspLeave", .{ null });
}

///
///  ディスパッチの許可［NGKI2746］
///
pub fn ena_dsp() ItronError!void {
    traceLog("enaDspEnter", .{});
    errdefer |err| traceLog("enaDspLeave", .{ err });
    try checkContextTaskUnlock();               //［NGKI2747］［NGKI2748］
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        enadsp = true;
        if (target_impl.getIpm() == TIPM_ENAALL) {
            set_dspflg();
            if (p_runtsk.?.flags.raster and p_runtsk.?.flags.enater) {
                if (TOPPERS_SUPPORT_OVRHDR) {
                    if (p_runtsk.?.flags.staovr) {
                        _ = target_timer.ovrtimer.stop();
                    }
                }
                task_terminate(p_runtsk.?);
                target_impl.exitAndDispatch();
            }
            else {
                taskDispatch();
            }
        }
    }
    traceLog("enaDspLeave", .{ null });
}

///
///  コンテキストの参照［NGKI2752］
///
pub fn sns_ctx() bool {
    traceLog("snsCtxEnter", .{});
    var state = target_impl.senseContext();
    traceLog("snsCtxLeave", .{ state });
    return state;
}

///
///  CPUロック状態の参照［NGKI2754］
///
pub fn sns_loc() bool {
    traceLog("snsLocEnter", .{});
    var state = target_impl.senseLock();
    traceLog("snsLocLeave", .{ state });
    return state;
}

///
///  ディスパッチ禁止状態の参照［NGKI2756］
///
pub fn sns_dsp() bool {
    traceLog("snsDspEnter", .{});
    var state = !enadsp;
    traceLog("snsDspLeave", .{ state });
    return state;
}

///
///  ディスパッチ保留状態の参照［NGKI2758］
///
pub fn sns_dpn() bool {
    traceLog("snsDpnEnter", .{});
    var state = target_impl.senseContext() or target_impl.senseLock()
                                           or !dspflg;
    traceLog("snsDpnLeave", .{ state });
    return state;
}

///
///  カーネル非動作状態の参照［NGKI2760］
///
pub fn sns_ker() bool {
    traceLog("snsKerEnter", .{});
    var state = !startup.kerflg;
    traceLog("snsKerLeave", .{ state });
    return state;
}
