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
usingnamespace @import("kernel_impl.zig");

///
///  C言語ヘッダファイルの取り込み
///
pub const c = @cImport({
    @cDefine("UINT_C(val)", "val");
    @cInclude("kernel.h");
});

///
///  用いるライブラリ
///
const errorcode = @import("../library/errorcode.zig");

///
///  サービスコールのC言語API
///

// 返値をER型に変換
fn callService(result: ItronError!void) ER {
    if (result) {
        return c.E_OK;
    }
    else |err| {
        return errorcode.itronErrorCode(err);
    }
}

// 返値をER_UINT型に変換
fn callServiceUint(result: ItronError!c_uint) ER_UINT {
    if (result) |retval| {
        return  @intCast(ER_UINT, @intCast(u31, retval));
    }
    else |err| {
        return errorcode.itronErrorCode(err);
    }
}

// 返値をER_BOOL型に変換
fn callServiceBool(result: ItronError!bool) ER_BOOL {
    if (result) |retval| {
        return  @intCast(ER_BOOL, @boolToInt(retval));
    }
    else |err| {
        return errorcode.itronErrorCode(err);
    }
}

///
///  カーネルのサービスコール
///

// act_tskのC言語API
export fn act_tsk(tskid: ID) ER {
    return callService(task_manage.act_tsk(tskid));
}

// can_actのC言語API
export fn can_act(tskid: ID) ER_UINT {
    return callServiceUint(task_manage.can_act(tskid));
}

// get_tstのC言語API
export fn get_tst(tskid: ID, p_tskstat: *STAT) ER {
    return callService(task_manage.get_tst(tskid, p_tskstat));
}

// chg_priのC言語API
export fn chg_pri(tskid: ID, tskpri: PRI) ER {
    return callService(task_manage.chg_pri(tskid, tskpri));
}

// get_priのC言語API
export fn get_pri(tskid: ID, p_tskpri: *PRI) ER {
    return callService(task_manage.get_pri(tskid, p_tskpri));
}

// get_infのC言語API
export fn get_inf(p_exinf: *EXINF) ER {
    return callService(task_manage.get_inf(p_exinf));
}

// ref_tskのC言語API
export fn ref_tsk(tskid: ID, pk_rtsk: *T_RTSK) ER {
    return callService(task_refer.ref_tsk(tskid, pk_rtsk));
}

// slp_tskのC言語API
export fn slp_tsk() ER {
    return callService(task_sync.slp_tsk());
}

// tslp_tskのC言語API
export fn tslp_tsk(tmout: TMO) ER {
    return callService(task_sync.tslp_tsk(tmout));
}

// wup_tskのC言語API
export fn wup_tsk(tskid: ID) ER {
    return callService(task_sync.wup_tsk(tskid));
}

// can_wupのC言語API
export fn can_wup(tskid: ID) ER_UINT {
    return callServiceUint(task_sync.can_wup(tskid));
}

// rel_waiのC言語API
export fn rel_wai(tskid: ID) ER {
    return callService(task_sync.rel_wai(tskid));
}

// sus_tskのC言語API
export fn sus_tsk(tskid: ID) ER {
    return callService(task_sync.sus_tsk(tskid));
}

// rsm_tskのC言語API
export fn rsm_tsk(tskid: ID) ER {
    return callService(task_sync.rsm_tsk(tskid));
}

// dly_tskのC言語API
export fn dly_tsk(dlytim: RELTIM) ER {
    return callService(task_sync.dly_tsk(dlytim));
}

// ext_tskのC言語API
pub export fn ext_tsk() ER {
    return callService(task_term.ext_tsk());
}

// ras_terのC言語API
export fn ras_ter(tskid: ID) ER {
    return callService(task_term.ras_ter(tskid));
}

// dis_terのC言語API
export fn dis_ter() ER {
    return callService(task_term.dis_ter());
}

// ena_terのC言語API
export fn ena_ter() ER {
    return callService(task_term.ena_ter());
}

// sns_terのC言語API
export fn sns_ter() c_int {
    return @boolToInt(task_term.sns_ter());
}

// ter_tskのC言語API
export fn ter_tsk(tskid: ID) ER {
    return callService(task_term.ter_tsk(tskid));
}

