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
///  イベントフラグ機能
///
usingnamespace @import("kernel_impl.zig");
usingnamespace task;
usingnamespace wait;
usingnamespace time_event;
usingnamespace check;

///
///  イベントフラグ初期化ブロック
///
///  この構造体は，同期・通信オブジェクトの初期化ブロックの共通部分
///  （WOBJINIB）を拡張（オブジェクト指向言語の継承に相当）したもので，
///  最初のフィールドが共通になっている．
///
pub const FLGINIB = struct {
    wobjatr: ATR,               // イベントフラグ属性
    iflgptn: FLGPTN,            // イベントフラグのビットパターンの初期値
};

// イベントフラグ初期化ブロックのチェック
comptime {
    checkWobjIniB(FLGINIB);
}

///
///  イベントフラグ管理ブロック
///
///  この構造体は，同期・通信オブジェクトの管理ブロックの共通部分
///  （WOBJCB）を拡張（オブジェクト指向言語の継承に相当）したもので，
///  最初の2つのフィールドが共通になっている．
///
const FLGCB = struct {
    wait_queue: queue.Queue,    // イベントフラグ待ちキュー
    p_wobjinib: *const FLGINIB, // 初期化ブロックへのポインタ
    flgptn: FLGPTN,             // イベントフラグ現在パターン
};

// イベントフラグ管理ブロックのチェック
comptime {
    checkWobjCB(FLGCB);
}

///
///  イベントフラグ待ち情報ブロックの定義
///
///  この構造体は，同期・通信オブジェクトの待ち情報ブロックの共通部分
///  （WINFO_WOBJ）を拡張（オブジェクト指向言語の継承に相当）したもの
///  で，最初の2つのフィールドが共通になっている．
///
///  waiptnには，待ち状態の間は待ちパターンを，待ち解除された後は待ち
///  解除時のパターンを入れる（1つのフィールドを2つの目的に兼用してい
///  る）．
///
const WINFO_FLG = struct {
    winfo: WINFO,               // 標準の待ち情報ブロック
    p_wobjcb: *FLGCB,           // 待っているイベントフラグの管理ブロック
    waiptn: FLGPTN,             // 待ちパターン／待ち解除時のパターン
    wfmode: MODE,               // 待ちモード
};

// イベントフラグ待ち情報ブロックのチェック
comptime {
    checkWinfoWobj(WINFO_FLG);
}

///
///  イベントフラグに関するコンフィギュレーションデータの取り込み
///
pub const ExternFlgCfg = struct {
    ///
    ///  イベントフラグIDの最大値
    ///
    pub extern const _kernel_tmax_flgid: ID;

    ///
    ///  イベントフラグ初期化ブロックのエリア
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern const _kernel_flginib_table: [100]FLGINIB;

    ///
    ///  イベントフラグ管理ブロックのエリア
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern var _kernel_flgcb_table: [100]FLGCB;
};

///
///  イベントフラグの数
///
fn numOfFlg() usize {
    return @intCast(usize, cfg._kernel_tmax_flgid - TMIN_FLGID + 1);
}

///
///  イベントフラグIDからイベントフラグ管理ブロックを取り出すための関数
///
fn indexFlg(flgid: ID) usize {
    return @intCast(usize, flgid - TMIN_FLGID);
}
fn checkAndGetFlgCB(flgid: ID) ItronError!*FLGCB {
    try checkId(TMIN_FLGID <= flgid and flgid <= cfg._kernel_tmax_flgid);
    return &cfg._kernel_flgcb_table[indexFlg(flgid)];
}

///
///  イベントフラグ管理ブロックからイベントフラグIDを取り出すための関数
///
fn getFlgIdFromFlgCB(p_flgcb: *FLGCB) ID {
    return @intCast(ID, (@ptrToInt(p_flgcb)
                             - @ptrToInt(&cfg._kernel_flgcb_table))
                        / @sizeOf(FLGCB)) + TMIN_FLGID;
}

///
///  イベントフラグ待ち情報ブロックを取り出すための関数
///
pub fn getWinfoFlg(p_winfo: *WINFO) *WINFO_FLG {
    return @fieldParentPtr(WINFO_FLG, "winfo", p_winfo);
}

///
///  待ち情報ブロックからイベントフラグIDを取り出すための関数
///
pub fn getFlgIdFromWinfo(p_winfo: *WINFO) ID {
    return getFlgIdFromFlgCB(getWinfoFlg(p_winfo).p_wobjcb);
}

///
///  イベントフラグ機能の初期化
///
pub fn initialize_eventflag() void {
    for (cfg._kernel_flgcb_table[0 .. numOfFlg()]) |*p_flgcb, i| {
        p_flgcb.wait_queue.initialize();
        p_flgcb.p_wobjinib = &cfg._kernel_flginib_table[i];
        p_flgcb.flgptn = p_flgcb.p_wobjinib.iflgptn;
    }
}

