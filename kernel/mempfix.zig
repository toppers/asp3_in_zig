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
///  固定長メモリプール機能
///
usingnamespace @import("kernel_impl.zig");
usingnamespace task;
usingnamespace wait;
usingnamespace time_event;
usingnamespace check;

///
///  固定長メモリプール領域のアライン単位
///
const MPF_ALIGN =
    if (@hasDecl(target_impl, "MPF_ALIGN"))
        target_impl.MPF_ALIGN
    else if (@hasDecl(target_impl, "CHECK_MPF_ALIGN"))
        target_impl.CHECK_MPF_ALIGN
    else 1;

///
///  固定長メモリブロック管理ブロック
///
///  nextフィールドには，メモリブロックが割当て済みの場合はINDEX_ALLOC
///  を，未割当ての場合は次の未割当てブロックのインデックス番号を格納
///  する．最後の未割当てブロックの場合には，INDEX_NULLを格納する．
///
const MPFMB = struct {
    next: c_uint,                       // 次の未割当てブロック
};
const INDEX_NULL = ~@as(c_uint, 0);     // 空きブロックリストの最後
const INDEX_ALLOC = ~@as(c_uint, 1);    // 割当て済みのブロック

///
///  固定長メモリプール初期化ブロック
///
///  この構造体は，同期・通信オブジェクトの初期化ブロックの共通部分
///  （WOBJINIB）を拡張（オブジェクト指向言語の継承に相当）したもので，
///  最初のフィールドが共通になっている．
///
pub const MPFINIB = struct {
    wobjatr: ATR,               // 固定長メモリプール属性
    blkcnt: c_uint,             // メモリブロック数
    blksz: c_uint,              // メモリブロックのサイズ（丸めた値）
    mpf: [*]u8,                 // 固定長メモリプール領域の先頭番地
    p_mpfmb: [*]MPFMB,          // 固定長メモリプール管理領域の先頭番地
};

// 固定長メモリプール初期化ブロックのチェック
comptime {
    checkWobjIniB(MPFINIB);
}

///
///  固定長メモリプール管理ブロック
///
///  この構造体は，同期・通信オブジェクトの管理ブロックの共通部分
///  （WOBJCB）を拡張（オブジェクト指向言語の継承に相当）したもので，
///  最初の2つのフィールドが共通になっている．
///
const MPFCB = struct {
    wait_queue: queue.Queue,     // 固定長メモリプール待ちキュー
    p_wobjinib: *const MPFINIB, // 初期化ブロックへのポインタ
    fblkcnt: c_uint,            // 未割当てブロック数
    unused: c_uint,             // 未使用ブロックの先頭
    freelist: c_uint,           // 未割当てブロックのリスト
};

// 固定長メモリプール管理ブロックのチェック
comptime {
    checkWobjCB(MPFCB);
}

///
///  固定長メモリプール待ち情報ブロックの定義
///
///  この構造体は，同期・通信オブジェクトの待ち情報ブロックの共通部分
///  （WINFO_WOBJ）を拡張（オブジェクト指向言語の継承に相当）したもの
///  で，最初の2つのフィールドが共通になっている．
///
const WINFO_MPF = struct {
    winfo: WINFO,              // 標準の待ち情報ブロック
    p_wobjcb: *MPFCB,          // 待っている固定長メモリプールの管理ブロック
    blk: [*]u8,                // 獲得したメモリブロック
};

// 固定長メモリプール待ち情報ブロックのチェック
comptime {
    checkWinfoWobj(WINFO_MPF);
}

///
///  固定長メモリプールに関するコンフィギュレーションデータの取り込み
///
pub const ExternMpfCfg = struct {
    ///
    ///  固定長メモリプールIDの最大値
    ///
    pub extern const _kernel_tmax_mpfid: ID;

    ///
    ///  固定長メモリプール初期化ブロックのエリア
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern const _kernel_mpfinib_table: [100]MPFINIB;

    ///
    ///  固定長メモリプール管理ブロックのエリア
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern var _kernel_mpfcb_table: [100]MPFCB;
};

