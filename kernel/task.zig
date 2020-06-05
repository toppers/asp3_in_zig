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
///  タスク管理モジュール
///
usingnamespace @import("kernel_impl.zig");
usingnamespace wait;
usingnamespace time_event;
usingnamespace check;

///
///  ターゲット依存のタスク属性
///
const TARGET_TSKATR = decl(ATR, target_impl, "TARGET_TSKATR", 0);

///
///  スタックサイズの最小値
///
const TARGET_MIN_STKSZ = decl(usize, target_impl, "TARGET_MIN_STKSZ", 1);

///
///  スタックサイズのアライン単位
///
const CHECK_STKSZ_ALIGN = decl(usize, target_impl, "CHECK_STKSZ_ALIGN", 1);

///
///  スタック領域のアライン単位（チェック用）
///
const CHECK_STACK_ALIGN = decl(usize, target_impl, "CHECK_STACK_ALIGN", 1);

///
///  スタック領域のアライン単位（確保用）
///
const STACK_ALIGN = decl(usize, target_impl, "STACK_ALIGN", CHECK_STACK_ALIGN);

///
///  優先度の範囲チェック
///
pub fn validTaskPri(tskpri: PRI) bool {
    return TMIN_TPRI <= tskpri and tskpri <= TMAX_TPRI;
}

///
///  タスクの優先度の内部表現の型
///
pub const TaskPrio = prio_bitmap.PrioType(TNUM_TPRI);

///
///  タスク優先度の内部表現・外部表現変換関数
///
pub fn internalTaskPrio(tskpri: PRI) TaskPrio {
    return @intCast(TaskPrio, tskpri - TMIN_TPRI);
}
pub fn externalTaskPrio(prio: TaskPrio) PRI {
    return @intCast(PRI, prio + TMIN_TPRI);
}

///
///  タスク状態の内部表現
///
///  TCB中のタスク状態のフィールドでは，タスクの状態と，タスクが待ち状
///  態の時の待ち要因を表す．ただし，実行状態（RUNNING）と実行可能状態
///  （READY）は区別せず，両状態をあわせて実行できる状態（RUNNABLE）と
///  して管理する．二重待ち状態は，(TS_WAITING_??? | TS_SUSPENDED)で表
///  す．
///
///  タスクが待ち状態（二重待ち状態を含む）の時は，TS_WAITING_???で待
///  ち要因を表す．待ち要因（5ビットで表現される）の上位2ビットで，同
///  期・通信オブジェクトの待ちキューにつながっているかどうかを表す．
///  同期・通信オブジェクトの待ちキューにつながらないものは上位2ビット
///  を00，同期・通信オブジェクトの管理ブロックの共通部分（WOBJCB）の
///  待ちキューにつながるものは10または11，それ以外の待ちキューにつな
///  がるものは01とする．
///
pub const TS_DORMANT      = 0x00;           // 休止状態
pub const TS_RUNNABLE     = 0x01;           // 実行できる状態
pub const TS_SUSPENDED    = 0x02;           // 強制待ち状態

pub const TS_WAITING_SLP  = (0x01 << 2);    // 起床待ち
pub const TS_WAITING_DLY  = (0x02 << 2);    // 時間経過待ち
pub const TS_WAITING_RDTQ = (0x08 << 2);    // データキューからの受信待ち
pub const TS_WAITING_RPDQ = (0x09 << 2);    // 優先度データキューからの受信待ち
pub const TS_WAITING_SEM  = (0x10 << 2);    // セマフォ資源の獲得待ち
pub const TS_WAITING_FLG  = (0x11 << 2);    // イベントフラグ待ち
pub const TS_WAITING_SDTQ = (0x12 << 2);    // データキューへの送信待ち
pub const TS_WAITING_SPDQ = (0x13 << 2);    // 優先度データキューへの送信待ち
pub const TS_WAITING_MTX  = (0x14 << 2);    // ミューテックスのロック待ち
pub const TS_WAITING_MPF  = (0x15 << 2);    // 固定長メモリブロックの獲得待ち

pub const TS_WAITING_MASK = (0x1f << 2);    // 待ち状態の判別用マスク