// sig_semのC言語API
export fn sig_sem(semid: ID) ER {
    return callService(semaphore.sig_sem(semid));
}

// wai_semのC言語API
export fn wai_sem(semid: ID) ER {
    return callService(semaphore.wai_sem(semid));
}

// pol_semのC言語API
export fn pol_sem(semid: ID) ER {
    return callService(semaphore.pol_sem(semid));
}

// twai_semのC言語API
export fn twai_sem(semid: ID, tmout: TMO) ER {
    return callService(semaphore.twai_sem(semid, tmout));
}

// ini_semのC言語API
export fn ini_sem(semid: ID) ER {
    return callService(semaphore.ini_sem(semid));
}

// ref_semのC言語API
export fn ref_sem(semid: ID, pk_rsem: *T_RSEM) ER {
    return callService(semaphore.ref_sem(semid, pk_rsem));
}

// set_flgのC言語API
export fn set_flg(flgid: ID, setptn: FLGPTN) ER {
    return callService(eventflag.set_flg(flgid, setptn));
}

// clr_flgのC言語API
export fn clr_flg(flgid: ID, clrptn: FLGPTN) ER {
    return callService(eventflag.clr_flg(flgid, clrptn));
}

// wai_flgのC言語API
export fn wai_flg(flgid: ID, waiptn: FLGPTN,
                  wfmode: MODE, p_flgptn: *FLGPTN) ER {
    return callService(eventflag.wai_flg(flgid, waiptn, wfmode, p_flgptn));
}

// pol_flgのC言語API
export fn pol_flg(flgid: ID, waiptn: FLGPTN,
                  wfmode: MODE, p_flgptn: *FLGPTN) ER {
    return callService(eventflag.pol_flg(flgid, waiptn, wfmode, p_flgptn));
}

// twai_flgのC言語API
export fn twai_flg(flgid: ID, waiptn: FLGPTN,
                   wfmode: MODE, p_flgptn: *FLGPTN, tmout: TMO) ER {
    return callService(eventflag.twai_flg(flgid, waiptn, wfmode,
                                          p_flgptn, tmout));
}

// ini_flgのC言語API
export fn ini_flg(flgid: ID) ER {
    return callService(eventflag.ini_flg(flgid));
}

// ref_flgのC言語API
export fn ref_flg(flgid: ID, pk_rflg: *T_RFLG) ER {
    return callService(eventflag.ref_flg(flgid, pk_rflg));
}

// snd_dtqのC言語API
export fn snd_dtq(dtqid: ID, data: usize) ER {
    return callService(dataqueue.snd_dtq(dtqid, data));
}

// psnd_dtqのC言語API
export fn psnd_dtq(dtqid: ID, data: usize) ER {
    return callService(dataqueue.psnd_dtq(dtqid, data));
}

// tsnd_dtqのC言語API
export fn tsnd_dtq(dtqid: ID, data: usize, tmout: TMO) ER {
    return callService(dataqueue.tsnd_dtq(dtqid, data, tmout));
}

// fsnd_dtqのC言語API
export fn fsnd_dtq(dtqid: ID, data: usize) ER {
    return callService(dataqueue.fsnd_dtq(dtqid, data));
}

// rcv_dtqのC言語API
export fn rcv_dtq(dtqid: ID, p_data: *usize) ER {
    return callService(dataqueue.rcv_dtq(dtqid, p_data));
}

// prcv_dtqのC言語API
export fn prcv_dtq(dtqid: ID, p_data: *usize) ER {
    return callService(dataqueue.prcv_dtq(dtqid, p_data));
}

// trcv_dtqのC言語API
export fn trcv_dtq(dtqid: ID, p_data: *usize, tmout: TMO) ER {
    return callService(dataqueue.trcv_dtq(dtqid, p_data, tmout));
}

// ini_dtqのC言語API
export fn ini_dtq(dtqid: ID) ER {
    return callService(dataqueue.ini_dtq(dtqid));
}

// ref_dtqのC言語API
export fn ref_dtq(dtqid: ID, pk_rdtq: *T_RDTQ) ER {
    return callService(dataqueue.ref_dtq(dtqid, pk_rdtq));
}

// snd_pdqのC言語API
export fn snd_pdq(pdqid: ID, data: usize, datapri: PRI) ER {
    return callService(pridataq.snd_pdq(pdqid, data, datapri));
}

