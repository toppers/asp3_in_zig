///
///  TOPPERS/ASP Kernel
///      Toyohashi Open Platform for Embedded Real-Time Systems/
///      Advanced Standard Profile Kernel
/// 
///  Copyright (C) 2020 by Embedded and Real-Time Systems Laboratory
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
///  トレースログ機能
///
usingnamespace @import("kernel_impl.zig");

///
///  処理単位の呼び出し
///
pub fn cyclicEnter(p_cyccb: *cyclic.CYCCB) void {
    if (@hasDecl(option.log, "cyclicEnter")) {
        option.log.cyclicEnter(p_cycccb);
    }
}
pub fn cyclicLeave(p_cyccb: *cyclic.CYCCB) void {
    if (@hasDecl(option.log, "cyclicLeave")) {
        option.log.cyclicLeave(p_cyccb);
    }
}
pub fn alarmEnter(p_almcb: *alarm.ALMCB) void {
    if (@hasDecl(option.log, "alarmEnter")) {
        option.log.alarmEnter(p_almcb);
    }
}
pub fn alarmLeave(p_almcb: *alarm.ALMCB) void {
    if (@hasDecl(option.log, "alarmLeave")) {
        option.log.alarmLeave(p_almcb);
    }
}
pub fn overrunEnter(p_tcb: *task.TCB) void {
    if (@hasDecl(option.log, "overrunEnter")) {
        option.log.overrunEnter(p_tcb);
    }
}
pub fn overrunLeave(p_tcb: *task.TCB) void {
    if (@hasDecl(option.log, "overrunLeave")) {
        option.log.overrunLeave(p_tcb);
    }
}
pub fn interruptHandlerEnter(inhno: INHNO) void {
    if (@hasDecl(option.log, "interruptHandlerEnter")) {
        option.log.interruptHandlerEnter(inhno);
    }
}
pub fn interruptHandlerLeave(inhno: INHNO) void {
    if (@hasDecl(option.log, "interruptHandlerLeave")) {
        option.log.interruptHandlerLeave(inhno);
    }
}
pub fn isrEnter(isrid: ID) void {
    if (@hasDecl(option.log, "isrEnter")) {
        option.log.isrEnter(inhno);
    }
}
pub fn isrLeave(isrid: ID) void {
    if (@hasDecl(option.log, "isrLeave")) {
        option.log.isrLeave(inhno);
    }
}
pub fn exceptionHandlerEnter(excno: EXCNO) void {
    if (@hasDecl(option.log, "exceptionHandlerEnter")) {
        option.log.exceptionHandlerEnter(excno);
    }
}
pub fn exceptionHandlerLeave(excno: EXCNO) void {
    if (@hasDecl(option.log, "exceptionHandlerLeave")) {
        option.log.exceptionHandlerLeave(excno);
    }
}

///
///  タスク状態変化
///
pub fn taskStateChange(p_tcb: *task.TCB) void {
    if (@hasDecl(option.log, "taskStateChange")) {
        option.log.taskStateChange(p_tcb);
    }
}

///
///  ディスパッチャ
///
pub fn dispatchEnter(p_tcb: *task.TCB) void {
    if (@hasDecl(option.log, "dispatchEnter")) {
        option.log.dispatchEnter(p_tcb);
    }
}
pub fn dispatchLeave(p_tcb: *task.TCB) void {
    if (@hasDecl(option.log, "dispatchLeave")) {
        option.log.dispatchLeave(p_tcb);
    }
}

///
///  カーネル
///
pub fn kernelEnter() void {
    if (@hasDecl(option.log, "kernelEnter")) {
        option.log.kernelEnter();
    }
}
pub fn kernelLeave() void {
    if (@hasDecl(option.log, "kernelLeave")) {
        option.log.kernelLeave();
    }
}

