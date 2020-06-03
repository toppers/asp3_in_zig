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
///  セマフォ機能
///
usingnamespace @import("kernel_impl.zig");
usingnamespace task;
usingnamespace wait;
usingnamespace time_event;
usingnamespace check;

///
///  セマフォ初期化ブロック
///
///  この構造体は，同期・通信オブジェクトの初期化ブロックの共通部分
///  （WOBJINIB）を拡張（オブジェクト指向言語の継承に相当）したもので，
///  最初のフィールドが共通になっている．
///
pub const SEMINIB = struct {
    wobjatr: ATR,               // セマフォ属性
    isemcnt: u32,               // セマフォの資源数の初期値
    maxsem: u32,                // セマフォの最大資源数
};

// セマフォ初期化ブロックのチェック
comptime {
    checkWobjIniB(SEMINIB);
}

///
///  セマフォ管理ブロック
///
///  この構造体は，同期・通信オブジェクトの管理ブロックの共通部分
///  （WOBJCB）を拡張（オブジェクト指向言語の継承に相当）したもので，
///  最初の2つのフィールドが共通になっている．
///
const SEMCB = struct {
    wait_queue: queue.Queue,    // セマフォ待ちキュー
    p_wobjinib: *const SEMINIB, // 初期化ブロックへのポインタ
    semcnt: u32,                // セマフォ現在カウント値
};

// セマフォ管理ブロックのチェック
comptime {
    checkWobjCB(SEMCB);
}

///
///  セマフォ待ち情報ブロックの定義
///
///  この構造体は，同期・通信オブジェクトの待ち情報ブロックの共通部分
///  （WINFO_WOBJ）を拡張（オブジェクト指向言語の継承に相当）したもの
///  で，すべてのフィールドが共通になっている．
///
const WINFO_SEM = struct {
    winfo: WINFO,               // 標準の待ち情報ブロック
    p_wobjcb: *SEMCB,           // 待っているセマフォの管理ブロック
};

// セマフォ待ち情報ブロックのチェック
comptime {
    checkWinfoWobj(WINFO_SEM);
}

///
///  セマフォに関するコンフィギュレーションデータの取り込み
///
pub const ExternSemCfg = struct {
    ///
    ///  セマフォIDの最大値
    ///
    pub extern const _kernel_tmax_semid: ID;

    ///
    ///  セマフォ初期化ブロックのエリア
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern const _kernel_seminib_table: [100]SEMINIB;

    ///
    ///  セマフォ管理ブロックのエリア
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern var _kernel_semcb_table: [100]SEMCB;
};

///
///  セマフォの数
///
fn numOfSem() usize {
    return @intCast(usize, cfg._kernel_tmax_semid - TMIN_SEMID + 1);
}

///
///  セマフォIDからセマフォ管理ブロックを取り出すための関数
///
fn indexSem(semid: ID) usize {
    return @intCast(usize, semid - TMIN_SEMID);
}
fn checkAndGetSemCB(semid: ID) ItronError!*SEMCB {
    try checkId(TMIN_SEMID <= semid and semid <= cfg._kernel_tmax_semid);
    return &cfg._kernel_semcb_table[indexSem(semid)];
}

///
///  セマフォ管理ブロックからセマフォIDを取り出すための関数
///
fn getSemIdFromSemCB(p_semcb: *SEMCB) ID {
    return @intCast(ID, (@ptrToInt(p_semcb)
                             - @ptrToInt(&cfg._kernel_semcb_table))
                        / @sizeOf(SEMCB)) + TMIN_SEMID;
}

///
///  セマフォ待ち情報ブロックを取り出すための関数
///
pub fn getWinfoSem(p_winfo: *WINFO) *WINFO_SEM {
    return @fieldParentPtr(WINFO_SEM, "winfo", p_winfo);
}

///
///  待ち情報ブロックからセマフォIDを取り出すための関数
///
pub fn getSemIdFromWinfo(p_winfo: *WINFO) ID {
    return getSemIdFromSemCB(getWinfoSem(p_winfo).p_wobjcb);
}

///
///  セマフォ機能の初期化
///
pub fn initialize_semaphore() void {
    for (cfg._kernel_semcb_table[0 .. numOfSem()]) |*p_semcb, i| {
        p_semcb.wait_queue.initialize();
        p_semcb.p_wobjinib = &cfg._kernel_seminib_table[i];
        p_semcb.semcnt = p_semcb.p_wobjinib.isemcnt;
    }
}

///
///  セマフォ資源の返却
///
pub fn sig_sem(semid: ID) ItronError!void {
    log.sigSemEnter(semid);
    errdefer |err| log.sigSemLeave(err);
    try checkContextUnlock();
    const p_semcb = try checkAndGetSemCB(semid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (!p_semcb.wait_queue.isEmpty()) {
            const p_tcb = getTCBFromQueue(p_semcb.wait_queue.deleteNext());
            wait_complete(p_tcb);
            requestTaskDispatch();
        }
        else if (p_semcb.semcnt < p_semcb.p_wobjinib.maxsem) {
            p_semcb.semcnt += 1;
        }
        else {
            return ItronError.QueueingOverflow;
        }
    }
    log.sigSemLeave(null);
}