// psnd_pdqのC言語API
export fn psnd_pdq(pdqid: ID, data: usize, datapri: PRI) ER {
    return callService(pridataq.psnd_pdq(pdqid, data, datapri));
}

// tsnd_pdqのC言語API
export fn tsnd_pdq(pdqid: ID, data: usize, datapri: PRI, tmout: TMO) ER {
    return callService(pridataq.tsnd_pdq(pdqid, data, datapri, tmout));
}

// rcv_pdqのC言語API
export fn rcv_pdq(pdqid: ID, p_data: *usize, p_datapri: *PRI) ER {
    return callService(pridataq.rcv_pdq(pdqid, p_data, p_datapri));
}

// prcv_pdqのC言語API
export fn prcv_pdq(pdqid: ID, p_data: *usize, p_datapri: *PRI) ER {
    return callService(pridataq.prcv_pdq(pdqid, p_data, p_datapri));
}

// trcv_pdqのC言語API
export fn trcv_pdq(pdqid: ID, p_data: *usize, p_datapri: *PRI, tmout: TMO) ER {
    return callService(pridataq.trcv_pdq(pdqid, p_data, p_datapri, tmout));
}

// ini_pdqのC言語API
export fn ini_pdq(pdqid: ID) ER {
    return callService(pridataq.ini_pdq(pdqid));
}

// ref_pdqのC言語API
export fn ref_pdq(pdqid: ID, pk_rpdq: *T_RPDQ) ER {
    return callService(pridataq.ref_pdq(pdqid, pk_rpdq));
}

// loc_mtxのC言語API
export fn loc_mtx(mtxid: ID) ER {
    return callService(mutex.loc_mtx(mtxid));
}

// ploc_mtxのC言語API
export fn ploc_mtx(mtxid: ID) ER {
    return callService(mutex.ploc_mtx(mtxid));
}

// tloc_mtxのC言語API
export fn tloc_mtx(mtxid: ID, tmout: TMO) ER {
    return callService(mutex.tloc_mtx(mtxid, tmout));
}

// unl_mtxのC言語API
export fn unl_mtx(mtxid: ID) ER {
    return callService(mutex.unl_mtx(mtxid));
}

// ini_mtxのC言語API
export fn ini_mtx(mtxid: ID) ER {
    return callService(mutex.ini_mtx(mtxid));
}

// ref_mtxのC言語API
export fn ref_mtx(mtxid: ID, pk_rmtx: *T_RMTX) ER {
    return callService(mutex.ref_mtx(mtxid, pk_rmtx));
}

// get_mpfのC言語API
export fn get_mpf(mpfid: ID, p_blk: **c_void) ER {
    return callService(mempfix.get_mpf(mpfid, @ptrCast(**u8, p_blk)));
}

// pget_mpfのC言語API
export fn pget_mpf(mpfid: ID, p_blk: **c_void) ER {
    return callService(mempfix.pget_mpf(mpfid, @ptrCast(**u8, p_blk)));
}

// tget_mpfのC言語API
export fn tget_mpf(mpfid: ID, p_blk: **c_void, tmout: TMO) ER {
    return callService(mempfix.tget_mpf(mpfid, @ptrCast(**u8, p_blk), tmout));
}

// rel_mpfのC言語API
export fn rel_mpf(mpfid: ID, blk: *u8) ER {
    return callService(mempfix.rel_mpf(mpfid, blk));
}

// ini_mpfのC言語API
export fn ini_mpf(mpfid: ID) ER {
    return callService(mempfix.ini_mpf(mpfid));
}

// ref_mpfのC言語API
export fn ref_mpf(mpfid: ID, pk_rmpf: *T_RMPF) ER {
    return callService(mempfix.ref_mpf(mpfid, pk_rmpf));
}

// set_timのC言語API
export fn set_tim(systim: SYSTIM) ER {
    return callService(time_manage.set_tim(systim));
}

// get_timのC言語API
export fn get_tim(p_systim: *SYSTIM) ER {
    return callService(time_manage.get_tim(p_systim));
}

// adj_timのC言語API
export fn adj_tim(adjtim: i32) ER {
    return callService(time_manage.adj_tim(adjtim));
}