///
///  イベントフラグ待ち解除条件のチェック
///
fn check_flg_cond(p_flgcb: *FLGCB, waiptn: FLGPTN,
                  wfmode: MODE, p_flgptn: *FLGPTN) bool {
    if (if ((wfmode & TWF_ORW) != 0) (p_flgcb.flgptn & waiptn) != 0
                                else (p_flgcb.flgptn & waiptn) == waiptn) {
        p_flgptn.* = p_flgcb.flgptn;
        if ((p_flgcb.p_wobjinib.wobjatr & TA_CLR) != 0) {
            p_flgcb.flgptn = 0;
        }
        return true;
    }
    return false;
}

///
///  イベントフラグのセット
///
pub fn set_flg(flgid: ID, setptn: FLGPTN) ItronError!void {
    traceLog("setFlgEnter", .{ flgid, setptn });
    errdefer |err| traceLog("setFlgLeave", .{ err });
    try checkContextUnlock();
    const p_flgcb = try checkAndGetFlgCB(flgid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        p_flgcb.flgptn |= setptn;
        var p_queue = p_flgcb.wait_queue.p_next;
        while (p_queue != &p_flgcb.wait_queue) {
            const p_tcb = getTCBFromQueue(p_queue);
            const p_winfo_flg = getWinfoFlg(p_tcb.p_winfo);
            p_queue = p_queue.p_next;
            if (check_flg_cond(p_flgcb, p_winfo_flg.waiptn,
                               p_winfo_flg.wfmode, &p_winfo_flg.waiptn)) {
                p_tcb.task_queue.delete();
                wait_complete(p_tcb);
                if ((p_flgcb.p_wobjinib.wobjatr & TA_CLR) != 0) {
                    break;
                }
            }
        }
        requestTaskDispatch();
    }
    traceLog("setFlgLeave", .{ null });
}

///
///  イベントフラグのクリア
///
pub fn clr_flg(flgid: ID, clrptn: FLGPTN) ItronError!void {
    traceLog("clrFlgEnter", .{ flgid, clrptn });
    errdefer |err| traceLog("clrFlgLeave", .{ err });
    try checkContextTaskUnlock();
    const p_flgcb = try checkAndGetFlgCB(flgid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        p_flgcb.flgptn &= clrptn;
    }
    traceLog("clrFlgLeave", .{ null });
}

///
///  イベントフラグ待ち
///
pub fn wai_flg(flgid: ID, waiptn: FLGPTN,
               wfmode: MODE, p_flgptn: *FLGPTN) ItronError!void {
    traceLog("waiFlgEnter", .{ flgid, waiptn, wfmode, p_flgptn });
    errdefer |err| traceLog("waiFlgLeave", .{ err, p_flgptn });
    try checkDispatch();
    const p_flgcb = try checkAndGetFlgCB(flgid);
    try checkParameter(waiptn != 0);
    try checkParameter(wfmode == TWF_ORW or wfmode == TWF_ANDW);
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if ((p_flgcb.p_wobjinib.wobjatr & TA_WMUL) == 0
                     and !p_flgcb.wait_queue.isEmpty()) {
            return ItronError.IllegalUse;
        }
        else if (!check_flg_cond(p_flgcb, waiptn, wfmode, p_flgptn)) {
            var winfo_flg: WINFO_FLG = undefined;
            winfo_flg.waiptn = waiptn;
            winfo_flg.wfmode = wfmode;
            wobj_make_wait(p_flgcb, TS_WAITING_FLG, &winfo_flg);
            target_impl.dispatch();
            if (winfo_flg.winfo.werror) |werror| {
                return werror;
            }
            p_flgptn.* = winfo_flg.waiptn;
        }
    }
    traceLog("waiFlgLeave", .{ null, p_flgptn });
}

///
///  イベントフラグ待ち（ポーリング）
///
pub fn pol_flg(flgid: ID, waiptn: FLGPTN,
               wfmode: MODE, p_flgptn: *FLGPTN) ItronError!void {
    traceLog("polFlgEnter", .{ flgid, waiptn, wfmode, p_flgptn });
    errdefer |err| traceLog("polFlgLeave", .{ err, p_flgptn });
    try checkContextTaskUnlock();
    const p_flgcb = try checkAndGetFlgCB(flgid);
    try checkParameter(waiptn != 0);
    try checkParameter(wfmode == TWF_ORW or wfmode == TWF_ANDW);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if ((p_flgcb.p_wobjinib.wobjatr & TA_WMUL) == 0
                and !p_flgcb.wait_queue.isEmpty()) {
            return ItronError.IllegalUse;
        }
        else if (!check_flg_cond(p_flgcb, waiptn, wfmode, p_flgptn)) {
            return ItronError.TimeoutError;
        }
    }
    traceLog("polFlgLeave", .{ null, p_flgptn });
}

