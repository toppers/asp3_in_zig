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
///  待ち状態管理モジュール
///
usingnamespace @import("kernel_impl.zig");
usingnamespace task;
usingnamespace time_event;

///
///  待ち情報ブロック（WINFO）の定義
///
///  タスクが待ち状態の間は，TCBおよびそのp_winfoで指されるWINFOを次の
///  ように設定しなければならない．
///
///  (a) TCBのタスク状態を待ち状態（TS_WAITING_???）にする．
///
///  (b) タイムアウトを監視するために，タイムイベントブロックを登録す
///  る．登録するタイムイベントブロックは，待ちに入るサービスコール処
///  理関数のローカル変数として確保し，それへのポインタをWINFOの
///  p_tmevtbに記憶する．タイムアウトの監視が必要ない場合（永久待ちの
///  場合）には，p_tmevtbをNULLにする．
///
///  同期・通信オブジェクトに対する待ち状態の場合には，標準のWINFOに
///  p_wobjcbフィールドを追加した構造体（WINFO_WOBJ，wait.hで定義）に，
///  待ち対象の同期・通信オブジェクトに依存して記憶することが必要な情
///  報のためのフィールドを追加した構造体（WINFO_???）を定義し，WINFO
///  の代わりに用いる．また，以下の(c)〜(e)の設定を行う必要がある．同
///  期・通信オブジェクトに関係しない待ち（起床待ち，時間経過待ち）の
///  場合には，これらは必要ない．
///
///  (c) TCBを待ち対象の同期・通信オブジェクトの待ちキューにつなぐ．待
///  ちキューにつなぐために，task_queueを使う．
///
///  (d) 待ち対象の同期・通信オブジェクトの管理ブロックへのポインタを，
///  WINFO_WOBJのp_wobjcbに記憶する．
///
///  (e) 待ち対象の同期・通信オブジェクトに依存して記憶することが必要
///  な情報がある場合には，WINFO_???内のフィールドに記憶する．
///
///  待ち状態を解除する際には，待ち解除したタスクに対する返値をWINFOの
///  werrorに設定する．werrorが必要なのは待ち解除以降であるのに対して，
///  p_tmevtbは待ち解除後は必要ないため，メモリ節約のために共用体を使っ
///  ている．そのため，wercdへエラーコードを設定するのは，タイムイベン
///  トブロックを登録解除した後にしなければならない．
///
pub const WINFO = union {
    werror: ?ItronError,    // 待ち解除時のエラー
    p_tmevtb: ?*TMEVTB,     // 待ち状態用のタイムイベントブロック
};

///
///  タスクの優先度順の待ちキューへの挿入
///
///  p_tcbで指定されるタスクを，タスク優先度順のキューp_queueに挿入す
///  る．キューの中に同じ優先度のタスクがある場合には，その最後に挿入
///  する．
///
pub fn queue_insert_tpri(p_queue: *queue.Queue, p_tcb: *TCB) void {
    const prio = p_tcb.prio;
    var p_entry = p_queue.p_next;
    while (p_entry != p_queue) : (p_entry = p_entry.p_next) {
        if (prio < getTCBFromQueue(p_entry).prio) {
            break;
        }
    }
    p_entry.insertPrev(&p_tcb.task_queue);
}

///
///  待ち状態への遷移
///
///  実行中のタスクを待ち状態に遷移させる．具体的には，実行中のタスク
///  のタスク状態をtstatにしてレディキューから削除し，TCBのp_winfoフィー
///  ルド，WINFOのp_tmevtbフィールドを設定する．
///
pub fn make_wait(tstat: u8, p_winfo: *WINFO) void {
    p_runtsk.?.tstat = tstat;
    make_non_runnable(p_runtsk.?);
    p_runtsk.?.p_winfo = p_winfo;
    p_winfo.* = WINFO{ .p_tmevtb = null };
}