// fch_hrtのC言語API
export fn fch_hrt() HRTCNT {
    return time_manage.fch_hrt();
}

// sta_cycのC言語API
export fn sta_cyc(cycid: ID) ER {
    return callService(cyclic.sta_cyc(cycid));
}

// stp_cycのC言語API
export fn stp_cyc(cycid: ID) ER {
    return callService(cyclic.stp_cyc(cycid));
}

// ref_cycのC言語API
export fn ref_cyc(cycid: ID, pk_rcyc: *T_RCYC) ER {
    return callService(cyclic.ref_cyc(cycid, pk_rcyc));
}

// sta_almのC言語API
export fn sta_alm(almid: ID, almtim: RELTIM) ER {
    return callService(alarm.sta_alm(almid, almtim));
}

// stp_almのC言語API
export fn stp_alm(almid: ID) ER {
    return callService(alarm.stp_alm(almid));
}

// ref_almのC言語API
export fn ref_alm(almid: ID, pk_ralm: *T_RALM) ER {
    return callService(alarm.ref_alm(almid, pk_ralm));
}

// sta_ovrのC言語API
export fn sta_ovr(tskid: ID, ovrtim: RELTIM) ER {
    return callService(overrun.sta_ovr(tskid, ovrtim));
}

// stp_ovrのC言語API
export fn stp_ovr(tskid: ID) ER {
    return callService(overrun.stp_ovr(tskid));
}

// ref_ovrのC言語API
export fn ref_ovr(tskid: ID, pk_rovr: *T_ROVR) ER {
    return callService(overrun.ref_ovr(tskid, pk_rovr));
}

// rot_rdqのC言語API
export fn rot_rdq(tskpri: PRI) ER {
    return callService(sys_manage.rot_rdq(tskpri));
}

// get_tidのC言語API
export fn get_tid(p_tskid: *ID) ER {
    return callService(sys_manage.get_tid(p_tskid));
}

// get_lodのC言語API
export fn get_lod(tskpri: PRI, p_load: *c_uint) ER {
    return callService(sys_manage.get_lod(tskpri, p_load));
}

// get_nthのC言語API
export fn get_nth(tskpri: PRI, nth: c_uint, p_tskid: *ID) ER {
    return callService(sys_manage.get_nth(tskpri, nth, p_tskid));
}

// loc_cpuのC言語API
export fn loc_cpu() ER {
    return callService(sys_manage.loc_cpu());
}

// unl_cpuのC言語API
export fn unl_cpu() ER {
    return callService(sys_manage.unl_cpu());
}

// dis_dspのC言語API
export fn dis_dsp() ER {
    return callService(sys_manage.dis_dsp());
}

// ena_dspのC言語API
export fn ena_dsp() ER {
    return callService(sys_manage.ena_dsp());
}

// sns_ctxのC言語API
export fn sns_ctx() c_int {
    return @boolToInt(sys_manage.sns_ctx());
}

// sns_locのC言語API
export fn sns_loc() c_int {
    return @boolToInt(sys_manage.sns_loc());
}

// sns_dspのC言語API
export fn sns_dsp() c_int {
    return @boolToInt(sys_manage.sns_dsp());
}

// sns_dpnのC言語API
export fn sns_dpn() c_int {
    return @boolToInt(sys_manage.sns_dpn());
}

// sns_kerのC言語API
export fn sns_ker() c_int {
    return @boolToInt(sys_manage.sns_ker());
}

// ext_kerのC言語API
export fn ext_ker() noreturn {
    startup.ext_ker();
    // ASP3カーネルでは，ext_kerからリターンすることはない．
}

// dis_intのC言語API
export fn dis_int(intno: INTNO) ER {
    return callService(interrupt.dis_int(intno));
}

// ena_intのC言語API
export fn ena_int(intno: INTNO) ER {
    return callService(interrupt.ena_int(intno));
}

// clr_intのC言語API
export fn clr_int(intno: INTNO) ER {
    return callService(interrupt.clr_int(intno));
}

// ras_intのC言語API
export fn ras_int(intno: INTNO) ER {
    return callService(interrupt.ras_int(intno));
}

// prb_intのC言語API
export fn prb_int(intno: INTNO) ER_BOOL {
    return callServiceBool(interrupt.prb_int(intno));
}