///
///  イベントフラグ待ち（タイムアウトあり）
///
pub fn twai_flg(flgid: ID, waiptn: FLGPTN, wfmode: MODE,
                p_flgptn: *FLGPTN, tmout: TMO) ItronError!void {
    traceLog("tWaiFlgEnter", .{ flgid, waiptn, wfmode, p_flgptn, tmout });
    errdefer |err| traceLog("tWaiFlgLeave", .{ err, p_flgptn });
    try checkDispatch();
    const p_flgcb = try checkAndGetFlgCB(flgid);
    try checkParameter(waiptn != 0);
    try checkParameter(wfmode == TWF_ORW or wfmode == TWF_ANDW);
    try checkParameter(validTimeout(tmout));
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if ((p_flgcb.p_wobjinib.wobjatr & TA_WMUL) == 0
                     and !p_flgcb.wait_queue.isEmpty()) {
            return ItronError.IllegalUse;
        }
        else if (check_flg_cond(p_flgcb, waiptn, wfmode, p_flgptn)) {
        }
        else if (tmout == TMO_POL) {
            return ItronError.TimeoutError;
        }
        else {
            var winfo_flg: WINFO_FLG = undefined;
            var tmevtb: TMEVTB = undefined;
            winfo_flg.waiptn = waiptn;
            winfo_flg.wfmode = wfmode;
            wobj_make_wait_tmout(p_flgcb, TS_WAITING_FLG, &winfo_flg,
                                 &tmevtb, tmout);
            target_impl.dispatch();
            if (winfo_flg.winfo.werror) |werror| {
                return werror;
            }
            p_flgptn.* = winfo_flg.waiptn;
        }
    }
    traceLog("tWaiFlgLeave", .{ null, p_flgptn });
}

///
///  イベントフラグの再初期化
///
pub fn ini_flg(flgid: ID) ItronError!void {
    traceLog("iniFlgEnter", .{ flgid });
    errdefer |err| traceLog("iniFlgLeave", .{ err });
    try checkContextTaskUnlock();
    const p_flgcb = try checkAndGetFlgCB(flgid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        init_wait_queue(&p_flgcb.wait_queue);
        p_flgcb.flgptn = p_flgcb.p_wobjinib.iflgptn;
        taskDispatch();
    }
    traceLog("iniFlgLeave", .{ null });
}

///
/// イベントフラグの状態参照
///
pub fn ref_flg(flgid: ID, pk_rflg: *T_RFLG) ItronError!void {
    traceLog("refFlgEnter", .{ flgid, pk_rflg });
    errdefer |err| traceLog("refFlgLeave", .{ err, pk_rflg });
    try checkContextTaskUnlock();
    const p_flgcb = try checkAndGetFlgCB(flgid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        pk_rflg.wtskid = wait_tskid(&p_flgcb.wait_queue);
        pk_rflg.flgptn = p_flgcb.flgptn;
    }
    traceLog("refFlgLeave", .{ null, pk_rflg });
}

///
///  イベントフラグの生成（静的APIの処理）
///
pub fn cre_flg(cflg: T_CFLG) ItronError!FLGINIB {
    // flgatrが無効の場合（E_RSATR）［NGKI1562］［NGKI1550］
    //（TA_TPRI，TA_WMUL，TA_CLR以外のビットがセットされている場合）
    try checkValidAtr(cflg.flgatr, TA_TPRI|TA_WMUL|TA_CLR);

    // iflgptnがFLGPTNに格納できない場合（E_PAR）［NGKI3275］
    try checkParameter((cflg.iflgptn
                            & ~@as(FLGPTN, (1 << TBIT_FLGPTN) - 1)) == 0);

    // イベントフラグ初期化ブロックを返す
    return FLGINIB{ .wobjatr = cflg.flgatr, .iflgptn = cflg.iflgptn, };
}

///
///  イベントフラグに関するコンフィギュレーションデータの生成（静的API
///  の処理）
///
pub fn ExportFlgCfg(flginib_table: []FLGINIB) type {
    const tnum_flg = flginib_table.len;
    return struct {
        pub export const _kernel_tmax_flgid: ID = tnum_flg;

        // Zigの制限の回避：BIND_CFG != nullの場合に，サイズ0の配列が
        // 出ないようにする
        pub export const _kernel_flginib_table =
            if (option.BIND_CFG == null or tnum_flg > 0)
                flginib_table[0 .. tnum_flg].*
            else [1]FLGINIB{ .{ .wobjatr = 0, .iflgptn = 0, }};
        pub export var _kernel_flgcb_table:
            [if (option.BIND_CFG == null or tnum_flg > 0) tnum_flg
                 else 1]FLGCB = undefined;
    };
}