///
///  待ち状態への遷移（タイムアウト指定）
///
///  実行中のタスクを，タイムアウト指定付きで待ち状態に遷移させる．具
///  体的には，実行中のタスクのタスク状態をtstatにしてレディキューから
///  削除し，TCBのp_winfoフィールド，WINFOのp_tmevtbフィールドを設定す
///  る．また，タイムイベントブロックを登録する．
///
pub fn make_wait_tmout(tstat: u8, p_winfo: *WINFO,
                       p_tmevtb: *TMEVTB, tmout: TMO) void {
    p_runtsk.?.tstat = tstat;
    make_non_runnable(p_runtsk.?);
    p_runtsk.?.p_winfo = p_winfo;
    if (tmout == TMO_FEVR) {
        p_winfo.p_tmevtb = null;
    }
    else {
        assert(tmout <= TMAX_RELTIM);
        p_winfo.p_tmevtb = p_tmevtb;
        p_tmevtb.callback = wait_tmout;
        p_tmevtb.arg = @ptrToInt(p_runtsk);
        tmevtb_enqueue_reltim(p_tmevtb, @intCast(RELTIM, tmout));
    }
}

///
///  待ち解除のためのタスク状態の更新
///
///  p_tcbで指定されるタスクを，待ち解除するようタスク状態を更新する．
///  待ち解除するタスクが実行できる状態になる場合は，レディキューにつ
///  なぐ．
///
pub fn make_non_wait(p_tcb: *TCB) void {
    assert(isWaiting(p_tcb.tstat));

    if (!isSuspended(p_tcb.tstat)) {
        // 待ち状態から実行できる状態への遷移
        p_tcb.tstat = TS_RUNNABLE;
        traceLog("taskStateChange", .{ p_tcb });
        make_runnable(p_tcb);
    }
    else {
        // 二重待ち状態から強制待ち状態への遷移
        p_tcb.tstat = TS_SUSPENDED;
        traceLog("taskStateChange", .{ p_tcb });
    }
}

///
///  オブジェクト待ちキューからの削除
///
///  p_tcbで指定されるタスクが，同期・通信オブジェクトの待ちキューにつ
///  ながれていれば，待ちキューから削除する．
///
pub fn wait_dequeue_wobj(p_tcb: *TCB) void {
    if (isWaitingWobj(p_tcb.tstat)) {
        p_tcb.task_queue.delete();
    }
}

///
///  時間待ちのためのタイムイベントブロックの登録解除
///
///  p_tcbで指定されるタスクに対して，時間待ちのためのタイムイベントブ
///  ロックが登録されていれば，それを登録解除する．
///
pub fn wait_dequeue_tmevtb(p_tcb: *TCB) void {
    if (p_tcb.p_winfo.p_tmevtb) |p_tmevtb| {
        tmevtb_dequeue(p_tmevtb);
    }
}

///
///  待ち解除
///
///  p_tcbで指定されるタスクの待ち状態を解除する．具体的には，タイムイ
///  ベントブロックが登録されていれば，それを登録解除する．また，タス
///  ク状態を更新し，待ち解除したタスクからの返値をnull（エラー無し）
///  とする．待ちキューからの削除は行わない．
///
pub fn wait_complete(p_tcb: *TCB) void {
    wait_dequeue_tmevtb(p_tcb);
    p_tcb.p_winfo.* = WINFO{ .werror = null };
    make_non_wait(p_tcb);
}

///
///  タイムアウトに伴う待ち解除
///
///  p_tcbで指定されるタスクが，待ちキューにつながれていれば待ちキュー
///  から削除し，タスク状態を更新する．また，待ち解除したタスクからの
///  返値を，wait_tmoutではTimeoutError，wait_tmout_okではnull（エラー
///  無し）とする．
///
///  wait_tmout_okは，dly_tskで使うためのもので，待ちキューから削除す
///  る処理を行わない．
///
///  いずれの関数も，タイムイベントのコールバック関数として用いるため
///  のもので，割込みハンドラから呼び出されることを想定している．
///
pub fn wait_tmout(arg: usize) void {
    const p_tcb = @intToPtr(*TCB, arg);

    wait_dequeue_wobj(p_tcb);
    p_tcb.p_winfo.* = WINFO{ .werror = ItronError.TimeoutError };
    make_non_wait(p_tcb);
    if (p_runtsk != p_schedtsk) {
        target_impl.requestDispatchRetint();
    }

    // ここで優先度の高い割込みを受け付ける．
    target_impl.unlockCpu();
    target_impl.delayForInterrupt();
    target_impl.lockCpu();
}