///
///  セマフォ資源の獲得
///
pub fn wai_sem(semid: ID) ItronError!void {
    log.waiSemEnter(semid);
    errdefer |err| log.waiSemLeave(err);
    try checkDispatch();
    const p_semcb = try checkAndGetSemCB(semid);
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (p_semcb.semcnt >= 1) {
            p_semcb.semcnt -= 1;
        }
        else {
            var winfo_sem: WINFO_SEM = undefined;
            wobj_make_wait(p_semcb, TS_WAITING_SEM, &winfo_sem);
            target_impl.dispatch();
            if (winfo_sem.winfo.werror) |werror| {
                return werror;
            }
        }
    }
    log.waiSemLeave(null);
}

///
///  セマフォ資源の獲得（ポーリング）
///
pub fn pol_sem(semid: ID) ItronError!void {
    log.polSemEnter(semid);
    errdefer |err| log.polSemLeave(err);
    try checkContextTaskUnlock();
    const p_semcb = try checkAndGetSemCB(semid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (p_semcb.semcnt >= 1) {
            p_semcb.semcnt -= 1;
        }
        else {
            return ItronError.TimeoutError;
        }
    }
    log.polSemLeave(null);
}

///
///  セマフォ資源の獲得（タイムアウトあり）
///
pub fn twai_sem(semid: ID, tmout: TMO) ItronError!void {
    log.tWaiSemEnter(semid, tmout);
    errdefer |err| log.tWaiSemLeave(err);
    try checkDispatch();
    const p_semcb = try checkAndGetSemCB(semid);
    try checkParameter(validTimeout(tmout));
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (p_semcb.semcnt >= 1) {
            p_semcb.semcnt -= 1;
        }
        else if (tmout == TMO_POL) {
            return ItronError.TimeoutError;
        }
        else {
            var winfo_sem: WINFO_SEM = undefined;
            var tmevtb: TMEVTB = undefined;
            wobj_make_wait_tmout(p_semcb, TS_WAITING_SEM, &winfo_sem,
                                 &tmevtb, tmout);
            target_impl.dispatch();
            if (winfo_sem.winfo.werror) |werror| {
                return werror;
            }
        }
    }
    log.tWaiSemLeave(null);
}

///
///  セマフォの再初期化
///
pub fn ini_sem(semid: ID) ItronError!void {
    log.iniSemEnter(semid);
    errdefer |err| log.iniSemLeave(err);
    try checkContextTaskUnlock();
    const p_semcb = try checkAndGetSemCB(semid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        init_wait_queue(&p_semcb.wait_queue);
        p_semcb.semcnt = p_semcb.p_wobjinib.isemcnt;
        taskDispatch();
    }
    log.iniSemLeave(null);
}

///
///  セマフォの状態参照
///
pub fn ref_sem(semid: ID, pk_rsem: *T_RSEM) ItronError!void {
    log.refSemEnter(semid, pk_rsem);
    errdefer |err| log.refSemLeave(err, pk_rsem);
    try checkContextTaskUnlock();
    const p_semcb = try checkAndGetSemCB(semid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        pk_rsem.wtskid = wait_tskid(&p_semcb.wait_queue);
        pk_rsem.semcnt = p_semcb.semcnt;
    }
    log.refSemLeave(null, pk_rsem);
}

///
///  セマフォの生成（静的APIの処理）
///
pub fn cre_sem(csem: T_CSEM) ItronError!SEMINIB {
    // sematrが無効の場合（E_RSATR）［NGKI1456］［NGKI1448］
    //（TA_TPRI以外のビットがセットされている場合）
    try checkValidAtr(csem.sematr, TA_TPRI);

    // maxsemが有効範囲外の場合（E_PAR）［NGKI1468］
    //（1 <= maxsem && maxsem <= TMAX_MAXSEMでない場合）
    try checkParameter(1 <= csem.maxsem and csem.maxsem <= TMAX_MAXSEM);

    // isemcntが有効範囲外の場合（E_PAR）［NGKI1466］
    //（0 <= isemcnt && isemcnt <= maxsemでない場合）
    try checkParameter(0 <= csem.isemcnt and csem.isemcnt <= csem.maxsem);

    // セマフォ初期化ブロックを返す
    return SEMINIB{ .wobjatr = csem.sematr,
                    .isemcnt = csem.isemcnt,
                    .maxsem = csem.maxsem, };
}

///
///  セマフォに関するコンフィギュレーションデータの生成（静的APIの処理）
///
pub fn ExportSemCfg(seminib_table: []SEMINIB) type {
    const tnum_sem = seminib_table.len;
    return struct {
        pub export const _kernel_tmax_semid: ID = tnum_sem;
        pub export const _kernel_seminib_table = seminib_table[0 .. tnum_sem].*;
        pub export var _kernel_semcb_table: [tnum_sem]SEMCB = undefined;
    };
}