///
///  タスク状態判別関数
///
///  isDormantはタスクが休止状態であるかどうかを，isRunnableはタスクが
///  実行できる状態であるかどうかを判別する．isWaitingは待ち状態と二重
///  待ち状態のいずれかであるかどうかを，isSuspendedは強制待ち状態と二
///  重待ち状態のいずれかであるかどうかを判別する．
///
pub fn isDormant(tstat: u8) bool {
    return tstat == TS_DORMANT;
}
pub fn isRunnable(tstat: u8) bool {
    return (tstat & TS_RUNNABLE) != 0;
}
pub fn isWaiting(tstat: u8) bool {
    return (tstat & TS_WAITING_MASK) != 0;
}
pub fn isSuspended(tstat: u8) bool {
    return (tstat & TS_SUSPENDED) != 0;
}

///
///  タスク待ち要因判別関数
///
///  isWaitingSlpはタスクが起床待ちであるかどうかを，isWaitingMtxはタ
///  スクがミューテックス待ちであるかどうかを判別する．
///
///  また，isWaitingWobjはタスクが同期・通信オブジェクトに対する待ちで
///  あるか（言い換えると，同期・通信オブジェクトの待ちキューにつなが
///  れているか）どうかを，isWaitingWobjCBはタスクが同期・通信オブジェ
///  クトの管理ブロックの共通部分（WOBJCB）の待ちキューにつながれてい
///  るかどうかを判別する．
///
pub fn isWaitingSlp(tstat: u8) bool {
    return (tstat & ~@as(u8, TS_SUSPENDED)) == TS_WAITING_SLP;
}
pub fn isWaitingMtx(tstat: u8) bool {
    return (tstat & ~@as(u8, TS_SUSPENDED)) == TS_WAITING_MTX;
}
pub fn isWaitingWobj(tstat: u8) bool {
    return (tstat & (0x18 << 2)) != 0;
}
pub fn isWaitingWobjCB(tstat: u8) bool {
    return (tstat & (0x10 << 2)) != 0;
}

///
///  タスク初期化ブロック
///
///  タスクに関する情報を，値が変わらないためにROMに置ける部分（タスク
///  初期化ブロック）と，値が変化するためにRAMに置かなければならない部
///  分（タスク管理ブロック，TCB）に分離し，TCB内に対応するタスク初期
///  化ブロックを指すポインタを入れる．タスク初期化ブロック内に対応す
///  るTCBを指すポインタを入れる方法の方が，RAMの節約の観点からは望ま
///  しいが，実行効率が悪くなるために採用していない．他のオブジェクト
///  についても同様に扱う．
///
pub const TINIB = struct {
    tskatr: ATR,                // タスク属性
    exinf: EXINF,               // タスクの拡張情報
    task: TASK,                 // タスクの起動番地
    ipri: c_uint,               // タスクの起動時優先度（内部表現）
    tskinictxb:                 // タスク初期化コンテキストブロック
        if (@hasDecl(target_impl, "TSKINICTXB"))
            target_impl.TSKINICTXB
        else struct {
            stksz: usize,       // スタック領域のサイズ（丸めた値）
            stk: [*]u8,         // スタック領域
        },
};

///
///  タスク管理ブロック（TCB）
///
///  ASPカーネルでは，強制待ち要求ネスト数の最大値（TMAX_SUSCNT）が1に
///  固定されているので，強制待ち要求ネスト数（suscnt）は必要ない．
///
///  TCBのいくつかのフィールドは，特定のタスク状態でのみ有効な値を保持
///  し，それ以外の場合は値が保証されない（よって，参照してはならない）．
///  各フィールドが有効な値を保持する条件は次の通り．
///
///  ・初期化後は常に有効：
///         p_tinib，tstat，actque, staovr, leftotm
///  ・休止状態以外で有効（休止状態では初期値になっている）：
///         bpriority，priority，wupque，raster，enater，p_lastmtx
///  ・待ち状態（二重待ち状態を含む）で有効：
///         p_winfo
///  ・実行できる状態と同期・通信オブジェクトに対する待ち状態で有効：
///         task_queue
///  ・実行可能状態，待ち状態，強制待ち状態，二重待ち状態で有効：
///         tskctxb
///
pub const TCB = struct {
    task_queue: queue.Queue,    // タスクキュー
    p_tinib: *const TINIB,      // 初期化ブロックへのポインタ

    tstat: u8,                  // タスク状態（内部表現）
    bprio: TaskPrio,            // ベース優先度（内部表現）
    prio: TaskPrio,             // 現在の優先度（内部表現）
    flags: packed struct {
        actque: u1,             // 起動要求キューイング
        wupque: u1,             // 起床要求キューイング
        raster: bool,           // タスク終了要求状態
        enater: bool,           // タスク終了許可状態
        staovr: if (TOPPERS_SUPPORT_OVRHDR) bool else void,
                                // オーバランハンドラ動作状態
    },
    p_winfo: *WINFO,            // 待ち情報ブロックへのポインタ
    p_lastmtx: ?*mutex.MTXCB,   // 最後にロックしたミューテックス */
    leftotm: if (TOPPERS_SUPPORT_OVRHDR) PRCTIM else void,
                                // 残りプロセッサ時間
    tskctxb: target_impl.TSKCTXB,
};                              // タスクコンテキストブロック
     