// chg_ipmのC言語API
export fn chg_ipm(intpri: PRI) ER {
    return callService(interrupt.chg_ipm(intpri));
}

// get_ipmのC言語API
export fn get_ipm(p_intpri: *PRI) ER {
    return callService(interrupt.get_ipm(p_intpri));
}

// xsns_dpnのC言語API
export fn xsns_dpn(p_excinf: *c_void) c_int {
    return @boolToInt(exception.xsns_dpn(p_excinf));
}

///
///  SILのサービスコール
///
export fn sil_dly_nse(dlytim: usize) void {
    sil.dly_nse(dlytim);
}

///
///  各モジュールの初期化関数
///
export fn _kernel_initialize_task() void {
    task.initialize_task();
}
export fn _kernel_initialize_semaphore() void {
    semaphore.initialize_semaphore();
}
export fn _kernel_initialize_eventflag() void {
    eventflag.initialize_eventflag();
}
export fn _kernel_initialize_dataqueue() void {
    dataqueue.initialize_dataqueue();
}
export fn _kernel_initialize_pridataq() void {
    pridataq.initialize_pridataq();
}
export fn _kernel_initialize_mutex() void {
    mutex.initialize_mutex();
}
export fn _kernel_initialize_mempfix() void {
    mempfix.initialize_mempfix();
}
export fn _kernel_initialize_cyclic() void {
    cyclic.initialize_cyclic();
}
export fn _kernel_initialize_alarm() void {
    alarm.initialize_alarm();
}
export fn _kernel_initialize_interrupt() void {
    interrupt.initialize_interrupt();
}
export fn _kernel_initialize_exception() void {
    exception.initialize_exception();
}

///
///  ターゲット依存部からexportする関数
///
usingnamespace target_impl.ExportDefs;

///
///  タイマモジュールからexportする関数
///
usingnamespace target_timer.ExportDefs;

///
///  トレースログの設定からexportする関数
///
usingnamespace option.log.TraceExportDefs;

///
///  トレースログのためのカーネル情報の取出し関数
///
export fn _kernel_get_tskid(info: usize) usize {
    return task.getTskId(info);
}

export fn _kernel_get_tskstat(info: usize) usize {
    return task.getTskStat(info);
}

///
///  カーネルの整合性検査
///
fn bitKernel() ItronError!void {
    try task.bitTask();
    try mutex.bitMutex();
}

export fn _kernel_bit_kernel() ER {
    return callService(bitKernel());
}

//
//  オブジェクト初期化ブロック／管理ブロックがない場合の対策
//
comptime {
    if (option.BIND_CFG == null) {
    asm(
     \\ .weak _kernel_seminib_table
     \\ _kernel_seminib_table:
     \\ .weak _kernel_semcb_table
     \\ _kernel_semcb_table:

     \\ .weak _kernel_flginib_table
     \\ _kernel_flginib_table:
     \\ .weak _kernel_flgcb_table
     \\ _kernel_flgcb_table:

     \\ .weak _kernel_dtqinib_table
     \\ _kernel_dtqinib_table:
     \\ .weak _kernel_dtqcb_table
     \\ _kernel_dtqcb_table:

     \\ .weak _kernel_pdqinib_table
     \\ _kernel_pdqinib_table:
     \\ .weak _kernel_pdqcb_table
     \\ _kernel_pdqcb_table:

     \\ .weak _kernel_mtxinib_table
     \\ _kernel_mtxinib_table:
     \\ .weak _kernel_mtxcb_table
     \\ _kernel_mtxcb_table:

     \\ .weak _kernel_mpfinib_table
     \\ _kernel_mpfinib_table:
     \\ .weak _kernel_mpfcb_table
     \\ _kernel_mpfcb_table:

     \\ .weak _kernel_cycinib_table
     \\ _kernel_cycinib_table:
     \\ .weak _kernel_cyccb_table
     \\ _kernel_cyccb_table:

     \\ .weak _kernel_alminib_table
     \\ _kernel_alminib_table:
     \\ .weak _kernel_almcb_table
     \\ _kernel_almcb_table:

     \\ .weak _kernel_inirtnb_table
     \\ _kernel_inirtnb_table:

     \\ .weak _kernel_terrtnb_table
     \\ _kernel_terrtnb_table:
    );
    }
}