pub fn wait_tmout_ok(arg: usize) void {
    const p_tcb = @intToPtr(*TCB, arg);

    p_tcb.p_winfo.* = WINFO{ .werror = null };
    make_non_wait(p_tcb);
    if (p_runtsk != p_schedtsk) {
        target_impl.requestDispatchRetint();
    }

    // ここで優先度の高い割込みを受け付ける．
    target_impl.unlockCpu();
    target_impl.delayForInterrupt();
    target_impl.lockCpu();
}

///
///  待ちキューの先頭のタスクID
///
///  p_wait_queueで指定した待ちキューの先頭のタスクIDを返す．待ちキュー
///  が空の場合には，TSK_NONEを返す．
///
pub fn wait_tskid(p_wait_queue: *queue.Queue) ID {
    if (!p_wait_queue.isEmpty()) {
        return getTskIdFromTCB(getTCBFromQueue(p_wait_queue.p_next));
    }
    else {
        return TSK_NONE;
    }
}

///
///  同期・通信オブジェクトの管理ブロックの共通部分操作ルーチン
///
///  同期・通信オブジェクトの初期化ブロック，管理ブロック，待ち情報ブ
///  ロックの先頭部分は共通になっている．以下は，その共通部分を扱うた
///  めの型および関数である．
///
///  複数の待ちキューを持つ同期・通信オブジェクトの場合，先頭以外の待
///  ちキューを操作する場合には，これらのルーチンは使えない．また，オ
///  ブジェクト属性のTA_TPRIビットを参照するので，このビットを他の目的
///  に使っている場合も，これらのルーチンは使えない．
///

///
///  同期・通信オブジェクトの初期化ブロックの共通部分
///
pub const WOBJINIB = struct {
    wobjatr: ATR,                   // オブジェクト属性
};

// 同期・通信オブジェクトの管理ブロックのチェック
pub fn checkWobjIniB(comptime T: type) void {
    if (@byteOffsetOf(T, "wobjatr") != @byteOffsetOf(WOBJINIB, "wobjatr")) {
        @compileError("offsets of wobjatr in " ++ @typeName(T)
                          ++ " and wobjatr in WOBJINIB are different.");
    }
}

///
///  同期・通信オブジェクトの管理ブロックの共通部分
///
pub const WOBJCB = struct {
    wait_queue: queue.Queue,        // 待ちキュー
    p_wobjinib: *const WOBJINIB,    // 初期化ブロックへのポインタ
};

// 同期・通信オブジェクトの管理ブロックのチェック
pub fn checkWobjCB(comptime T: type) void {
    const qname = if (@hasField(T, "wait_queue")) "wait_queue"
                                             else "swait_queue";
    if (@byteOffsetOf(T, qname)
            != @byteOffsetOf(WOBJCB, "wait_queue")) {
        @compileError("offsets of " ++ qname ++ " in " ++ @typeName(T)
                          ++ " and wait_queue in WOBJCB are different.");
    }
    if (@byteOffsetOf(T, "p_wobjinib") != @byteOffsetOf(WOBJCB, "p_wobjinib")) {
        @compileError("offsets of p_wobjinib in " ++ @typeName(T)
                          ++ " and wobjinib in WOBJCB are different.");
    }
}

///
///  同期・通信オブジェクトの待ち情報ブロックの共通部分
///
pub const WINFO_WOBJ = struct {
    winfo: WINFO,                   // 標準の待ち情報ブロック
    p_wobjcb: *WOBJCB,              // 待ちオブジェクトの管理ブロック
};

// 同期・通信オブジェクトの待ち情報ブロックのチェック
pub fn checkWinfoWobj(comptime T: type) void {
    if (@byteOffsetOf(T, "winfo") != @byteOffsetOf(WINFO_WOBJ, "winfo")) {
        @compileError("offsets of winfo in " ++ @typeName(T)
                          ++ " and winfo in WINFO_WOBJ are different.");
    }
    if (@byteOffsetOf(T, "p_wobjcb") != @byteOffsetOf(WINFO_WOBJ, "p_wobjcb")) {
        @compileError("offsets of p_wobjcb in " ++ @typeName(T)
                          ++ " and wobjcb in WINFO_WOBJ are different.");
    }
}