///
///  実行状態のタスク
///
///  実行状態のタスク（＝プロセッサがコンテキストを持っているタスク）
///  のTCBを指すポインタ．実行状態のタスクがない場合はnullにする．
///
///  サービスコールの処理中で，自タスク（サービスコールを呼び出したタ
///  スク）に関する情報を参照する場合はp_runtskを使う．p_runtskを書き
///  換えるのは，ディスパッチャ（と初期化処理）のみである．
///
pub var p_runtsk: ?*TCB = undefined;

///
///  実行すべきタスク
///
///  実行すべきタスクのTCBを指すポインタ．実行できるタスクがない場合は
///  nullにする．
///
///  p_runtskは，通常はp_schedtskと一致しているが，非タスクコンテキス
///  ト実行中は，一致しているとは限らない．割込み優先度マスク全解除で
///  ない状態の間とディスパッチ禁止状態の間（すなわち，dspflgがfalseで
///  ある間）は，p_schedtskを更新しない．
///
pub var p_schedtsk: ?*TCB = undefined;

///
///  ディスパッチ許可状態
///
///  ディスパッチ許可状態であることを示すフラグ．
///
pub var enadsp: bool = undefined;

///
///  タスクディスパッチ可能状態
///
///  割込み優先度マスク全解除状態であり，ディスパッチ許可状態である
///  （ディスパッチ禁止状態でない）ことを示すフラグ．ディスパッチ保留
///  状態でないことは，タスクコンテキスト実行中で，CPUロック状態でなく，
///  dspflgがtrueであることで判別することができる．
///
pub var dspflg: bool = undefined;

///
///  レディキュー
///
///  レディキューは，実行できる状態のタスクを管理するためのキューであ
///  る．実行状態のタスクも管理しているため，レディ（実行可能）キュー
///  という名称は正確ではないが，レディキューという名称が定着している
///  ため，この名称で呼ぶことにする．
///
///  レディキューは，優先度ごとのタスクキューで構成されている．タスク
///  のTCBは，該当する優先度のキューに登録される．
///
pub var ready_queue: [TNUM_TPRI]queue.Queue = undefined;

///
///  レディキューサーチのためのビットマップ
///
///  レディキューのサーチを効率よく行うために，優先度ごとのタスクキュー
///  にタスクが入っているかどうかを示すビットマップを用意している．ビッ
///  トマップを使うことで，メモリアクセスの回数を減らすことができるが，
///  ビット操作命令が充実していないプロセッサで，優先度の段階数が少な
///  い場合には，ビットマップ操作のオーバーヘッドのために，逆に効率が
///  落ちる可能性もある．
///
var ready_primap: prio_bitmap.PrioBitmap(TNUM_TPRI) = undefined;

///
///  タスクに関するコンフィギュレーションデータの取り込み
///
pub const ExternTskCfg = struct {
    ///
    ///  タスクIDの最大値
    ///
    pub extern const _kernel_tmax_tskid: ID;

    ///
    ///  タスク初期化ブロックのエリア
    ///
    // zigの制限の回避（配列のサイズを大きい値にしている）
    pub extern const _kernel_tinib_table: [100]TINIB;

    ///
    ///  タスク生成順序テーブル
    ///
    // zigの制限の回避（配列のサイズを大きい値にしている）
    pub extern const _kernel_torder_table: [100]ID;

    ///
    ///  TCBのエリア
    ///
    // zigの制限の回避（配列のサイズを大きい値にしている）
    pub extern var _kernel_tcb_table: [100]TCB;
};