///
///  サービスコールの呼び出し
///
// タスク管理機能
pub fn actTskEnter(tskid: ID) void {
    if (@hasDecl(option.log, "actTskEnter")) {
        option.log.actTskEnter(tskid);
    }
}
pub fn actTskLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "actTskLeave")) {
        option.log.actTskLeave(err);
    }
}
pub fn canActEnter(tskid: ID) void {
    if (@hasDecl(option.log, "canActEnter")) {
        option.log.canActEnter(tskid);
    }
}
pub fn canActLeave(err: ItronError!c_uint) void {
    if (@hasDecl(option.log, "canActLeave")) {
        option.log.canActLeave(err);
    }
}
pub fn getTstEnter(tskid: ID, p_tskstat: *STAT) void {
    if (@hasDecl(option.log, "getTstEnter")) {
        option.log.getTstEnter(tskid, p_tskstat);
    }
}
pub fn getTstLeave(err: ?ItronError, p_tskstat: *STAT) void {
    if (@hasDecl(option.log, "getTstLeave")) {
        option.log.getTstLeave(err, p_tskstat);
    }
}
pub fn chgPriEnter(tskid: ID, tskpri: PRI) void {
    if (@hasDecl(option.log, "chgPriEnter")) {
        option.log.chgPriEnter(tskid, tskpri);
    }
}
pub fn chgPriLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "chgPriLeave")) {
        option.log.chgPriLeave(err);
    }
}
pub fn getPriEnter(tskid: ID, p_tskpri: *PRI) void {
    if (@hasDecl(option.log, "getPriEnter")) {
        option.log.getPriEnter(tskid, p_tskpri);
    }
}
pub fn getPriLeave(err: ?ItronError, p_tskpri: *PRI) void {
    if (@hasDecl(option.log, "getPriLeave")) {
        option.log.getPriLeave(err, p_tskpri);
    }
}
pub fn getInfEnter(p_exinf: *EXINF) void {
    if (@hasDecl(option.log, "getInfEnter")) {
        option.log.getInfEnter(p_exinf);
    }
}
pub fn getInfLeave(err: ?ItronError, p_exinf: *EXINF) void {
    if (@hasDecl(option.log, "getInfLeave")) {
        option.log.getInfLeave(err, p_exinf);
    }
}
pub fn refTskEnter(tskid: ID, pk_rtsk: *T_RTSK) void {
    if (@hasDecl(option.log, "refTskEnter")) {
        option.log.refTskEnter(tskid);
    }
}
pub fn refTskLeave(err: ?ItronError, pk_rtsk: *T_RTSK) void {
    if (@hasDecl(option.log, "refTskLeave")) {
        option.log.refTskLeave(err, pk_rtsk);
    }
}

// タスク付属同期機能
pub fn slpTskEnter() void {
    if (@hasDecl(option.log, "slpTskEnter")) {
        option.log.slpTskEnter();
    }
}
pub fn slpTskLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "slpTskLeave")) {
        slpTskLeave(err);
    }
}
pub fn tSlpTskEnter(tmout: TMO) void {
    if (@hasDecl(option.log, "tSlpTskEnter")) {
        option.log.tSlpTskEnter(tmout);
    }
}
pub fn tSlpTskLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "tSlpTskLeave")) {
        option.log.tSlpTskLeave(err);
    }
}
pub fn wupTskEnter(tskid: ID) void {
    if (@hasDecl(option.log, "wupTskEnter")) {
        option.log.wupTskEnter(tskid);
    }
}
pub fn wupTskLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "wupTskLeave")) {
        option.log.wupTskLeave(err);
    }
}
pub fn canWupEnter(tskid: ID) void {
    if (@hasDecl(option.log, "canWupEnter")) {
        option.log.canWupEnter(tskid);
    }
}
pub fn canWupLeave(err: ItronError!c_uint) void {
    if (@hasDecl(option.log, "canWupLeave")) {
        option.log.canWupLeave(err);
    }
}
pub fn relWaiEnter(tskid: ID) void {
    if (@hasDecl(option.log, "relWaiEnter")) {
        option.log.relWaiEnter(tskid);
    }
}
pub fn relWaiLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "relWaiLeave")) {
        option.log.relWaiLeave(err);
    }
}
pub fn susTskEnter(tskid: ID) void {
    if (@hasDecl(option.log, "susTskEnter")) {
        option.log.susTskEnter(tskid);
    }
}
pub fn susTskLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "susTskLeave")) {
        option.log.susTskLeave(err);
    }
}
pub fn rsmTskEnter(tskid: ID) void {
    if (@hasDecl(option.log, "rsmTskEnter")) {
        option.log.rsmTskEnter(tskid);
    }
}
pub fn rsmTskLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "rsmTskLeave")) {
        option.log.rsmTskLeave(err);
    }
}
pub fn dlyTskEnter(dlytim: RELTIM) void {
    if (@hasDecl(option.log, "dlyTskEnter")) {
        option.log.dlyTskEnter(dlytim);
    }
}
pub fn dlyTskLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "dlyTskLeave")) {
        option.log.dlyTskLeave(err);
    }
}

// タスク終了機能
pub fn extTskEnter() void {
    if (@hasDecl(option.log, "extTskEnter")) {
        option.log.extTskEnter();
    }
}
pub fn extTskLeave(err: ItronError!void) void {
    if (@hasDecl(option.log, "extTskLeave")) {
        option.log.extTskLeave(err);
    }
}
pub fn rasTerEnter(tskid: ID) void {
    if (@hasDecl(option.log, "rasTerEnter")) {
        option.log.rasTerEnter(tskid);
    }
}
pub fn rasTerLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "rasTerLeave")) {
        option.log.rasTerLeave(err);
    }
}
pub fn disTerEnter() void {
    if (@hasDecl(option.log, "disTerEnter")) {
        option.log.disTerEnter();
    }
}
pub fn disTerLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "disTerLeave")) {
        option.log.disTerLeave(err);
    }
}
pub fn enaTerEnter() void {
    if (@hasDecl(option.log, "enaTerEnter")) {
        option.log.enaTerEnter();
    }
}
pub fn enaTerLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "enaTerLeave")) {
        option.log.enaTerLeave(err);
    }
}
pub fn snsTerEnter() void {
    if (@hasDecl(option.log, "snsTerEnter")) {
        option.log.snsTerEnter();
    }
}
pub fn snsTerLeave(state: bool) void {
    if (@hasDecl(option.log, "snsTerLeave")) {
        option.log.snsTerLeave(state);
    }
}
pub fn terTskEnter(tskid: ID) void {
    if (@hasDecl(option.log, "terTskEnter")) {
        option.log.terTskEnter(tskid);
    }
}
pub fn terTskLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "terTskLeave")) {
        option.log.terTskLeave(err);
    }
}

