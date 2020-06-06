///
///  TOPPERS/ASP Kernel
///      Toyohashi Open Platform for Embedded Real-Time Systems/
///      Advanced Standard Profile Kernel
/// 
///  Copyright (C) 2013-2020 by Embedded and Real-Time Systems Laboratory
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
///  カーネルのターゲット依存部（ダミーターゲット用）
///
usingnamespace @import("../../kernel/kernel_impl.zig");

///
///  コンフィギュレーションオプションの取り込み
///
const TOPPERS_OMIT_TECS = option.TOPPERS_OMIT_TECS;

///
///  ターゲットシステムのハードウェア資源の定義
///
const dummy = @import("dummy.zig");

///
///  エラーチェック方法の指定
///
pub const CHECK_STKSZ_ALIGN = 4;         // スタックサイズのアライン単位
pub const CHECK_INTPTR_ALIGN = 4;        // intptr_t型の変数のアライン単位
pub const CHECK_INTPTR_NONNULL = true;  // intptr_t型の変数の非NULLチェック
pub const CHECK_FUNC_ALIGN = 4;         // 関数のアライン単位
pub const CHECK_FUNC_NONNULL = true;    // 関数の非NULLチェック
pub const CHECK_STACK_ALIGN = 4;        // スタック領域のアライン単位
pub const CHECK_STACK_NONNULL = true;   // スタック領域の非NULLチェック
pub const CHECK_MPF_ALIGN = 4;          // 固定長メモリプール領域のアライン単位
pub const CHECK_MPF_NONNULL = true; // 固定長メモリプール領域の非NULLチェック
pub const CHECK_MPK_ALIGN = 4;      // カーネルメモリプール領域のアライン単位
pub const CHECK_MPK_NONNULL = true; // カーネルメモリプール領域の非NULLチェック
pub const CHECK_MB_ALIGN = 4;       // 管理領域のアライン単位

///
///  非タスクコンテキスト用スタックのデフォルトのサイズ
///
pub const DEFAULT_ISTKSZ = 4096;

///
///  タスクコンテキストブロックの定義
///
pub const TSKCTXB = struct {
    sp: *u8,            // スタックポインタ
    pc: FP,             // 実行再開番地
};

///
///  スタックの初期値
///
fn stkpt(p_tinib: *const task.TINIB) *u8 {
    return &p_tinib.tskinictxb.stk[p_tinib.tskinictxb.stksz];
}

///
///  コンテキストの参照
///
pub fn senseContext() bool { return false; }

///
///  CPUロック状態への遷移
///
pub fn lockCpu() void {}

///
///  CPUロック状態への移行（ディスパッチできる状態）
///
pub const lockCpuDsp = lockCpu;

///
///  CPUロック状態の解除
///
pub fn unlockCpu() void {}

///
///  CPUロック状態の解除（ディスパッチできる状態）
///
pub const unlockCpuDsp = unlockCpu;

///
///  CPUロック状態の参照
///
pub fn senseLock() bool { return false; }

///
///  割込みを受け付けるための遅延処理
///
pub fn delayForInterrupt() void {}

///
///  割込み優先度マスクの設定
///
pub fn setIpm(intpri: PRI) void {}

///
///  割込み優先度マスクの参照
///
pub fn getIpm() PRI { return TIPM_ENAALL; }

///
///  割込み番号の範囲の判定
///
pub fn validIntno(intno: INTNO) bool {
    return 0 <= intno and intno <= 31;
}

///
///  割込みハンドラ番号の範囲の判定
///
pub const validInhno = validIntno;

///
///  割込み属性の設定のチェック
///
pub fn checkIntnoCfg(intno: INTNO) bool { return true; }

///
///  割込み要求禁止フラグのセット
///
pub fn disableInt(intno: INTNO) void {}

///
///  割込み要求禁止フラグのクリア
///
pub fn enableInt(intno: INTNO) void {}

///
///  割込み要求がクリアできる状態か？
///
pub fn checkIntnoClear(intno: INTNO) bool { return true; }

///
///  割込み要求のクリア
///
pub fn clearInt(intno: INTNO) void {}

///
///  割込みが要求できる状態か？
///
pub fn checkIntnoRaise(intno: INTNO) bool { return true; }

///
///  割込みの要求
///
pub fn raiseInt(intno: INTNO) void {}

///
///  割込み要求のチェック
///
pub fn probeInt(intno: INTNO) bool { return true; }

///
///  最高優先順位タスクへのディスパッチ
///
pub noinline fn dispatch() void {
    if (comptime TOPPERS_SUPPORT_OVRHDR) {
        overrun.overrun_stop();
    }
    // スクラッチレジスタを除くすべてのレジスタをスタックに保存する
    // スタックポインタを自タスク（p_runtsk）のTCBに保存する
    // dispatch_rを，実行再開番地として自タスクのTCBに保存する
    dispatcher();

//  dispatch_r:
    // スクラッチレジスタを除くすべてのレジスタをスタックから復帰する
    if (TOPPERS_SUPPORT_OVRHDR) {
        overrun.overrun_start();
    }
}

///
///  非タスクコンテキストからのディスパッチ要求
///
pub fn requestDispatchRetint() void {}