///
///  タスクの数
///
fn numOfTsk() usize {
    return @intCast(usize, cfg._kernel_tmax_tskid - TMIN_TSKID + 1);
}

///
///  タスクIDからTCBを取り出すための関数
///
fn indexTsk(tskid: ID) usize {
    return @intCast(usize, tskid - TMIN_TSKID);
}
pub fn checkAndGetTCB(tskid: ID) ItronError!*TCB {
    try checkId(TMIN_TSKID <= tskid and tskid <= cfg._kernel_tmax_tskid);
    return &cfg._kernel_tcb_table[indexTsk(tskid)];
}

///
///  タスクIDからタスク初期化ブロックを取り出すための関数
///
pub fn getTIniB(tskid: ID) *const TINIB {
    return &cfg._kernel_tinib_table[indexTsk(tskid)];
}

///
///  TCBからタスクIDを取り出すための関数
///
pub fn getTskIdFromTCB(p_tcb: *TCB) ID {
    return @intCast(ID, (@ptrToInt(p_tcb) - @ptrToInt(&cfg._kernel_tcb_table))
                        / @sizeOf(TCB)) + TMIN_TSKID;
}

///
///  タスクキューからTCBを取り出すための関数
///
pub fn getTCBFromQueue(p_entry: *queue.Queue) *TCB {
    return @fieldParentPtr(TCB, "task_queue", p_entry);
}

///
///  ミューテックス機能のためのフックルーチン
///
pub var mtxhook_check_ceilpri: ?fn(p_tcb: *TCB, bprio: TaskPrio) bool = null;
pub var mtxhook_scan_ceilmtx: ?fn(p_tcb: *TCB) bool = null;
pub var mtxhook_release_all: ?fn(p_tcb: *TCB) void = null;

///
///  タスク管理モジュールの初期化
///
pub fn initialize_task() void {
    p_runtsk = null;
    p_schedtsk = null;
    enadsp = true;
    dspflg = true;

    for (ready_queue) |*p_queue| {
        p_queue.initialize();
    }
    ready_primap.initialize();

    for (cfg._kernel_torder_table[0 .. numOfTsk()]) |tskid| {
        const p_tcb = &cfg._kernel_tcb_table[indexTsk(tskid)];
        p_tcb.p_tinib = &cfg._kernel_tinib_table[indexTsk(tskid)];
        p_tcb.flags.actque = 0;
        make_dormant(p_tcb);
        p_tcb.p_lastmtx = null;
        if ((p_tcb.p_tinib.tskatr & TA_ACT) != 0) {
            make_active(p_tcb);
        }
    }
}

///
///  最高優先順位タスクのサーチ
///
///  レディキュー中の最高優先順位のタスクをサーチし，そのTCBへのポイン
///  タを返す．レディキューが空の場合には，この関数を呼び出してはなら
///  ない．
///
fn searchSchedtsk() *TCB {
    return getTCBFromQueue(ready_queue[ready_primap.search()].p_next);
}

///
///  実行できる状態への遷移
///
///  p_tcbで指定されるタスクをレディキューに挿入する．また，必要な場合
///  には，実行すべきタスクを更新する．
///
pub fn make_runnable(p_tcb: *TCB) void {
    const prio = p_tcb.prio;

    ready_queue[prio].insertPrev(&p_tcb.task_queue);
    ready_primap.set(prio);

    if (dspflg) {
        if (p_schedtsk == null or prio < p_schedtsk.?.prio) {
            p_schedtsk = p_tcb;
        }
    }
}

///
///  実行できる状態から他の状態への遷移
///
///  p_tcbで指定されるタスクをレディキューに挿入する．また，必要な場合
///  には，実行すべきタスクを更新する．
///
pub fn make_non_runnable(p_tcb: *TCB) void {
    const prio = p_tcb.prio;
    const p_queue = &ready_queue[prio];

    p_tcb.task_queue.delete();
    if (p_queue.isEmpty()) {
        ready_primap.clear(prio);
        if (p_schedtsk == p_tcb) {
            assert(dspflg);
            p_schedtsk = if (ready_primap.isEmpty()) null
                else searchSchedtsk();
        }
    }
    else {
        if (p_schedtsk == p_tcb) {
            assert(dspflg);
            p_schedtsk = getTCBFromQueue(p_queue.p_next);
        }
    }
}