// セマフォ機能
pub fn sigSemEnter(semid: ID) void {
    if (@hasDecl(option.log, "sigSemEnter")) {
        option.log.sigSemEnter(semid);
    }
}
pub fn sigSemLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "sigSemLeave")) {
        option.log.sigSemLeave(err);
    }
}
pub fn waiSemEnter(semid: ID) void {
    if (@hasDecl(option.log, "waiSemEnter")) {
        option.log.waiSemEnter(semid);
    }
}
pub fn waiSemLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "waiSemLeave")) {
        option.log.waiSemLeave(err);
    }
}
pub fn polSemEnter(semid: ID) void {
    if (@hasDecl(option.log, "polSemEnter")) {
        option.log.polSemEnter(semid);
    }
}
pub fn polSemLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "polSemLeave")) {
        option.log.polSemLeave(err);
    }
}
pub fn tWaiSemEnter(semid: ID, tmout: TMO) void {
    if (@hasDecl(option.log, "tWaiSemEnter")) {
        option.log.tWaiSemEnter(semid, tmout);
    }
}
pub fn tWaiSemLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "tWaiSemLeave")) {
        option.log.tWaiSemLeave(err);
    }
}
pub fn iniSemEnter(semid: ID) void {
    if (@hasDecl(option.log, "iniSemEnter")) {
        option.log.iniSemEnter(semid);
    }
}
pub fn iniSemLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "iniSemLeave")) {
        option.log.iniSemLeave(err);
    }
}
pub fn refSemEnter(semid: ID, pk_rsem: *T_RSEM) void {
    if (@hasDecl(option.log, "refSemEnter")) {
        option.log.refSemEnter(semid, pk_rsem);
    }
}
pub fn refSemLeave(err: ?ItronError, pk_rsem: *T_RSEM) void {
    if (@hasDecl(option.log, "refSemLeave")) {
        option.log.refSemLeave(err, pk_rsem);
    }
}

// イベントフラグ機能
pub fn setFlgEnter(flgid: ID, setptn: FLGPTN) void {
    if (@hasDecl(option.log, "setFlgEnter")) {
        option.log.setFlgEnter(flgid, setptn);
    }
}
pub fn setFlgLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "setFlgLeave")) {
        option.log.setFlgLeave(err);
    }
}
pub fn clrFlgEnter(flgid: ID, clrptn: FLGPTN) void {
    if (@hasDecl(option.log, "clrFlgEnter")) {
        option.log.clrFlgEnter(flgid, clrptn);
    }
}
pub fn clrFlgLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "clrFlgLeave")) {
        option.log.clrFlgLeave(err);
    }
}
pub fn waiFlgEnter(flgid: ID, waiptn: FLGPTN,
                   wfmode :MODE, p_flgptn: *FLGPTN) void {
    if (@hasDecl(option.log, "waiFlgEnter")) {
        option.log.waiFlgEnter(flgid, waiptn, wfmode, p_flgptn);
    }
}
pub fn waiFlgLeave(err: ?ItronError, p_flgptn: *FLGPTN) void {
    if (@hasDecl(option.log, "waiFlgLeave")) {
        option.log.waiFlgLeave(err, p_flgptn);
    }
}
pub fn polFlgEnter(flgid: ID, waiptn: FLGPTN,
                   wfmode :MODE, p_flgptn: *FLGPTN) void {
    if (@hasDecl(option.log, "polFlgEnter")) {
        option.log.polFlgEnter(flgid, waiptn, wfmode, p_flptn);
    }
}
pub fn polFlgLeave(err: ?ItronError, p_flgptn: *FLGPTN) void {
    if (@hasDecl(option.log, "polFlgLeave")) {
        option.log.polFlgLeave(err, p_flgptn);
    }
}
pub fn tWaiFlgEnter(flgid: ID, waiptn: FLGPTN, wfmode :MODE,
                    p_flgptn: *FLGPTN, tmout: TMO) void {
    if (@hasDecl(option.log, "tWaiFlgEnter")) {
        option.log.tWaiFlgEnter(flgid, waiptn, wfmode, p_flgptn, tmout);
    }
}