///
///  固定長メモリプールの数
///
fn numOfMpf() usize {
    return @intCast(usize, cfg._kernel_tmax_mpfid - TMIN_MPFID + 1);
}

///
///  固定長メモリプールIDから固定長メモリプール管理ブロックを取り出すための関数
///
fn indexMpf(mpfid: ID) usize {
    return @intCast(usize, mpfid - TMIN_MPFID);
}
fn checkAndGetMpfCB(mpfid: ID) ItronError!*MPFCB {
    try checkId(TMIN_MPFID <= mpfid and mpfid <= cfg._kernel_tmax_mpfid);
    return &cfg._kernel_mpfcb_table[indexMpf(mpfid)];
}

///
///  固定長メモリプール管理ブロックから固定長メモリプールIDを取り出すための関数
///
fn getMpfIdFromMpfCB(p_mpfcb: *MPFCB) ID {
    return @intCast(ID, (@ptrToInt(p_mpfcb)
                             - @ptrToInt(&cfg._kernel_mpfcb_table))
                        / @sizeOf(MPFCB)) + TMIN_MPFID;
}

///
///  固定長メモリプール待ち情報ブロックを取り出すための関数
///
pub fn getWinfoMpf(p_winfo: *WINFO) *WINFO_MPF {
    return @fieldParentPtr(WINFO_MPF, "winfo", p_winfo);
}

///
///  待ち情報ブロックから固定長メモリプールIDを取り出すための関数
///
pub fn getMpfIdFromWinfo(p_winfo: *WINFO) ID {
    return getMpfIdFromMpfCB(getWinfoMpf(p_winfo).p_wobjcb);
}

///
///  固定長メモリプール機能の初期化
///
pub fn initialize_mempfix() void {
    for (cfg._kernel_mpfcb_table[0 .. numOfMpf()]) |*p_mpfcb, i| {
        p_mpfcb.wait_queue.initialize();
        p_mpfcb.p_wobjinib = &cfg._kernel_mpfinib_table[i];
        p_mpfcb.fblkcnt = p_mpfcb.p_wobjinib.blkcnt;
        p_mpfcb.unused = 0;
        p_mpfcb.freelist = INDEX_NULL;
    }
}

///
///  固定長メモリプールからブロックを獲得
///
fn getMpfBlock(p_mpfcb: *MPFCB, p_blk: *[*]u8) void {
    var blkidx: c_uint = undefined;

    if (p_mpfcb.freelist != INDEX_NULL) {
        blkidx = p_mpfcb.freelist;
        p_mpfcb.freelist = p_mpfcb.p_wobjinib.p_mpfmb[blkidx].next;
    }
    else {
        blkidx = p_mpfcb.unused;
        p_mpfcb.unused += 1;
    }
    p_blk.* = p_mpfcb.p_wobjinib.mpf + p_mpfcb.p_wobjinib.blksz * blkidx;
    p_mpfcb.fblkcnt -= 1;
    p_mpfcb.p_wobjinib.p_mpfmb[blkidx].next = INDEX_ALLOC;
}

///
///  固定長メモリブロックの獲得
///
pub fn get_mpf(mpfid: ID, p_blk: **u8) ItronError!void {
    traceLog("getMpfEnter", .{ mpfid, p_blk });
    errdefer |err| traceLog("getMpfLeave", .{ err, p_blk });
    try checkDispatch();
    const p_mpfcb = try checkAndGetMpfCB(mpfid);
    {
        target_impl.lockCpuDsp();
        defer target_impl.unlockCpuDsp();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (p_mpfcb.fblkcnt > 0) {
            getMpfBlock(p_mpfcb, @ptrCast(*[*]u8, p_blk));
        }
        else {
            var winfo_mpf: WINFO_MPF = undefined;
            wobj_make_wait(p_mpfcb, TS_WAITING_MPF, &winfo_mpf);
            target_impl.dispatch();
            if (winfo_mpf.winfo.werror) |werror| {
                return werror;
            }
        }
    }
    traceLog("getMpfLeave", .{ null, p_blk });
}