///
///  タスクディスパッチ可能状態への遷移
///
///  タスクディスパッチ可能状態であることを示すフラグ（dspflg）をtrue
///  にし，実行すべきタスクを更新する．
///
pub fn set_dspflg() void {
    dspflg = true;
    p_schedtsk = searchSchedtsk();
}

///
///  休止状態への遷移
///
///  p_tcbで指定されるタスクの状態を休止状態とする．また，タスクの起動
///  時に初期化すべき変数の初期化と，タスク起動のためのコンテキストを
///  設定する．
///
fn make_dormant(p_tcb: *TCB) void {
    p_tcb.tstat = TS_DORMANT;
    p_tcb.bprio = @intCast(TaskPrio, p_tcb.p_tinib.ipri);
    p_tcb.prio = p_tcb.bprio;
    p_tcb.flags.wupque = 0;
    p_tcb.flags.raster = false;
    p_tcb.flags.enater = true;
    if (TOPPERS_SUPPORT_OVRHDR) {
        p_tcb.flags.staovr = false;
    }
    traceLog("taskStateChange", .{ p_tcb });
}

///
///  休止状態から実行できる状態への遷移
///
///  p_tcbで指定されるタスクの状態を休止状態から実行できる状態とする．
///
pub fn make_active(p_tcb: *TCB) void {
    target_impl.activateContext(p_tcb);
    p_tcb.tstat = TS_RUNNABLE;
    traceLog("taskStateChange", .{ p_tcb });
    make_runnable(p_tcb);
}

///
///  タスクの優先度の変更
///
///  p_tcbで指定されるタスクの優先度をnewpri（内部表現）に変更する．ま
///  た，必要な場合には，実行すべきタスクを更新する．
///
///  p_tcbで指定されるタスクが実行できる状態である場合，その優先順位は，
///  優先度が同じタスクの中で，mtxmodeがfalseの時は最低，mtxmodeがtrue
///  の時は最高とする．
///
pub fn change_priority(p_tcb: *TCB, newprio: TaskPrio, mtxmode: bool) void {
    const oldprio = p_tcb.prio;

    p_tcb.prio = newprio;
    if (isRunnable(p_tcb.tstat)) {
        // タスクが実行できる状態の場合
        p_tcb.task_queue.delete();
        if (ready_queue[oldprio].isEmpty()) {
            ready_primap.clear(oldprio);
        }
        if (mtxmode) {
            ready_queue[newprio].insertNext(&p_tcb.task_queue);
        }
        else {
            ready_queue[newprio].insertPrev(&p_tcb.task_queue);
        }
        ready_primap.set(newprio);

        if (dspflg) {
            if (p_schedtsk == p_tcb) {
                if (newprio >= oldprio) {
                    p_schedtsk = searchSchedtsk();
                }
            }
            else {
                if (newprio <= p_schedtsk.?.prio) {
                    p_schedtsk = getTCBFromQueue(ready_queue[newprio].p_next);
                }
            }
        }
    }
    else {
        if (isWaitingWobjCB(p_tcb.tstat)) {
            // タスクが，同期・通信オブジェクトの管理ブロックの共通部
            // 分（WOBJCB）の待ちキューにつながれている場合
            wobj_change_priority(@fieldParentPtr(WINFO_WOBJ, "winfo",
                                             p_tcb.p_winfo).p_wobjcb, p_tcb);
        }
    }
}

///
///  レディキューの回転
///
///  レディキュー中の，p_queueで指定されるタスクキューを回転させる．ま
///  た，必要な場合には，実行すべきタスクを更新する．
///
pub fn rotate_ready_queue(prio: TaskPrio) void {
    const p_queue = &ready_queue[prio];

    if (!p_queue.isEmpty() and p_queue.p_next.p_next != p_queue) {
        const p_entry = p_queue.deleteNext();
        p_queue.insertPrev(p_entry);
        if (dspflg) {
            if (p_schedtsk == getTCBFromQueue(p_entry)) {
                p_schedtsk = getTCBFromQueue(p_queue.p_next);
            }
        }
    }
}