pub fn tWaiFlgLeave(err: ?ItronError, p_flgptn: *FLGPTN) void {
    if (@hasDecl(option.log, "tWaiFlgLeave")) {
        option.log.tWaiFlgLeave(err, p_flgptn);
    }
}
pub fn iniFlgEnter(flgid: ID) void {
    if (@hasDecl(option.log, "iniFlgEnter")) {
        option.log.iniFlgEnter(flgid);
    }
}
pub fn iniFlgLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "iniFlgLeave")) {
        option.log.iniFlgLeave(err);
    }
}
pub fn refFlgEnter(flgid: ID, pk_rflg: *T_RFLG) void {
    if (@hasDecl(option.log, "refFlgEnter")) {
        option.log.refFlgEnter(flgid, pk_rflg);
    }
}
pub fn refFlgLeave(err: ?ItronError, pk_rflg: *T_RFLG) void {
    if (@hasDecl(option.log, "refFlgLeave")) {
        option.log.refFlgLeave(err, pk_rflg);
    }
}

// データキュー機能
pub fn sndDtqEnter(dtqid: ID, data: usize) void {
    if (@hasDecl(option.log, "sndDtqEnter")) {
        option.log.sndDtqEnter(dtqid, data);
    }
}
pub fn sndDtqLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "sndDtqLeave")) {
        option.log.sndDtqLeave(err);
    }
}
pub fn pSndDtqEnter(dtqid: ID, data: usize) void {
    if (@hasDecl(option.log, "pSndDtqEnter")) {
        option.log.pSndDtqEnter(dtqid, data);
    }
}
pub fn pSndDtqLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "pSndDtqLeave")) {
        option.log.pSndDtqLeave(err);
    }
}
pub fn tSndDtqEnter(dtqid: ID, data: usize, tmout: TMO) void {
    if (@hasDecl(option.log, "tSndDtqEnter")) {
        option.log.tSndDtqEnter(dtqid, data, tmout);
    }
}
pub fn tSndDtqLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "tSndDtqLeave")) {
        option.log.tSndDtqLeave(err);
    }
}
pub fn fSndDtqEnter(dtqid: ID, data: usize) void {
    if (@hasDecl(option.log, "fSndDtqEnter")) {
        option.log.fSndDtqEnter(dtqid, data);
    }
}
pub fn fSndDtqLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "fSndDtqLeave")) {
        option.log.fSndDtqLeave(err);
    }
}
pub fn rcvDtqEnter(dtqid: ID, p_data: *usize) void {
    if (@hasDecl(option.log, "rcvDtqEnter")) {
        option.log.rcvDtqEnter(dtqid, p_data);
    }
}
pub fn rcvDtqLeave(err: ?ItronError, p_data: *usize) void {
    if (@hasDecl(option.log, "rcvDtqLeave")) {
        option.log.rcvDtqLeave(err, p_data);
    }
}
pub fn prcvDtqEnter(dtqid: ID, p_data: *usize) void {
    if (@hasDecl(option.log, "prcvDtqEnter")) {
        option.log.prcvDtqEnter(dtqid, p_data);
    }
}
pub fn prcvDtqLeave(err: ?ItronError, p_data: *usize) void {
    if (@hasDecl(option.log, "prcvDtqLeave")) {
        option.log.prcvDtqLeave(err, p_data);
    }
}
pub fn tRcvDtqEnter(dtqid: ID, p_data: *usize, tmout: TMO) void {
    if (@hasDecl(option.log, "tRcvDtqEnter")) {
        option.log.tRcvDtqEnter(dtqid, p_data, tmout);
    }
}
pub fn tRcvDtqLeave(err: ?ItronError, p_data: *usize) void {
    if (@hasDecl(option.log, "tRcvDtqLeave")) {
        option.log.tRcvDtqLeave(err, p_data);
    }
}
pub fn iniDtqEnter(dtqid: ID) void {
    if (@hasDecl(option.log, "iniDtqEnter")) {
        option.log.iniDtqEnter(dtqid);
    }
}
pub fn iniDtqLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "iniDtqLeave")) {
        option.log.iniDtqLeave(err);
    }
}
pub fn refDtqEnter(dtqid: ID, pk_rdtq: *T_RDTQ) void {
    if (@hasDecl(option.log, "refDtqEnter")) {
        option.log.refDtqEnter(dtqid, pk_rdtq);
    }
}
pub fn refDtqLeave(err: ?ItronError, pk_rdtq: *T_RDTQ) void {
    if (@hasDecl(option.log, "refDtqLeave")) {
        option.log.refDtqLeave(err, pk_rdtq);
    }
}