///
///  ディスパッチャの動作開始
///
pub fn startDispatch() noreturn {
    // タスクコンテキストに切り換える
    // CPUロック状態にする
    // IDが1のタスクのスタック領域に切り換える
    // dispatcher_0に分岐する
    unreachable;
}

///
///  現在のコンテキストを捨ててディスパッチ
///
pub fn exitAndDispatch() noreturn {
    // dispatcherに分岐する
    unreachable;
}

///
///  ディスパッチャ本体
///
fn dispatcher() void {
    traceLog("dispatchEnter", .{ task.p_runtsk.? });

//  dispatcher_0:
    task.p_runtsk = task.p_schedtsk;
    if (task.p_runtsk != null) {
        // 自タスク（p_runtsk）のTCBからスタックポインタを復帰する
        traceLog("dispatchLeave", .{ task.p_runtsk.? });
        // 自タスクのTCBから実行再開番地を復帰し，そこへ分岐する
    }

    //
    // アイドル処理
    //
    // 割込みを許可したらCPUロック解除状態になるよう準備する
    // 割込みをすべて許可する
    //
    while (true) {
        if (@hasDecl(target_impl, "CUSTOM_IDLE")
                and target_impl.CUSTOM_IDLE != null) {
            CUSTOM_IDLE();
        }
        else {
            // 割込み発生を待つ
        }
    }
}

///
///  ディスパッチャの動作開始
///
fn start_dispatch() void {
    // タスクコンテキストに切り換える
    // スタックをIDが1のタスクのスタック領域に切り換える
    // CPUロック状態・割込み優先度マスク全解除状態にする
    // dispatcher_0に分岐する
}

///
///  割込みハンドラ出入口処理
///
pub fn int_handler_entry() void {}

///
///  CPU例外ハンドラ出入口処理
///
pub fn exc_handler_entry() void {}

///
///  カーネルの終了処理の呼出し
///
pub fn callExitKernel() noreturn {
    // 非タスクコンテキストに切り換える
    startup.exitKernel();
}

///
///  タスク開始時処理
///
fn start_r() callconv(.C) noreturn {
    if (TOPPERS_SUPPORT_OVRHDR) {
        ovrtimer_start();
    }
    // CPUロック解除状態にする
    // 自タスク（p_runtsk）の起動番地を，拡張情報をパラメータとして呼
    // び出す
    // ext_tskに分岐する
    unreachable;
}

///
///  タスクコンテキストの初期化
///
pub fn activateContext(p_tcb: *task.TCB) void {
    // 指定されたタスク（p_tcb）のTCB中のスタックポインタを初期化する
    // start_rを，実行再開番地として自タスクのTCBに保存する
    p_tcb.tskctxb.sp = stkpt(p_tcb.p_tinib);
    p_tcb.tskctxb.pc = start_r;
}

///
///  割込みハンドラの設定
///
///  割込みハンドラ番号inhnoの割込みハンドラの番地をinthdrに設定する．
///
pub fn define_inh(inhno: INHNO, inhatr: ATR, inthdr: INTHDR) void {}

///
///  割込み要求ライン属性の設定
///
pub fn config_int(intno: INTNO, intatr: ATR, intpri: PRI) void {}

///
///  CPU例外ハンドラの設定
///
///  CPU例外ハンドラ番号excnoのCPU例外ハンドラの番地をexchdrに設定する．
///
pub fn define_exc(excno: EXCNO, excatr: ATR, xchdr: EXCHDR) void {}

///
///  CPU例外の発生した時のコンテキストと割込みのマスク状態の参照
///
///  CPU例外の発生した時のシステム状態が，カーネル内のクリティカルセク
///  ションの実行中でなく，全割込みロック状態でなく，CPUロック状態でな
///  く，カーネル管理外の割込みハンドラ実行中でなく，カーネル管理外の
///  CPU例外ハンドラ実行中でなく，タスクコンテキストであり，割込み優先
///  度マスクが全解除である時にtrue，そうでない時にfalseを返す．
///
pub fn exc_sense_intmask(p_excinf: *c_void) bool { return true; }

///
///  システムログの低レベル出力のための初期化
///
///  セルタイプtPutLogSIOPort内に実装されている関数を直接呼び出す．
///
extern fn tPutLogSIOPort_initialize() void;

///
///  ターゲットシステム依存の初期化
///
pub fn initialize() void {
    // SIOを初期化
    if (!TOPPERS_OMIT_TECS) {
        tPutLogSIOPort_initialize();
    }
}

///
///  ターゲット依存の終了処理
///
extern fn software_term_hook() void;

pub fn exit() noreturn {
    // software_term_hookの呼び出し
    // 最適化の抑止のために，インラインアセンブラを使っている．
    if (asm("" : [_]"=r"(-> u32) : [_]"0"(software_term_hook)) != 0) {
        software_term_hook();
    }

    while (true) {}
}

///
///  ターゲット依存部からexportする関数
///
pub const ExportDefs = struct {
    ///
    ///  スタートアップモジュール
    ///
    export fn _start() void {
        startup.sta_ker();
    }

    ///
    ///  リンクエラーを防ぐための定義
    ///
    export fn software_term_hook() void {}
};