///
///  タスクの終了処理
///
///  p_tcbで指定されるタスクを終了させる処理を行う．タスクの起動要求
///  キューイング数が0でない場合には，再度起動するための処理を行う．
///
pub fn task_terminate(p_tcb: *TCB) void {
    if (isRunnable(p_tcb.tstat)) {
        make_non_runnable(p_tcb);
    }
    else if (isWaiting(p_tcb.tstat)) {
        wait_dequeue_wobj(p_tcb);
        wait_dequeue_tmevtb(p_tcb);
    }
    if (p_tcb.p_lastmtx != null) {
        mtxhook_release_all.?(p_tcb);
    }
    make_dormant(p_tcb);
    if (p_tcb.flags.actque > 0) {
        p_tcb.flags.actque -= 1;
        make_active(p_tcb);
    }
}

///
///  必要な場合にはタスクディスパッチを行う
///
///  タスクコンテキストから呼ぶ場合はtaskDispatch，非コンテキストから
///  も呼ぶ場合にはrequestTaskDispatchを用いる．
///
pub fn taskDispatch() void {
    if (p_runtsk != p_schedtsk) {
        target_impl.dispatch();
    }
}

pub fn requestTaskDispatch() void {
    if (p_runtsk != p_schedtsk) {
        if (!target_impl.senseContext()) {
            target_impl.dispatch();
        }
        else {
            target_impl.requestDispatchRetint();
        }
    }
}

///
///  タスクの生成（静的APIの処理）
///
pub fn cre_tsk(comptime ctsk: T_CTSK) ItronError!TINIB {
    // tskatrが無効の場合（E_RSATR）［NGKI1028］［NGKI3526］［ASPS0009］
    // ［NGKI1016］
    //（TA_ACT，TA_NOACTQUE，TARGET_TSKATR以外のビットがセットされている場合）
    try checkValidAtr(ctsk.tskatr, TA_ACT|TA_NOACTQUE | TARGET_TSKATR);

    // itskpriが有効範囲外の場合（E_PAR）［NGKI1034］
    //（TMIN_TPRI <= itskpri && itskpri <= TMAX_TPRIでない場合）
    try checkParameter(validTaskPri(ctsk.itskpri));

    // stkszがターゲット定義の最小値（TARGET_MIN_STKSZ，未定義の場合は1）
    // よりも小さい場合（E_PAR）［NGKI1042］
    try checkParameter(ctsk.stksz >= TARGET_MIN_STKSZ);

    // stkszがターゲット定義の制約に合致しない場合（E_PAR）［NGKI1056］
    try checkParameter((ctsk.stksz & (CHECK_STKSZ_ALIGN - 1)) == 0);

    // ターゲット依存のエラーチェック
    if (@hasDecl(target_impl, "checkCreTsk")) {
        try target_impl.checkCreTsk(ctsk);
    }

    // タスクのスタック領域の確保
    //
    // この記述では，タスク毎に別々のスタック領域が割り当てられる保証
    // がない．コンパイラのバージョンが上がると，誤動作する可能性があ
    // る．
    comptime const stksz = TOPPERS_ROUND_SZ(ctsk.stksz, STACK_ALIGN);
    comptime const stk = if (ctsk.stk) |stk| stk
        else &struct {
            var stack: [stksz]u8 align(STACK_ALIGN) = undefined;
        }.stack;

    // タスク初期化ブロックを返す
    return TINIB{ .tskatr = ctsk.tskatr,
                  .exinf = ctsk.exinf,
                  .task = ctsk.task,
                  .ipri = internalTaskPrio(ctsk.itskpri),
                  .tskinictxb = if (@hasDecl(target_impl, "TSKINICTXB"))
                         target_impl.genTskIniCtxB(stksz, stk)
                     else .{ .stksz = stksz, .stk = stk, }, };
}

///
///  タスクに関するコンフィギュレーションデータの生成（静的APIの処理）
///
pub fn ExportTskCfg(tinib_table: []TINIB, torder_table: []ID) type {
    // チェック処理用の定義の生成
    exportCheck(@sizeOf(TINIB), "sizeof_TINIB");
    exportCheck(@sizeOf(TASK), "sizeof_TASK");
    exportCheck(@byteOffsetOf(TINIB, "task"), "offsetof_TINIB_task");
    exportCheck(@byteOffsetOf(TINIB, "tskinictxb")
                    + @byteOffsetOf(@TypeOf(tinib_table[0].tskinictxb), "stk"),
                "offsetof_TINIB_stk");

    const tnum_tsk = tinib_table.len;
    return struct {
        pub export const _kernel_tmax_tskid: ID = tnum_tsk;
        pub export const _kernel_tinib_table = tinib_table[0 .. tnum_tsk].*;
        pub export const _kernel_torder_table = torder_table[0 .. tnum_tsk].*;
        pub export var _kernel_tcb_table: [tnum_tsk]TCB = undefined;
    };
}