// 優先度優先度データキュー機能
pub fn sndPdqEnter(pdqid: ID, data: usize, datapri: PRI) void {
    if (@hasDecl(option.log, "sndPdqEnter")) {
        option.log.sndPdqEnter(pdqid, data, datapri);
    }
}
pub fn sndPdqLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "sndPdqLeave")) {
        option.log.sndPdqLeave(err);
    }
}
pub fn psndPdqEnter(pdqid: ID, data: usize, datapri: PRI) void {
    if (@hasDecl(option.log, "psndPdqEnter")) {
        option.log.psndPdqEnter(pdqid, data, datapri);
    }
}
pub fn psndPdqLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "psndPdqLeave")) {
        option.log.psndPdqLeave(err);
    }
}
pub fn tSndPdqEnter(pdqid: ID, data: usize, datapri: PRI, tmout: TMO) void {
    if (@hasDecl(option.log, "tSndPdqEnter")) {
        option.log.tSndPdqEnter(pdqid, data, datapri, tmout);
    }
}
pub fn tSndPdqLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "tSndPdqLeave")) {
        option.log.tSndPdqLeave(err);
    }
}
pub fn rcvPdqEnter(pdqid: ID, p_data: *usize, p_datapri: *PRI) void {
    if (@hasDecl(option.log, "rcvPdqEnter")) {
        option.log.rcvPdqEnter(pdqid, p_data, p_datapri);
    }
}
pub fn rcvPdqLeave(err: ?ItronError, p_data: *usize, p_datapri: *PRI) void {
    if (@hasDecl(option.log, "rcvPdqLeave")) {
        option.log.rcvPdqLeave(err, p_data, p_datapri);
    }
}
pub fn pRcvPdqEnter(pdqid: ID, p_data: *usize, p_datapri: *PRI) void {
    if (@hasDecl(option.log, "pRcvPdqEnter")) {
        option.log.pRcvPdqEnter(pdqid, p_data, p_datapri);
    }
}
pub fn pRcvPdqLeave(err: ?ItronError, p_data: *usize, p_datapri: *PRI) void {
    if (@hasDecl(option.log, "pRcvPdqLeave")) {
        option.log.pRcvPdqLeave(err, p_data, p_datapri);
    }
}
pub fn tRcvPdqEnter(pdqid: ID, p_data: *usize,
                    p_datapri: *PRI, tmout: TMO) void {
    if (@hasDecl(option.log, "tRcvPdqEnter")) {
        option.log.tRcvPdqEnter(pdqid, p_data, p_datapri, tmout);
    }
}
pub fn tRcvPdqLeave(err: ?ItronError, p_data: *usize, p_datapri: *PRI) void {
    if (@hasDecl(option.log, "tRcvPdqLeave")) {
        option.log.tRcvPdqLeave(err, p_data, p_datapri);
    }
}
pub fn iniPdqEnter(pdqid: ID) void {
    if (@hasDecl(option.log, "iniPdqEnter")) {
        option.log.iniPdqEnter(pdqid);
    }
}
pub fn iniPdqLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "iniPdqLeave")) {
        option.log.iniPdqLeave(err);
    }
}
pub fn refPdqEnter(pdqid: ID, pk_rpdq: *T_RPDQ) void {
    if (@hasDecl(option.log, "refPdqEnter")) {
        option.log.refPdqEnter(pdqid, pk_rpdq);
    }
}
pub fn refPdqLeave(err: ?ItronError, pk_rpdq: *T_RPDQ) void {
    if (@hasDecl(option.log, "refPdqLeave")) {
        option.log.refPdqLeave(err, pk_rpdq);
    }
}

// ミューテックス機能
pub fn locMtxEnter(mtxid: ID) void {
    if (@hasDecl(option.log, "locMtxEnter")) {
        option.log.locMtxEnter(mtxid);
    }
}
pub fn locMtxLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "locMtxLeave")) {
        option.log.locMtxLeave(err);
    }
}
pub fn pLocMtxEnter(mtxid: ID) void {
    if (@hasDecl(option.log, "pLocMtxEnter")) {
        option.log.pLocMtxEnter(mtxid);
    }
}
pub fn pLocMtxLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "pLocMtxLeave")) {
        option.log.pLocMtxLeave(err);
    }
}
pub fn tLocMtxEnter(mtxid: ID, tmout: TMO) void {
    if (@hasDecl(option.log, "tLocMtxEnter")) {
        option.log.tLocMtxEnter(mtxid);
    }
}
pub fn tLocMtxLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "tLocMtxLeave")) {
        option.log.tLocMtxLeave(err);
    }
}
pub fn unlMtxEnter(mtxid: ID) void {
    if (@hasDecl(option.log, "unlMtxEnter")) {
        option.log.unlMtxEnter(mtxid);
    }
}
pub fn unlMtxLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "unlMtxLeave")) {
        option.log.unlMtxLeave(err);
    }
}
pub fn iniMtxEnter(mtxid: ID) void {
    if (@hasDecl(option.log, "iniMtxEnter")) {
        option.log.iniMtxEnter(mtxid);
    }
}
pub fn iniMtxLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "iniMtxLeave")) {
        option.log.iniMtxLeave(err);
    }
}
pub fn refMtxEnter(mtxid: ID, pk_rmtx: *T_RMTX) void {
    if (@hasDecl(option.log, "refMtxEnter")) {
        option.log.refMtxEnter(mtxid, pk_rmtx);
    }
}
pub fn refMtxLeave(err: ?ItronError, pk_rmtx: *T_RMTX) void {
    if (@hasDecl(option.log, "refMtxLeave")) {
        option.log.refMtxLeave(err, pk_rmtx);
    }
}