///
///  実行中のタスクの同期・通信オブジェクトの待ちキューへの挿入
///
fn wobj_queue_insert(p_wobjcb: *WOBJCB) void {
    if ((p_wobjcb.p_wobjinib.wobjatr & TA_TPRI) != 0) {
        queue_insert_tpri(&p_wobjcb.wait_queue, p_runtsk.?);
    }
    else {
        p_wobjcb.wait_queue.insertPrev(&p_runtsk.?.task_queue);
    }
}

///
///  同期・通信オブジェクトに対する待ち状態への遷移
///  
///  実行中のタスクを待ち状態に遷移させ，同期・通信オブジェクトの待ち
///  キューにつなぐ．また，待ち情報ブロック（WINFO）のp_wobjcbを設定す
///  る．wobj_make_wait_tmoutは，タイムイベントブロックの登録も行う．
///
pub fn wobj_make_wait(p_wobjcb: anytype, tstat: u8,
                      p_winfo_wobj: anytype) void {
    make_wait(tstat, &p_winfo_wobj.winfo);
    wobj_queue_insert(@ptrCast(*WOBJCB, p_wobjcb));
    p_winfo_wobj.p_wobjcb = p_wobjcb;
    traceLog("taskStateChange", .{ p_runtsk.? });
}

pub fn wobj_make_wait_tmout(p_wobjcb: anytype, tstat: u8, p_winfo_wobj: anytype,
                            p_tmevtb: *TMEVTB, tmout: TMO) void {
    make_wait_tmout(tstat, &p_winfo_wobj.winfo, p_tmevtb, tmout);
    wobj_queue_insert(@ptrCast(*WOBJCB, p_wobjcb));
    p_winfo_wobj.p_wobjcb = p_wobjcb;
    traceLog("taskStateChange", .{ p_runtsk.? });
}

pub fn wobj_make_rwait(p_wobjcb: anytype, tstat: u8,
                       p_winfo_wobj: anytype) void {
    make_wait(tstat, &p_winfo_wobj.winfo);
    p_wobjcb.rwait_queue.insertPrev(&p_runtsk.?.task_queue);
    p_winfo_wobj.p_wobjcb = p_wobjcb;
    traceLog("taskStateChange", .{ p_runtsk.? });
}

pub fn wobj_make_rwait_tmout(p_wobjcb: anytype,
                             tstat: u8, p_winfo_wobj: anytype,
                             p_tmevtb: *TMEVTB, tmout: TMO) void {
    make_wait_tmout(tstat, &p_winfo_wobj.winfo, p_tmevtb, tmout);
    p_wobjcb.rwait_queue.insertPrev(&p_runtsk.?.task_queue);
    p_winfo_wobj.p_wobjcb = p_wobjcb;
    traceLog("taskStateChange", .{ p_runtsk.? });
}

///
///  タスク優先度変更時の処理
///
///  同期・通信オブジェクトに対する待ち状態にあるタスクの優先度が変更
///  された場合に，待ちキューの中でのタスクの位置を修正する．
///
pub fn wobj_change_priority(p_wobjcb: *WOBJCB, p_tcb: *TCB) void {
    if ((p_wobjcb.p_wobjinib.wobjatr & TA_TPRI) != 0) {
        p_tcb.task_queue.delete();
        queue_insert_tpri(&p_wobjcb.wait_queue, p_tcb);
    }
}

///
///  待ちキューの初期化
///
///  待ちキューにつながれているタスクをすべて待ち解除する．待ち解除し
///  たタスクからの返値は，ObjectDeletedとする．
///
pub fn init_wait_queue(p_wait_queue: *queue.Queue) void {
    while (!p_wait_queue.isEmpty()) {
        const p_tcb = getTCBFromQueue(p_wait_queue.deleteNext());
        wait_dequeue_tmevtb(p_tcb);
        p_tcb.p_winfo.* = WINFO{ .werror = ItronError.ObjectDeleted };
        make_non_wait(p_tcb);
    }
}