///
///  トレースログのためのカーネル情報の取出し関数
///
pub fn getTskId(info: usize) usize {
    var tskid: ID = undefined;

    if (@intToPtr(?*TCB, info)) |p_tcb| {
        tskid = getTskIdFromTCB(p_tcb);
    }
    else {
        tskid = TSK_NONE;
    }
    return @intCast(usize, tskid);
}

pub fn getTskStat(info: usize) usize {
    var tstatstr: [*:0]const u8 = undefined;

    const tstat = @intCast(u8, info);
    if (isDormant(tstat)) {
        tstatstr = "DORMANT";
    }
    else {
        if (isSuspended(tstat)) {
            if (isWaiting(tstat)) {
                tstatstr = "WAITING-SUSPENDED";
            }
            else {
                tstatstr = "SUSPENDED";
            }
        }
        else if (isWaiting(tstat)) {
            tstatstr = "WAITING";
        }
        else {
            tstatstr = "RUNNABLE";
        }
    }
    return @ptrToInt(tstatstr);
}

///
///  カーネルの整合性検査のための関数
///

///
///  TCBへのポインタのチェック
///
pub fn validTCB(p_tcb: *TCB) bool {
    if ((@ptrToInt(p_tcb) - @ptrToInt(&cfg._kernel_tcb_table))
            % @sizeOf(TCB) != 0) {
        return false;
    }
    const tskid = getTskIdFromTCB(p_tcb);
    return TMIN_TSKID <= tskid and tskid <= cfg._kernel_tmax_tskid;
}

///
///  スタック上を指しているかのチェック
///
pub fn onStack(addr: usize, size: usize, p_tinib: *const TINIB) bool {
    if (@hasDecl(target_impl, "onStack")) {
        return target_impl.onStack(addr, size, p_tinib);
    }
    else {
        return @ptrToInt(p_tinib.tskinictxb.stk) <= addr
            and addr + size <= @ptrToInt(&p_tinib.tskinictxb.stk
                                             [p_tinib.tskinictxb.stksz]);
    }
}

///
///  タスクコンテキストブロックのチェック
///
pub fn validTSKCTXB(p_tcb: *TCB) bool {
    if (@hasDecl(target_impl, "validTSKCTXB")) {
        return target_impl.validTSKCTXB(&p_tcb.tskctxb, p_tcb);
    }
    else {
        // spがアラインしているかをチェック
        if ((@ptrToInt(p_tcb.tskctxb.sp) & (CHECK_STACK_ALIGN - 1)) != 0) {
            return false;
        }

        // spがスタック上を指しているかをチェック
        if (!onStack(@ptrToInt(p_tcb.tskctxb.sp), 0, p_tcb.p_tinib)) {
            return false;
        }
        return true;
    }
}

///
///  スケジューリングのためのデータ構造の整合性検査
///
fn bitSched() ItronError!void {
    // p_schedtskの整合性検査
    if (dspflg) {
        if (ready_primap.isEmpty()) {
            try checkBit(p_schedtsk == null);
        }
        else {
            try checkBit(p_schedtsk == searchSchedtsk());
        }
    }

    // ready_primapの整合性検査
    try checkBit(ready_primap.bitCheck());

    // ready_queueとready_primapの整合性の検査
    for (ready_queue) |*p_queue, prio| {
        if (p_queue.isEmpty()) {
            try checkBit(!ready_primap.isSet(@intCast(TaskPrio, prio)));
        }
        else {
            try checkBit(ready_primap.isSet(@intCast(TaskPrio, prio)));
        }

        var p_entry = p_queue.p_next;
        while (p_entry != p_queue) : (p_entry = p_entry.p_next) {
            const p_tcb = getTCBFromQueue(p_entry);
            try checkBit(validTCB(p_tcb));
            try checkBit(isRunnable(p_tcb.tstat));
            try checkBit(p_tcb.prio == prio);
        }
    }
}