// 固定長メモリプール機能
pub fn getMpfEnter(mpfid: ID, p_blk: **u8) void {
    if (@hasDecl(option.log, "getMpfEnter")) {
        option.log.getMpfEnter(mpfid, p_blk);
    }
}
pub fn getMpfLeave(err: ?ItronError, p_blk: **u8) void {
    if (@hasDecl(option.log, "getMpfLeave")) {
        option.log.getMpfLeave(err, p_blk);
    }
}
pub fn pGetMpfEnter(mpfid: ID, p_blk: **u8) void {
    if (@hasDecl(option.log, "pGetMpfEnter")) {
        option.log.pGetMpfEnter(mpfid, p_blk);
    }
}
pub fn pGetMpfLeave(err: ?ItronError, p_blk: **u8) void {
    if (@hasDecl(option.log, "pGetMpfLeave")) {
        option.log.pGetMpfLeave(err, p_blk);
    }
}
pub fn tGetMpfEnter(mpfid: ID, p_blk: **u8, tmout: TMO) void {
    if (@hasDecl(option.log, "tGetMpfEnter")) {
        option.log.tGetMpfEnter(mpfid, p_blk, tmout);
    }
}
pub fn tGetMpfLeave(err: ?ItronError, p_blk: **u8) void {
    if (@hasDecl(option.log, "tGetMpfLeave")) {
        option.log.tGetMpfLeave(err, p_blk);
    }
}
pub fn relMpfEnter(mpfid: ID, blk: *u8) void {
    if (@hasDecl(option.log, "relMpfEnter")) {
        option.log.relMpfEnter(mpfid, blk);
    }
}
pub fn relMpfLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "relMpfLeave")) {
        option.log.relMpfLeave(err);
    }
}
pub fn iniMpfEnter(mpfid: ID) void {
    if (@hasDecl(option.log, "iniMpfEnter")) {
        option.log.iniMpfEnter(mpfid);
    }
}
pub fn iniMpfLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "iniMpfLeave")) {
        option.log.iniMpfLeave(err);
    }
}
pub fn refMpfEnter(mpfid: ID, pk_rmpf: *T_RMPF) void {
    if (@hasDecl(option.log, "refMpfEnter")) {
        option.log.refMpfEnter(mpfid, pk_rmpf);
    }
}
pub fn refMpfLeave(err: ?ItronError, pk_rmpf: *T_RMPF) void {
    if (@hasDecl(option.log, "refMpfLeave")) {
        option.log.refMpfLeave(err, pk_rmpf);
    }
}

// システム時刻管理機能
pub fn setTimEnter(systim: SYSTIM) void {
    if (@hasDecl(option.log, "setTimEnter")) {
        option.log.setTimEnter(systim);
    }
}
pub fn setTimLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "setTimLeave")) {
        option.log.setTimLeave(err);
    }
}
pub fn getTimEnter(p_systim: *SYSTIM) void {
    if (@hasDecl(option.log, "getTimEnter")) {
        option.log.getTimEnter(p_systim);
    }
}
pub fn getTimLeave(err: ?ItronError, p_systim: *SYSTIM) void {
    if (@hasDecl(option.log, "getTimLeave")) {
        option.log.getTimLeave(err);
    }
}
pub fn adjTimEnter(adjtim: i32) void {
    if (@hasDecl(option.log, "adjTimEnter")) {
        option.log.adjTimEnter(adjtim);
    }
}
pub fn adjTimLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "adjTimLeave")) {
        option.log.adjTimLeave(err);
    }
}
pub fn fchHrtEnter() void {
    if (@hasDecl(option.log, "fchHrtEnter")) {
        option.log.fchHrtEnter();
    }
}
pub fn fchHrtLeave(hrtcnt: HRTCNT) void {
    if (@hasDecl(option.log, "fchHrtLeave")) {
        option.log.fchHrtLeave(hrtcnt);
    }
}

// 周期通知機能
pub fn staCycEnter(cycid: ID) void {
    if (@hasDecl(option.log, "staCycEnter")) {
        option.log.staCycEnter(cycid);
    }
}
pub fn staCycLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "staCycLeave")) {
        option.log.staCycLeave(err);
    }
}
pub fn stpCycEnter(cycid: ID) void {
    if (@hasDecl(option.log, "stpCycEnter")) {
        option.log.stpCycEnter(cycid);
    }
}
pub fn stpCycLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "stpCycLeave")) {
        option.log.stpCycLeave(err);
    }
}
pub fn refCycEnter(cycid: ID, pk_rcyc: *T_RCYC) void {
    if (@hasDecl(option.log, "refCycEnter")) {
        option.log.refCycEnter(cycid, pk_rcyc);
    }
}
pub fn refCycLeave(err: ?ItronError, pk_rcyc: *T_RCYC) void {
    if (@hasDecl(option.log, "refCycLeave")) {
        option.log.refCycLeave(err, pk_rcyc);
    }
}