///
///  固定長メモリブロックの獲得（ポーリング）
///
pub fn pget_mpf(mpfid: ID, p_blk: **u8) ItronError!void {
    traceLog("pGetMpfEnter", .{ mpfid, p_blk });
    errdefer |err| traceLog("pGetMpfLeave", .{ err, p_blk });
    try checkContextTaskUnlock();
    const p_mpfcb = try checkAndGetMpfCB(mpfid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (p_mpfcb.fblkcnt > 0) {
            getMpfBlock(p_mpfcb, @ptrCast(*[*]u8, p_blk));
        }
        else {
            return ItronError.TimeoutError;
        }
    }
    traceLog("pGetMpfLeave", .{ null, p_blk });
}

///
///  固定長メモリブロックの獲得（タイムアウトあり）
///
pub fn tget_mpf(mpfid: ID, p_blk: **u8, tmout: TMO) ItronError!void {
    traceLog("tGetMpfEnter", .{ mpfid, p_blk, tmout });
    errdefer |err| traceLog("tGetMpfLeave", .{ err, p_blk });
    try checkDispatch();
    const p_mpfcb = try checkAndGetMpfCB(mpfid);
    try checkParameter(validTimeout(tmout));
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (p_runtsk.?.flags.raster) {
            return ItronError.TerminationRequestRaised;
        }
        else if (p_mpfcb.fblkcnt > 0) {
            getMpfBlock(p_mpfcb, @ptrCast(*[*]u8, p_blk));
        }
        else if (tmout == TMO_POL) {
            return ItronError.TimeoutError;
        }
        else {
            var winfo_mpf: WINFO_MPF = undefined;
            var tmevtb: TMEVTB = undefined;
            wobj_make_wait_tmout(p_mpfcb, TS_WAITING_MPF, &winfo_mpf,
                                 &tmevtb, tmout);
            target_impl.dispatch();
            if (winfo_mpf.winfo.werror) |werror| {
                return werror;
            }
        }
    }
    traceLog("tGetMpfLeave", .{ null, p_blk });
}

///
///  固定長メモリブロックの返却
///
pub fn rel_mpf(mpfid: ID, blk: *u8) ItronError!void {
    traceLog("relMpfEnter", .{ mpfid, blk });
    errdefer |err| traceLog("relMpfLeave", .{ err });
    try checkContextTaskUnlock();
    const p_mpfcb = try checkAndGetMpfCB(mpfid);
    try checkParameter(@ptrToInt(p_mpfcb.p_wobjinib.mpf) <= @ptrToInt(blk));
    var blkoffset = @ptrToInt(blk) - @ptrToInt(p_mpfcb.p_wobjinib.mpf);
    try checkParameter(blkoffset % p_mpfcb.p_wobjinib.blksz == 0);
    try checkParameter(blkoffset / p_mpfcb.p_wobjinib.blksz < p_mpfcb.unused);
    var blkidx = @intCast(c_uint, blkoffset / p_mpfcb.p_wobjinib.blksz);
    try checkParameter(p_mpfcb.p_wobjinib.p_mpfmb[blkidx].next == INDEX_ALLOC);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        if (!p_mpfcb.wait_queue.isEmpty()) {
            const p_tcb = getTCBFromQueue(p_mpfcb.wait_queue.deleteNext());
            getWinfoMpf(p_tcb.p_winfo).blk = ptrAlignCast([*]u8, blk);
            wait_complete(p_tcb);
            taskDispatch();
        }
        else {
            p_mpfcb.fblkcnt += 1;
            p_mpfcb.p_wobjinib.p_mpfmb[blkidx].next = p_mpfcb.freelist;
            p_mpfcb.freelist = blkidx;
        }
    }
    traceLog("relMpfLeave", .{ null });
}