///
///  タスク毎の整合性検査
///
fn bitTCB(p_tcb: *TCB) ItronError!void {
    const p_tinib = p_tcb.p_tinib;
    const tstat = p_tcb.tstat;

    // タスク初期化ブロックへのポインタの整合性検査
    try checkBit(p_tinib == getTIniB(getTskIdFromTCB(p_tcb)));

    // tstatの整合性検査
    if (isDormant(tstat)) {
        try checkBit(tstat == TS_DORMANT);
    }
    else if (isWaiting(tstat)) {
        try checkBit((tstat & ~@as(u8, TS_WAITING_MASK | TS_SUSPENDED)) == 0);
    }
    else if (isSuspended(tstat)) {
        try checkBit(tstat == TS_SUSPENDED);
    }
    else {
        try checkBit(tstat == TS_RUNNABLE);
    }

    // ベース優先度の検査
    try checkBit(p_tcb.bprio < TNUM_TPRI);

    // 現在の優先度の検査
    try checkBit(p_tcb.prio <= p_tcb.bprio);

    // rasterと他の状態の整合性検査
    if (p_tcb.flags.raster) {
        try checkBit(!p_tcb.flags.enater);
        try checkBit(!isWaiting(tstat));
    }

    // 休止状態における整合性検査
    if (isDormant(tstat)) {
        try checkBit(p_tcb.bprio == p_tinib.ipri);
        try checkBit(p_tcb.prio == p_tinib.ipri);
        try checkBit(p_tcb.flags.actque == 0);
        try checkBit(p_tcb.flags.wupque == 0);
        try checkBit(p_tcb.flags.raster == false);
        try checkBit(p_tcb.flags.enater == true);
        try checkBit(p_tcb.p_lastmtx == null);
    }

    // 実行できる状態における整合性検査
    if (isRunnable(tstat)) {
        try checkBit(ready_queue[p_tcb.prio].bitIncluded(&p_tcb.task_queue));
    }

    // 待ち状態における整合性検査
    if (isWaiting(tstat)) {
        var winfo_size: usize = undefined;
        if (p_tcb.p_winfo.p_tmevtb) |p_tmevtb| {
            try checkBit(onStack(@ptrToInt(p_tmevtb),
                                 @sizeOf(TMEVTB), p_tinib));
            try checkBit(validTMEVTB(p_tmevtb));
            if ((tstat & TS_WAITING_MASK) != TS_WAITING_DLY) {
                try checkBit(p_tmevtb.callback == wait_tmout);
            }
            else {
                try checkBit(p_tmevtb.callback == wait_tmout_ok);
            }
            try checkBit(p_tmevtb.arg == @ptrToInt(p_tcb));
        }

        switch (tstat & TS_WAITING_MASK) {
            TS_WAITING_SLP => {
                try checkBit(p_tcb.flags.wupque == 0);
                winfo_size = @sizeOf(WINFO);
            },
            TS_WAITING_DLY => {
                try checkBit(p_tcb.p_winfo.p_tmevtb != null);
                winfo_size = @sizeOf(WINFO);
            },
            // ★未完成
            TS_WAITING_MTX => {
                const p_mtxcb = mutex.getWinfoMtx(p_tcb.p_winfo).p_wobjcb;
                try checkBit(mutex.validMTXCB(p_mtxcb));
                try checkBit(p_mtxcb.wait_queue.bitIncluded(&p_tcb.task_queue));
                winfo_size = @sizeOf(mutex.WINFO_MTX);
            },
            // ★未完成
            else => {
//                return ItronError.SystemError;
            }
        }

        try checkBit(onStack(@ptrToInt(p_tcb.p_winfo), winfo_size, p_tinib));
    }

    // p_lastmtxの検査
    if (p_tcb.p_lastmtx) |p_lastmtx| {
        try checkBit(mutex.validMTXCB(p_lastmtx));
    }

    // tskctxbの検査
    if (!isDormant(tstat) and p_tcb != p_runtsk) {
        try checkBit(validTSKCTXB(p_tcb));
    }
}

///
///  タスクに関する整合性検査
///
pub fn bitTask() ItronError!void {
    // スケジューリングのためのデータ構造の整合性検査
    try bitSched();

    // タスク毎の整合性検査
    for (cfg._kernel_tcb_table[0 .. numOfTsk()]) |*p_tcb| {
        try bitTCB(p_tcb);
    }
}