// アラーム通知機能
pub fn staAlmEnter(almid: ID, almtim: RELTIM) void {
    if (@hasDecl(option.log, "staAlmEnter")) {
        option.log.staAlmEnter(almid, almtim);
    }
}
pub fn staAlmLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "staAlmLeave")) {
        option.log.staAlmLeave(err);
    }
}
pub fn stpAlmEnter(almid: ID) void {
    if (@hasDecl(option.log, "stpAlmEnter")) {
        option.log.stpAlmEnter(almid);
    }
}
pub fn stpAlmLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "stpAlmLeave")) {
        option.log.stpAlmLeave(err);
    }
}
pub fn refAlmEnter(almid: ID, pk_ralm: *T_RALM) void {
    if (@hasDecl(option.log, "refAlmEnter")) {
        option.log.refAlmEnter(almid, pk_ralm);
    }
}
pub fn refAlmLeave(err: ?ItronError, pk_ralm: *T_RALM) void {
    if (@hasDecl(option.log, "refAlmLeave")) {
        option.log.refAlmLeave(err, pk_ralm);
    }
}

// オーバランハンドラ機能
pub fn staOvrEnter(tskid: ID, ovrtim: PRCTIM) void {
    if (@hasDecl(option.log, "staOvrEnter")) {
        option.log.staOvrEnter(tskid, ovrtim);
    }
}
pub fn staOvrLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "staOvrLeave")) {
        option.log.staOvrLeave(err);
    }
}
pub fn stpOvrEnter(tskid: ID) void {
    if (@hasDecl(option.log, "stpOvrEnter")) {
        option.log.stpOvrEnter(tskid);
    }
}
pub fn stpOvrLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "stpOvrLeave")) {
        option.log.stpOvrLeave(err);
    }
}
pub fn refOvrEnter(tskid: ID, pk_rovr: *T_ROVR) void {
    if (@hasDecl(option.log, "refOvrEnter")) {
        option.log.refOvrEnter(tskid, pk_rovr);
    }
}
pub fn refOvrLeave(err: ?ItronError, pk_rovr: *T_ROVR) void {
    if (@hasDecl(option.log, "refOvrLeave")) {
        option.log.refOvrLeave(err, pk_rovr);
    }
}

// システム状態管理機能
pub fn rotRdqEnter(tskpri: PRI) void {
    if (@hasDecl(option.log, "rotRdqEnter")) {
        option.log.rotRdqEnter(tskpri);
    }
}
pub fn rotRdqLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "rotRdqLeave")) {
        option.log.rotRdqLeave(err);
    }
}
pub fn getTidEnter(p_tskid: *ID) void {
    if (@hasDecl(option.log, "getTidEnter")) {
        option.log.getTidEnter(p_tskid);
    }
}
pub fn getTidLeave(err: ?ItronError, p_tskid: *ID) void {
    if (@hasDecl(option.log, "getTidLeave")) {
        option.log.getTidLeave(err, p_tskid);
    }
}
pub fn getLodEnter(tskpri: PRI, p_load: *c_uint) void {
    if (@hasDecl(option.log, "getLodEnter")) {
        option.log.getLodEnter(tskpri, p_load);
    }
}
pub fn getLodLeave(err: ?ItronError, p_load: *c_uint) void {
    if (@hasDecl(option.log, "getLodLeave")) {
        option.log.getLodLeave(err, p_load);
    }
}
pub fn getNthEnter(tskpri: PRI, nth: c_uint, p_tskid: *ID) void {
    if (@hasDecl(option.log, "getNthEnter")) {
        option.log.getNthEnter(tskpri, nth, p_tskid);
    }
}
pub fn getNthLeave(err: ?ItronError, p_tskid: *ID) void {
    if (@hasDecl(option.log, "getNthLeave")) {
        option.log.getNthLeave(err, p_tskid);
    }
}
pub fn locCpuEnter() void {
    if (@hasDecl(option.log, "locCpuEnter")) {
        option.log.locCpuEnter();
    }
}
pub fn locCpuLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "locCpuLeave")) {
        option.log.locCpuLeave(err);
    }
}
pub fn unlCpuEnter() void {
    if (@hasDecl(option.log, "unlCpuEnter")) {
        option.log.unlCpuEnter();
    }
}
pub fn unlCpuLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "unlCpuLeave")) {
        option.log.unlCpuLeave(err);
    }
}
pub fn disDspEnter() void {
    if (@hasDecl(option.log, "disDspEnter")) {
        option.log.disDspEnter();
    }
}
pub fn disDspLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "disDspLeave")) {
        option.log.disDspLeave(err);
    }
}
pub fn enaDspEnter() void {
    if (@hasDecl(option.log, "enaDspEnter")) {
        option.log.enaDspEnter();
    }
}
pub fn enaDspLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "enaDspLeave")) {
        option.log.enaDspLeave(err);
    }
}
pub fn snsCtxEnter() void {
    if (@hasDecl(option.log, "snsCtxEnter")) {
        option.log.snsCtxEnter();
    }
}
pub fn snsCtxLeave(state: bool) void {
    if (@hasDecl(option.log, "snsCtxLeave")) {
        option.log.snsCtxLeave(state);
    }
}
pub fn snsLocEnter() void {
    if (@hasDecl(option.log, "snsLocEnter")) {
        option.log.snsLocEnter();
    }
}
pub fn snsLocLeave(state: bool) void {
    if (@hasDecl(option.log, "snsLocLeave")) {
        option.log.snsLocLeave(state);
    }
}
pub fn snsDspEnter() void {
    if (@hasDecl(option.log, "snsDspEnter")) {
        option.log.snsDspEnter();
    }
}
pub fn snsDspLeave(state: bool) void {
    if (@hasDecl(option.log, "snsDspLeave")) {
        option.log.snsDspLeave(state);
    }
}
pub fn snsDpnEnter() void {
    if (@hasDecl(option.log, "snsDpnEnter")) {
        option.log.snsDpnEnter();
    }
}
pub fn snsDpnLeave(state: bool) void {
    if (@hasDecl(option.log, "snsDpnLeave")) {
        option.log.snsDpnLeave(state);
    }
}
pub fn snsKerEnter() void {
    if (@hasDecl(option.log, "snsKerEnter")) {
        option.log.snsKerEnter();
    }
}
pub fn snsKerLeave(state: bool) void {
    if (@hasDecl(option.log, "snsKerLeave")) {
        option.log.snsKerLeave(state);
    }
}
pub fn extKerEnter() void {
    if (@hasDecl(option.log, "extKerEnter")) {
        option.log.extKerEnter();
    }
}
pub fn extKerLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "extKerLeave")) {
        option.log.extKerLeave(err);
    }
}