///
///  固定長メモリプールの再初期化
///
pub fn ini_mpf(mpfid: ID) ItronError!void {
    traceLog("iniMpfEnter", .{ mpfid });
    errdefer |err| traceLog("iniMpfLeave", .{ err });
    try checkContextTaskUnlock();
    const p_mpfcb = try checkAndGetMpfCB(mpfid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        init_wait_queue(&p_mpfcb.wait_queue);
        p_mpfcb.fblkcnt = p_mpfcb.p_wobjinib.blkcnt;
        p_mpfcb.unused = 0;
        p_mpfcb.freelist = INDEX_NULL;
        taskDispatch();
    }
    traceLog("iniMpfLeave", .{ null });
}

///
///  固定長メモリプールの状態参照
///
pub fn ref_mpf(mpfid: ID, pk_rmpf: *T_RMPF) ItronError!void {
    traceLog("refMpfEnter", .{ mpfid, pk_rmpf });
    errdefer |err| traceLog("refMpfLeave", .{ err, pk_rmpf });
    try checkContextTaskUnlock();
    const p_mpfcb = try checkAndGetMpfCB(mpfid);
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        pk_rmpf.wtskid = wait_tskid(&p_mpfcb.wait_queue);
        pk_rmpf.fblkcnt = p_mpfcb.fblkcnt;
    }
    traceLog("refMpfLeave", .{ null, pk_rmpf });
}

///
///  固定長メモリプールの生成（静的APIの処理）
///
pub fn cre_mpf(comptime cmpf: T_CMPF) ItronError!MPFINIB {
    // mpfatrが無効の場合（E_RSATR）［NGKI2225］［NGKI2218］
    //（TA_TPRI以外のビットがセットされている場合）
    try checkValidAtr(cmpf.mpfatr, TA_TPRI);

    // blkcntが0の場合（E_PAR）［NGKI2229］
    try checkParameter(cmpf.blkcnt > 0);

    // blkszが0の場合（E_PAR）［NGKI2230］
    try checkParameter(cmpf.blksz > 0);

    // 固定長メモリプール領域の確保
    comptime const blksz = TOPPERS_ROUND_SZ(cmpf.blksz, MPF_ALIGN);
    comptime const mpf = if (cmpf.mpf) |mpf| mpf
        else &struct {
            var mpf: [cmpf.blkcnt * blksz]u8 align(MPF_ALIGN) = undefined;
        }.mpf;

    // mpfmbがNULLでない場合（E_NOSPT）［ASPS0132］
    try checkNotSupported(cmpf.mpfmb == null);

    // 固定長メモリプール管理領域の確保
    comptime const p_mpfmb =  &struct {
        var mpfmb: [cmpf.blkcnt]MPFMB = undefined;
    }.mpfmb;

    // データキュー初期化ブロックを返す
    return MPFINIB{ .wobjatr = cmpf.mpfatr,
                    .blkcnt = cmpf.blkcnt,
                    .blksz = cmpf.blksz,
                    .mpf = mpf,
                    .p_mpfmb = p_mpfmb, };
}

///
///  固定長メモリプールに関するコンフィギュレーションデータの取り込み
///  （静的APIの処理）
///
pub fn ExportMpfCfg(mpfinib_table: []MPFINIB) type {
    // チェック処理用の定義の生成
    exportCheck(@sizeOf(MPFINIB), "sizeof_MPFINIB");
    exportCheck(@byteOffsetOf(MPFINIB, "mpf"), "offsetof_MPFINIB_mpf");

    const tnum_mpf = mpfinib_table.len;
    return struct {
        pub export const _kernel_tmax_mpfid: ID = tnum_mpf;

        // Zigの制限の回避：BIND_CFG != nullの場合に，サイズ0の配列が
        // 出ないようにする
        pub export const _kernel_mpfinib_table =
            if (option.BIND_CFG == null or tnum_mpf > 0)
                mpfinib_table[0 .. tnum_mpf].*
            else [1]MPFINIB{ .{ .wobjatr = 0, .blkcnt = 0, .blksz = 0,
                                .mpf = @intToPtr([*]u8, 256),
                                .p_mpfmb = @intToPtr([*]MPFMB, 256), }};
        pub export var _kernel_mpfcb_table:
            [if (option.BIND_CFG == null or tnum_mpf > 0) tnum_mpf
                 else 1]MPFCB = undefined;
    };
}