// 割込み管理機能
pub fn disIntEnter(intno: INTNO) void {
    if (@hasDecl(option.log, "disIntEnter")) {
        option.log.disIntEnter(intno);
    }
}
pub fn disIntLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "disIntLeave")) {
        option.log.disIntLeave(err);
    }
}
pub fn enaIntEnter(intno: INTNO) void {
    if (@hasDecl(option.log, "enaIntEnter")) {
        option.log.enaIntEnter(intno);
    }
}
pub fn enaIntLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "enaIntLeave")) {
        option.log.enaIntLeave(err);
    }
}
pub fn clrIntEnter(intno: INTNO) void {
    if (@hasDecl(option.log, "clrIntEnter")) {
        option.log.clrIntEnter(intno);
    }
}
pub fn clrIntLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "clrIntLeave")) {
        option.log.clrIntLeave(err);
    }
}
pub fn rasIntEnter(intno: INTNO) void {
    if (@hasDecl(option.log, "rasIntEnter")) {
        option.log.rasIntEnter(intno);
    }
}
pub fn rasIntLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "rasIntLeave")) {
        option.log.rasIntLeave(err);
    }
}
pub fn prbIntEnter(intno: INTNO) void {
    if (@hasDecl(option.log, "prbIntEnter")) {
        option.log.prbIntEnter(intno);
    }
}
pub fn prbIntLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "prbIntLeave")) {
        option.log.prbIntLeave(err);
    }
}
pub fn chgIpmEnter(intpri: PRI) void {
    if (@hasDecl(option.log, "chgIpmEnter")) {
        option.log.chgIpmEnter(intpri);
    }
}
pub fn chgIpmLeave(err: ?ItronError) void {
    if (@hasDecl(option.log, "chgIpmLeave")) {
        option.log.chgIpmLeave(err);
    }
}
pub fn getIpmEnter(p_intpri: *PRI) void {
    if (@hasDecl(option.log, "getIpmEnter")) {
        option.log.getIpmEnter(p_intpri);
    }
}
pub fn getIpmLeave(err: ?ItronError, p_intpri: *PRI) void {
    if (@hasDecl(option.log, "getIpmLeave")) {
        option.log.getIpmLeave(err, p_intpri);
    }
}

// CPU例外管理機能
pub fn xSnsDpnEnter(p_excinf: *c_void) void {
    if (@hasDecl(option.log, "xSnsDpnEnter")) {
        option.log.xSnsDpnEnter(p_excinf);
    }
}
pub fn xSnsDpnLeave(state: bool) void {
    if (@hasDecl(option.log, "xSnsDpnLeave")) {
        option.log.xSnsDpnLeave(state);
    }
}
