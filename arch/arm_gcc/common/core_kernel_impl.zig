///
///  TOPPERS/ASP Kernel
///      Toyohashi Open Platform for Embedded Real-Time Systems/
///      Advanced Standard Profile Kernel
/// 
///  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
///                                 Toyohashi Univ. of Technology, JAPAN
///  Copyright (C) 2006-2020 by Embedded and Real-Time Systems Laboratory
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
///  kernel_impl.zigのコア依存部（ARM用）
///
usingnamespace @import("../../../kernel/kernel_impl.zig");

///
///  コンフィギュレーションオプションの取り込み
///
const OMIT_XLOG_SYS = option.target.OMIT_XLOG_SYS;
const USE_ARM_MMU = option.target.USE_ARM_MMU;
const USE_ARM_SSECTION = option.target.USE_ARM_SSECTION;
const USE_ARM_FPU = option.target.USE_ARM_FPU;
const USE_ARM_FPU_D32 = option.target.USE_ARM_FPU_D32;
const USE_ARM_PMCNT = option.target.USE_ARM_PMCNT;
const USE_ARM_PMCNT_DIV64 = option.target.USE_ARM_PMCNT_DIV64;
const TNUM_INHNO = option.target.TNUM_INHNO;
const TNUM_INTNO = option.target.TNUM_INTNO;
const LOG_INH_ENTER = @hasDecl(option.log, "interruptHandlerEnter");
const LOG_INH_LEAVE = @hasDecl(option.log, "interruptHandlerLeave");
const LOG_EXC_ENTER = @hasDecl(option.log, "exceptionHandlerEnter");
const LOG_EXC_LEAVE = @hasDecl(option.log, "exceptionHandlerLeave");
const LOG_DSP_ENTER = @hasDecl(option.log, "dispatchEnter");
const LOG_DSP_LEAVE = @hasDecl(option.log, "dispatchLeave");

///
///  用いるライブラリ
///
const arm = @import("arm.zig");

///
///  ターゲット依存のタスク属性（エラーチェック用）
///
pub const TARGET_TSKATR = if (USE_ARM_FPU) TA_FPU else 0;

///
///  エラーチェック方法の指定
///
pub const CHECK_STKSZ_ALIGN = 8;        // スタックサイズのアライン単位
pub const CHECK_USIZE_ALIGN = 4;        // usize型の変数のアライン単位
pub const CHECK_USIZE_NONNULL = true;   // usize型の変数の非NULLチェック
pub const CHECK_FUNC_ALIGN = 4;         // 関数のアライン単位
pub const CHECK_FUNC_NONNULL = true;    // 関数の非NULLチェック
pub const CHECK_STACK_ALIGN = 8;        // スタック領域のアライン単位
pub const CHECK_STACK_NONNULL = true;   // スタック領域の非NULLチェック
pub const CHECK_MPF_ALIGN = 4;          // 固定長メモリプール領域のアライン単位
pub const CHECK_MPF_NONNULL = true;     // 固定長メモリプール領域の
                                        //                   非NULLチェック
pub const CHECK_MB_ALIGN = 4;           // 管理領域のアライン単位

///
///  コンテキストの参照
///
///  ARM依存部では，タスクコンテキストと非タスクコンテキストの両方をスー
///  パバイザモードで動作させるため，プロセッサモードで判断することが
///  できない．そのため，割込みハンドラ／CPU例外ハンドラのネスト段数
///  （これを，例外ネストカウントと呼ぶ）で管理し，例外ネストカウント
///  が0の時にタスクコンテキスト，0より大きい場合に非タスクコンテキス
///  トであると判断する．
///

///
///  コンテキスト参照のための変数
///
var excpt_nest_count: u32 = undefined;     // 例外ネストカウント

///
///  コンテキストの参照
///
pub fn senseContext() bool {
    return excpt_nest_count > 0;
}

///
///  TOPPERS標準割込み処理モデルの実現
///
///  ARMコア依存部では，割込みの扱いに関して，次の2つの方法をサポート
///  する．
///
///  (1) カーネルを単体で使用する場合やSafeGのノンセキュアモードで使用
///  する場合：IRQをカーネル管理の割込み，FIQをカーネル管理外の割込み
///  とする．デフォルトでは，この方法が使用される．
///
///  (2) SafeGのセキュアモードで使用する場合：FIQをカーネル管理の割込
///  みとし，カーネルの動作中はIRQを常にマスクする．この方法を使用する
///  場合には，TOPPERS_SAFEG_SECUREをマクロ定義する（★現時点では未サ
///  ポート）．
/// 
///  TOPPERS標準割込み処理モデルの中で，割込み優先度マスクと割込み要求
///  禁止フラグに関しては，割込みコントローラによって実現方法が異なる
///  ため，ARMコア依存部では扱わない．
///

// CPUロック・割込みロックでない状態でのCPSRのビットパターン
const CPSR_UNLOCK = 0x00;

// CPUロック状態でのCPSRのビットパターン
const CPSR_CPULOCK = arm.CPSR_IRQ_BIT;

//  割込みロック状態でのCPSRのビットパターン
const CPSR_INTLOCK = arm.CPSR_FIQ_IRQ_BIT;

///
///  CPUロック状態への遷移
///
pub fn lockCpu() void {
    if (comptime !arm.isEnabled(arm.Feature.has_v6)) {
        arm.set_cpsr(arm.current_cpsr() | CPSR_CPULOCK);
    }
    else {
        arm.disable_irq();
    }
    // メモリ参照が，この関数を超えて最適化されることを抑止
    arm.memory_changed();
}

///
///  CPUロック状態への移行（ディスパッチできる状態）
///
pub const lockCpuDsp = lockCpu;

///
///  CPUロック状態の解除
///
pub fn unlockCpu() void {
    // メモリ参照が，この関数を超えて最適化されることを抑止
    arm.memory_changed();
    if (comptime !arm.isEnabled(arm.Feature.has_v6)) {
        arm.set_cpsr((arm.current_cpsr() & ~@as(u32, arm.CPSR_INT_MASK))
                                                            | CPSR_UNLOCK);
    }
    else {
        arm.enable_irq();
    }
}

///
///  CPUロック状態の解除（ディスパッチできる状態）
///
pub const unlockCpuDsp = unlockCpu;

///
///  CPUロック状態の参照
///
pub fn senseLock() bool {
    return (arm.current_cpsr() & arm.CPSR_IRQ_BIT) != 0;
}

///
///  割込みを受け付けるための遅延処理
///
pub fn delayForInterrupt() void {}

///
///  タスクコンテキストブロック
///
pub const TSKCTXB = struct {
    sp: *u8,                            // スタックポインタ
    pc: fn() callconv(.Naked) void,     // 実行再開番地
};

///
///  スタックの初期値
///
fn stkpt(p_tinib: *const task.TINIB) *u8 {
    return &p_tinib.tskinictxb.stk[p_tinib.tskinictxb.stksz];
}

///
///  インラインアセンブラ中での数字ラベルの使い方
///
///  1:	ローカルな分岐先
///  2:	p_runtsk
///  3:	p_schedtsk
///  4: excpt_nest_count
///  5: _kernel_istkpt
///  6: _kernel_inh_table
///  7: _kernel_exc_table
///

///
///  最高優先順位タスクへのディスパッチ
///
///  dispatchは，タスクコンテキストから呼び出されたサービスコール処理
///  から呼び出すべきもので，タスクコンテキスト・CPUロック状態・ディス
///  パッチ許可状態・（モデル上の）割込み優先度マスク全解除状態で呼び
///  出さなければならない．
///
pub noinline fn dispatch() void {
    if (comptime TOPPERS_SUPPORT_OVRHDR) {
        overrun.overrun_stop();
    }
    asm volatile(
        (if (comptime USE_ARM_FPU)
     \\  ldr r2, [r0,%[tcb_p_tinib]]    // p_runtsk.p_tinib → r2
     \\  ldr r1, [r2,%[tinib_tskatr]]   // p_runtsk.p_tinib.tskatr → r1
     \\  tst r1, %[ta_fpu]
     \\  beq 1f
     \\  vpush {d8-d15}                 // 非スクラッチFPUレジスタの保存
     \\ 1:
        else "") ++ "\n" ++
     \\  str sp, [r0,%[tcb_sp]]         // スタックポインタを保存
     \\  adr r1, dispatch_r
     \\  str r1, [r0,%[tcb_pc]]         // 実行再開番地を保存
     \\  b dispatcher                   // r0にはp_runtskが格納されている
     \\
     \\ dispatch_r:
        ++ "\n" ++
        (if (comptime USE_ARM_FPU)
     \\  ldr r2, [r4,%[tcb_p_tinib]]    // p_runtsk.p_tinib → r2
     \\  ldr r1, [r2,%[tinib_tskatr]]   // p_runtsk.p_tinib.tskatr → r1
     \\  tst r1, %[ta_fpu]
     \\  vmrs r0, fpexc
     \\  biceq r0, r0, %[fpexc_enable]
     \\  orrne r0, r0, %[fpexc_enable]
     \\  vmsr fpexc, r0                 // FPEXCを設定
     \\  beq 1f
     \\  vpop {d8-d15}                  // 非スクラッチFPUレジスタの復帰
     \\ 1:
        else "")
     :
     : [p_selftsk] "{r0}" (task.p_runtsk.?),
       [tcb_p_tinib] "J" (@as(i16, @byteOffsetOf(task.TCB, "p_tinib"))),
       [tinib_tskatr] "J" (@as(i16, @byteOffsetOf(task.TINIB, "tskatr"))),
       [tcb_sp] "J" (@as(i16, @byteOffsetOf(task.TCB, "tskctxb")
                             + @byteOffsetOf(TSKCTXB, "sp"))),
       [tcb_pc] "J" (@as(i16, @byteOffsetOf(task.TCB, "tskctxb")
                             + @byteOffsetOf(TSKCTXB, "pc"))),
       [ta_fpu] "n" (@as(u32, TA_FPU)),
       [fpexc_enable] "n" (@as(u32, arm.FPEXC_ENABLE)),
       [dispatcher] "s" (dispatcher),
     : "r0","r1","r2","r3","r4","r5","r6","r7",
       "r8","r9","r10","r11","r12","lr","memory","cc"
    );
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
///  startDispatchは，カーネル起動時に呼び出すべきもので，すべての割込
///  みを禁止した状態（割込みロック状態と同等の状態）で呼び出さなけれ
///  ばならない．
///
///  dispatcher_0へ分岐する前に，タスクコンテキスト・CPUロック状態・割
///  込み優先度マスク全解除状態にし，使用するスタックを，IDが1のタスク
///  のスタック領域に切り換えなければならない．
///
pub fn startDispatch() noreturn {
    // 各種のデバイス（特に割込みコントローラ）の設定が完了するのを待
    // つ．
    arm.data_sync_barrier();

    // タスクコンテキストに切り換える（例外ネストカウントを0にする）．
    excpt_nest_count = 0;

    // CPUロック状態にする．
    arm.set_cpsr(arm.CPSR_SVC_MODE | CPSR_CPULOCK);

    // IDが1のタスクのスタック領域に切り換え，ディスパッチャ本体へ．
    asm volatile(
     \\  b dispatcher_0
     :
     : [stkpt] "{sp}" (stkpt(task.getTIniB(1))),
       [dispatcher] "s" (dispatcher),
    );
    unreachable;
}

///
///  現在のコンテキストを捨ててディスパッチ
///
///  exitAndDispatchは，ext_tskから呼び出すべきもので，タスクコンテキ
///  スト・CPUロック状態・ディスパッチ許可状態・（モデル上の）割込み優
///  先度マスク全解除状態で呼び出さなければならない．
///
pub fn exitAndDispatch() noreturn {
    // ディスパッチャ本体へ．
    asm volatile(
     \\  b dispatcher                   // r0にはp_runtskが格納されている
     :
     : [p_selftsk] "{r0}" (task.p_runtsk.?),
       [dispatcher] "s" (dispatcher),
    );
    unreachable;
}

//
//  ディスパッチャ本体
//
fn dispatcher() callconv(.Naked) void {
    asm volatile(
     \\ dispatcher:
        ++ "\n" ++
        (if (LOG_DSP_ENTER)
     \\ // 【この時点のレジスタ状態】
     \\ //  r0：p_runtsk（タスク切換え前）
     \\  bl _kernel_log_dsp_enter
        else "") ++ "\n" ++
     \\
     \\ dispatcher_0:
     \\ // このルーチンは，タスクコンテキスト・CPUロック状態・割込
     \\ // み優先度マスク全解除状態・ディスパッチ許可状態で呼び出さ
     \\ // れる．実行再開番地へもこの状態のまま分岐する．
     \\  ldr r0, 3f                     // p_schedtsk → r4 → p_runtsk
     \\  ldr r4, [r0]
     \\  ldr r1, 2f
     \\  str r4, [r1]
     \\  tst r4, r4                     // p_runtskがNULLならdispatcher_1へ
     \\  beq dispatcher_1
     \\  ldr sp, [r4,%[tcb_sp]]         // タスクスタックを復帰
        ++ "\n" ++
        (if (LOG_DSP_LEAVE)
     \\  mov r0, r4                     // p_runtskをパラメータに渡す
     \\  bl _kernel_log_dsp_leave
        else "") ++ "\n" ++
     \\  ldr r0, [r4,%[tcb_pc]]         // 実行再開番地を復帰
     \\  bx r0                          // p_runtskをr4に入れた状態で分岐する
     \\
     \\ // アイドル処理
     \\ //
     \\ // 割込みをすべて許可し，CPUロック解除状態にして割込みを待
     \\ // つ．
     \\ //
     \\ // ターゲットによっては，省電力モード等に移行するため，標準
     \\ // の方法と異なる手順が必要な場合がある．そのようなターゲッ
     \\ // トでは，ターゲット依存部でCUSTOM_IDLEを定義すればよい．
     \\ dispatcher_1:
        ++ "\n" ++
        (if (@hasDecl(target_impl, "CUSTOM_IDLE"))
        target_impl.CUSTOM_IDLE
        else
     \\  msr cpsr_c, %[cpsr_svc_unlock] // 割込みを許可（スーパバイザモード）
        ) ++ "\n" ++
     \\  b dispatcher_1                 // 割込み待ち
     \\ 2:
     \\  .long %[p_runtsk]
     \\ 3:
     \\  .long %[p_schedtsk]
     :
     : [tcb_sp] "J" (@as(i16, @byteOffsetOf(task.TCB, "tskctxb")
                             + @byteOffsetOf(TSKCTXB, "sp"))),
       [tcb_pc] "J" (@as(i16, @byteOffsetOf(task.TCB, "tskctxb")
                             + @byteOffsetOf(TSKCTXB, "pc"))),
       [cpsr_svc_unlock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_UNLOCK)),
       [p_runtsk] "s" (&task.p_runtsk),
       [p_schedtsk] "s" (&task.p_schedtsk),
    );
    unreachable;
}

//
//  タスクの実行開始時処理
//
fn start_r() callconv(.Naked) noreturn {
    // 【この時点のレジスタ状態】
    // r4：p_runtsk（タスク切換え後）
    asm volatile(
        (if (TOPPERS_SUPPORT_OVRHDR)
     \\  bl _kernel_overrun_start
        else "") ++ "\n" ++
     \\  msr cpsr_c, %[cpsr_svc_unlock] // CPUロック解除状態に
     \\  ldr lr, _ext_tsk               // タスク本体からの戻り番地を設定
     \\  ldr r2, [r4,%[tcb_p_tinib]]    // p_runtsk.p_tinib → r2
        ++ "\n" ++
        (if (USE_ARM_FPU)
     \\  ldr r1, [r2,%[tinib_tskatr]]   // p_runtsk.p_tinib.tskatr → r1
     \\  tst r1, %[ta_fpu]
     \\  vmrs r0, fpexc
     \\  biceq r0, r0, %[fpexc_enable]
     \\  orrne r0, r0, %[fpexc_enable]
     \\  vmsr fpexc, r0                 // FPEXCを設定
        else "") ++ "\n" ++
     \\  ldr r0, [r2,%[tinib_exinf]]    // exinfをパラメータに
     \\  ldr r1, [r2,%[tinib_task]]     // タスク起動番地にジャンプ
     \\  bx r1
     \\ _ext_tsk:
     \\  .long %[ext_tsk]
     :
     : [cpsr_svc_unlock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_UNLOCK)),
       [ext_tsk] "s" (task_term.ext_tsk),
       [tcb_p_tinib] "J" (@as(i16, @byteOffsetOf(task.TCB, "p_tinib"))),
       [tinib_tskatr] "J" (@as(i16, @byteOffsetOf(task.TINIB, "tskatr"))),
       [tinib_exinf] "J" (@as(i16, @byteOffsetOf(task.TINIB, "exinf"))),
       [tinib_task] "J" (@as(i16, @byteOffsetOf(task.TINIB, "task"))),
       [ta_fpu] "n" (@as(u32, TA_FPU)),
       [fpexc_enable] "n" (@as(u32, arm.FPEXC_ENABLE)),
    );
    unreachable;
}

///
///  カーネルの終了処理の呼出し
///
///  call_exit_kernelは，カーネルの終了時に呼び出すべきもので，非タス
///  クコンテキストに切り換えて，カーネルの終了処理（exit_kernel）へ分
///  岐する．
pub fn call_exit_kernel() noreturn {
    // 例外ネストカウントを1にする．
    excpt_nest_count = 1;

    // 非タスクコンテキスト用のスタック領域に切り換え，exit_kernelに分
    // 岐する．
    asm volatile(
     \\  ldr sp, 5f
     \\  ldr sp, [sp]
     \\  b %[exit_kernel]
     \\ 5:
     \\  .long _kernel_istkpt
     :
     : [exit_kernel] "s" (startup.exit_kernel),
    );
    unreachable;
}

///
///  タスクコンテキストの初期化
///
///  タスクが休止状態から実行できる状態に遷移する時に呼ばれる．この時
///  点でスタック領域を使ってはならない．
///
pub fn activateContext(p_tcb: *task.TCB) void {
    p_tcb.tskctxb.sp = stkpt(p_tcb.p_tinib);
    p_tcb.tskctxb.pc = start_r;
}

///
///  割込みハンドラテーブルの取り込み
///
pub const ExternInhIniB = struct {
    ///
    ///  割込みハンドラテーブル
    ///
    extern const _kernel_inh_table: [TNUM_INHNO]INTHDR;
};

///
///  割込み要求ライン初期化ブロックの取り込み
///
pub const ExternIntIniB = struct {
    ///
    ///  設定する割込み要求ラインの数
    ///
    extern const _kernel_tnum_cfg_intno: c_uint;

    ///
    ///  割込み要求ライン初期化ブロックのエリア
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    extern const _kernel_intinib_table: [100]interrupt.INTINIB;

    ///
    ///  割込み要求ライン設定テーブル
    ///
    extern const _kernel_intcfg_table: [TNUM_INTNO]bool;
};

///
///  割込みハンドラテーブルの生成（静的APIの処理）
///
extern fn _kernel_default_int_handler() void;

pub fn ExportInhIniB(inhinib_list: []interrupt.INHINIB) type {
    // チェック処理用の定義の生成
    exportCheck(TNUM_INHNO, "TNUM_INHNO");
    exportCheck(@sizeOf(INTHDR), "sizeof_INTHDR");

    comptime var inh_table = [1]INTHDR{ _kernel_default_int_handler }
                                                        ** TNUM_INHNO;
    for (inhinib_list) |inhinib| {
        inh_table[inhinib.inhno] = inhinib.inthdr;
    }
    return struct {
        pub export const _kernel_inh_table = inh_table;
    };
}

///
///  割込み要求ライン初期化ブロックの生成（静的APIの処理）
///

// 割込み要求ライン初期化ブロック
fn ExportIniB(intinib_list: []interrupt.INTINIB) type {
    return struct {
        pub export const _kernel_tnum_cfg_intno: c_uint = intinib_list.len;
        pub export const _kernel_intinib_table = intinib_list
                                                [0 .. intinib_list.len].*;
    };
}

// 割込み要求ライン設定テーブル
fn ExportCfg(intinib_list: []interrupt.INTINIB) type {
    comptime var intcfg_table = [1]bool{ false } ** TNUM_INTNO;
    for (intinib_list) |intinib| {
        intcfg_table[intinib.intno] = true;
    }
    return struct {
        pub export const _kernel_intcfg_table = intcfg_table;
    };
}

pub fn ExportIntIniB(intinib_list: []interrupt.INTINIB) type {
    return struct {
        usingnamespace if (@hasDecl(target_impl, "USE_INTINIB_TABLE")
                               and target_impl.USE_INTINIB_TABLE)
            ExportIniB(intinib_list) else struct {};
        usingnamespace if (@hasDecl(target_impl, "USE_INTCFG_TABLE")
                               and target_impl.USE_INTCFG_TABLE)
            ExportCfg(intinib_list) else struct {};
    };
}

///
///  割込み要求ライン設定テーブルの生成（静的APIの処理）
///

//
//  割込みハンドラの出入口処理
//
fn irq_handler() callconv(.Naked) void {
    asm volatile(
     \\ irq_handler:
     \\ // ここには，IRQモードで分岐してくる．
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\ // スーパバイザモードに切り換え，スクラッチレジスタ＋αを保存する．
     \\  msr cpsr_c, %[cpsr_svc_cpulock]
     \\  push {r0-r5,r12,lr,pc}         // pcはスペース確保のため
     \\
     \\ // IRQモードに戻して，戻り番地（lr−4）と戻り先のcpsr（spsr）
     \\ // を取得する．
     \\  msr cpsr_c, %[cpsr_irq_cpulock]
     \\  sub r2, lr, #4
     \\  mrs r1, spsr
     \\
     \\ // スーパバイザモードに切り換え，戻り番地と戻り先のcpsrを保
     \\ // 存する．
     \\  msr cpsr_c, %[cpsr_svc_cpulock]
     \\  str r2, [sp,#0x20]             // 戻り番地をスタックに保存（pcの場所）
     \\  push {r1}                      // 戻り先のcpsrをスタックに保存
        else
     \\ // 戻り番地（lr）と戻り先のcpsr（spsr）をスーパバイザモード
     \\ // のスタックに保存する．
     \\  sub lr, lr, #4                 // 戻り番地の算出
     \\  srsfd %[cpsr_svc]!
     \\
     \\ // スーパバイザモードに切り換え，スクラッチレジスタ＋αを保
     \\ // 存する．
     \\  cps %[cpsr_svc]
     \\  push {r0-r5,r12,lr}
        ) ++ "\n" ++
     \\
     \\ // スタックポインタの調整
     \\  and r1, sp, #4
     \\  sub sp, sp, r1
     \\  push {r0,r1}                   // スタックポインタの調整値を保存
     \\                                 // r0はスペース確保のため
     \\ // 例外ネストカウントをインクリメントする．割込みが非タスク
     \\ // コンテキストで発生した場合には，irq_handler_1へ分岐する．
     \\  ldr r2, 4f
     \\  ldr r3, [r2]
     \\  add r3, r3, #1
     \\  str r3, [r2]
     \\  teq r3, #1                     // 割込みが非タスクコンテキストで発生
     \\  bne irq_handler_1              //            ならirq_handler_1に分岐
     \\
        ++ "\n" ++
        (if (TOPPERS_SUPPORT_OVRHDR)
     \\  bl _kernel_overrun_stop
        else "") ++ "\n" ++
        (if (USE_ARM_FPU)
     \\ // FPUをディスエーブルする．
     \\  vmrs r0, fpexc
     \\  str r0, [sp]                   // FPEXCを保存（r0の場所）*/
     \\  bic r0, r0, %[fpexc_enable]
     \\  vmsr fpexc, r0                 // FPEXCを設定
        else "") ++ "\n" ++
     \\ 
     \\ // 非タスクコンテキスト用のスタックに切り換える．
     \\  mov r3, sp                     // この時点のスタックポインタをr3に
     \\  ldr r2, 5f                     // 非タスクコンテキスト用のスタックに
     \\  ldr sp, [r2]
     \\  push {r0,r3}                   // 切換え前のスタックポインタを保存
     \\                                 // r0はスペース確保のため
     \\ irq_handler_1:
     \\ // 割込みコントローラを操作し，割込み番号を取得する．
     \\ //
     \\ // irc_begin_intは，スタックトップ（r0の場所）に，irc_end_int
     \\ // で用いる情報を保存する．
     \\  bl irc_begin_int
        ++ "\n" ++
        (if (comptime TNUM_INHNO <= 256 or !arm.isEnabled(arm.Feature.has_v7))
     \\  cmp r4, %[tnum_inhno]          // TNUM_INHNOの値によってはエラーになる
        else
     \\  movw r3, %[tnum_inhno]
     \\  cmp r4, r3
        ) ++ "\n" ++
     \\  bhs irq_handler_2              // スプリアス割込みなら
     \\                                 //  irq_handler_2に分岐
     \\ // CPUロック解除状態にする．
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\  msr cpsr_c, %[cpsr_svc_unlock]
        else
     \\  cpsie if
        ) ++ "\n" ++
     \\
        ++ "\n" ++
        (if (LOG_INH_ENTER)
     \\ // ログ出力の呼出し
     \\  mov r0, r4                     // 割込み番号をパラメータに渡す
     \\  bl _kernel_log_inh_enter
        else "") ++ "\n" ++
     \\
     \\ // 割込みハンドラの呼出し
     \\  ldr r2, 6f                     // 割込みハンドラテーブルの読込み
     \\  ldr r1, [r2,r4,lsl #2]         // 割込みハンドラの番地 → r1
     \\  mov lr, pc                     // 割込みハンドラの呼出し
     \\  bx r1
     \\
        ++ "\n" ++
        (if (LOG_INH_LEAVE)
     \\ // ログ出力の呼出し
     \\  mov r0, r4                     // 割込み番号をパラメータに渡す
     \\  bl _kernel_log_inh_leave
        else "") ++ "\n" ++
     \\
     \\ // カーネル管理の割込みを禁止する．
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\  msr cpsr_c, %[cpsr_svc_cpulock]
        else
     \\  cpsid i
        ) ++ "\n" ++
     \\
     \\ // 割込みコントローラを操作する．
     \\ irq_handler_2:
     \\  bl irc_end_int
     \\
     \\ // 例外ネストカウントをデクリメントする．
     \\  ldr r2, 4f
     \\  ldr r3, [r2]
     \\  subs r3, r3, #1
     \\  str r3, [r2]                   // 戻り先が非タスクコンテキストなら
     \\  bne irq_handler_5              // irq_handler_5に分岐
     \\
     \\ // タスク用のスタックに戻す．
     \\  pop {r0,r3}
     \\  mov sp, r3
     \\
        ++ "\n" ++
        (if (USE_ARM_FPU)
     \\ // FPUを元に戻す．
     \\  ldr r0, [sp]                   // FPEXCを復帰
     \\  vmsr fpexc, r0
        else "") ++ "\n" ++
     \\
     \\ // p_runtskがNULLか判定する．
     \\  ldr r0, 2f                     // p_runtsk → r0
     \\  ldr r0, [r0]
     \\  tst r0, r0                     // p_runtskがNULLでなければ
     \\  bne irq_handler_3              // irq_handler_3に分岐
     \\
     \\ // タスクのスタックに保存したスクラッチレジスタ等を捨てる．
     \\  pop {r0,r1}                    // スタックポインタの調整を元に戻す
     \\  add sp, sp, r1
     \\  add sp, sp, #40                // スクラッチレジスタ等を捨てる
     \\  b dispatcher_0
     \\
     \\ // ディスパッチが必要か判定する．
     \\ irq_handler_3:
     \\ // 【この時点のレジスタ状態】
     \\ //  r0：p_runtsk
     \\  ldr r1, 3f                     // p_schedtsk → r1
     \\  ldr r1, [r1]
     \\  teq r0, r1                     // p_runtskとp_schedtskが同じなら
     \\  beq irq_handler_4              //                irq_handler_4へ
     \\
     \\ // コンテキストを保存する．
     \\  push {r6-r11}                  // 残りのレジスタの保存
        ++ "\n" ++
        (if (USE_ARM_FPU)
     \\  ldr r2, [r0,%[tcb_p_tinib]]    // p_runtsk.p_tinib → r2
     \\  ldr r1, [r2,%[tinib_tskatr]]   // p_runtsk.p_tinib.tskatr → r1
     \\  tst r1, %[ta_fpu]
     \\  beq 1f                         // TA_FPU属性でない場合は分岐
        ++ "\n" ++
        (if (USE_ARM_FPU_D32)
     \\  vpush {d16-d31}
        else "") ++ "\n" ++
     \\  vpush {d0-d15}                 // 全FPUレジスタの保存
     \\  vmrs r1, fpscr
     \\  push {r1,r2}                   // FPSCRの保存
     \\ 1:                              // r2はアラインメントのため
        else "") ++ "\n" ++
     \\  str sp, [r0,%[tcb_sp]]         // スタックポインタを保存
     \\  adr r1, ret_int_r              // 実行再開番地を保存
     \\  str r1, [r0,%[tcb_pc]]
     \\  b dispatcher                   // r0にはp_runtskが格納されている
     \\
     \\ ret_int_r:
     \\ // コンテキストを復帰する．
     \\ //
     \\ // 【この時点のレジスタ状態】
     \\ //   r4：p_runtsk（タスク切換え後）
        ++ "\n" ++
        (if (USE_ARM_FPU)
     \\  ldr r2, [r4,%[tcb_p_tinib]]    // p_runtsk.p_tinib → r2
     \\  ldr r1, [r2,%[tinib_tskatr]]   // p_runtsk.p_tinib.tskatr → r1
     \\  tst r1, #TA_FPU
     \\  vmrs r0, fpexc
     \\  biceq r0, r0, %[fpexc_enable]
     \\  orrne r0, r0, %[fpexc_enable]
     \\  vmsr fpexc, r0                 // FPEXCを設定
     \\  beq 1f                         // TA_FPU属性でない場合は分岐
     \\  pop {r1,r2}                    // FPSCRの復帰
     \\  vmsr fpscr, r1
     \\  vpop {d0-d15}                  // 全FPUレジスタの復帰
        ++ "\n" ++
        (if (USE_ARM_FPU_D32)
     \\  vpop {d16-d31}
        else "") ++ "\n" ++
     \\ 1:
        else "") ++ "\n" ++
     \\  pop {r6-r11}                   // 残りのレジスタの復帰
     \\
     \\ irq_handler_4:
        ++ "\n" ++
        (if (TOPPERS_SUPPORT_OVRHDR)
     \\  bl _kernel_overrun_start
        else "") ++ "\n" ++
     \\
     \\ // 割込み処理からのリターン
     \\ //
     \\ // 割込み処理からのリターンにより，CPUロック解除状態に遷移
     \\ // するようにする必要があるが，ARMはCPSRのビットによってCPU
     \\ // ロック状態を表しているため，CPSRを元に戻してリターンすれ
     \\ // ばよい．
     \\ irq_handler_5:
     \\  pop {r0,r1}                    // スタックポインタの調整を元に戻す
     \\  add sp, sp, r1
     \\
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\  pop {r0}                       // 戻り先のcpsrをspsrに設定
     \\  msr spsr_cxsf, r0
     \\  ldmfd sp!, {r0-r5,r12,lr,pc}^  // コンテキストの復帰
     \\                                 // ^付きなので，spsr → cpsr
        else
     \\  pop {r0-r5,r12,lr}             // スクラッチレジスタ＋αの復帰
     \\  rfefd sp!
        )
        ++ "\n" ++
     \\ 2:
     \\  .long %[p_runtsk]
     \\ 3:
     \\  .long %[p_schedtsk]
     \\ 4:
     \\  .long %[excpt_nest_count]
     \\ 5:
     \\  .long _kernel_istkpt
     \\ 6:
     \\  .long _kernel_inh_table
     :
     : [cpsr_svc_cpulock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_CPULOCK)),
       [cpsr_irq_cpulock] "n" (@as(u32, arm.CPSR_IRQ_MODE | CPSR_CPULOCK)),
       [cpsr_svc_unlock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_UNLOCK)),
       [cpsr_svc] "n" (@as(u32, arm.CPSR_SVC_MODE)),
       [fpexc_enable] "n" (@as(u32, arm.FPEXC_ENABLE)),
       [tnum_inhno] "n" (@as(u32, TNUM_INHNO)),
       [tcb_p_tinib] "J" (@as(i16, @byteOffsetOf(task.TCB, "p_tinib"))),
       [tinib_tskatr] "J" (@as(i16, @byteOffsetOf(task.TINIB, "tskatr"))),
       [tcb_sp] "J" (@as(i16, @byteOffsetOf(task.TCB, "tskctxb")
                             + @byteOffsetOf(TSKCTXB, "sp"))),
       [tcb_pc] "J" (@as(i16, @byteOffsetOf(task.TCB, "tskctxb")
                             + @byteOffsetOf(TSKCTXB, "pc"))),
       [ta_fpu] "n" (@as(u32, TA_FPU)),
       [fpexc_enable] "n" (@as(u32, arm.FPEXC_ENABLE)),
       [excpt_nest_count] "s" (&excpt_nest_count),
       [p_runtsk] "s" (&task.p_runtsk),
       [p_schedtsk] "s" (&task.p_schedtsk),
       [irc_begin_int] "s" (target_impl.irc_begin_int),
       [irc_end_int] "s" (target_impl.irc_end_int),
       [dispatcher] "s" (dispatcher),
    );
    unreachable;
}

///
///  CPU例外ハンドラテーブルの取り込み
///
pub const ExternExcIniB = struct {
    extern const _kernel_exc_table: [TNUM_EXCNO]EXCHDR;
};

///
///  CPU例外ハンドラテーブルの生成（静的APIの処理）
///
extern fn _kernel_default_exc_handler(p_excinf: *T_EXCINF, excno: EXCNO) void;

pub fn ExportExcIniB(excinib_list: []exception.EXCINIB) type {
    // チェック処理用の定義の生成
    exportCheck(TNUM_EXCNO, "TNUM_EXCNO");
    exportCheck(@sizeOf(EXCHDR), "sizeof_EXCHDR");

    comptime var exc_table =
        [1]EXCHDR{ @ptrCast(EXCHDR, _kernel_default_exc_handler) }
                                                        ** TNUM_EXCNO;
    for (excinib_list) |excinib| {
        exc_table[excinib.excno] = excinib.exchdr;
    }
    return struct {
        pub export const _kernel_exc_table = exc_table;
    };
}

///
///  CPU例外ハンドラの初期化
///
pub fn initialize_exception() void {
}

///
///  CPU例外ハンドラ番号の範囲の判定
///
pub fn validExcno(excno: EXCNO) bool {
    return 0 <= excno and excno < TNUM_EXCNO;
}
pub fn validExcnoDefExc(excno: EXCNO) bool {
    return validExcno(excno) and excno != EXCNO_IRQ;
}

///
///  CPU例外の発生した時のコンテキストの参照
///
///  CPU例外の発生した時のコンテキストが，タスクコンテキストの時に
///  false，そうでない時にtrueを返す．
///
pub fn exc_sense_context(p_excinf: *T_EXCINF) bool {
    return p_excinf.nest_count != 0;
}

///
///  CPU例外の発生した時の割込み優先度マスクの参照
///
pub fn exc_get_intpri(p_excinf: *T_EXCINF) PRI {
    return @intCast(PRI, p_excinf.intpri);
}

///
///  CPUロック状態または割込みロック状態かの参照
///
pub fn exc_sense_lock(p_excinf: *T_EXCINF) bool {
    return (p_excinf.cpsr & arm.CPSR_INT_MASK) != 0;
}

///
///  CPU例外の発生した時のコンテキストと割込みのマスク状態の参照
///
///  CPU例外の発生した時のシステム状態が，カーネル実行中でなく，タスク
///  コンテキストであり，全割込みロック状態でなく，CPUロック状態でなく，
///  割込み優先度マスク全解除状態である時にtrue，そうでない時にfalseを
///  返す（CPU例外がカーネル管理外の割込み処理中で発生した場合にも
///  falseを返す）．
///
pub fn exc_sense_intmask(p_excinf: *c_void) bool {
    const p_arm_excinf = ptrAlignCast(*T_EXCINF, p_excinf);
    return(!exc_sense_context(p_arm_excinf)
               and exc_get_intpri(p_arm_excinf) == TIPM_ENAALL
               and !exc_sense_lock(p_arm_excinf));
}

//
//  CPU例外ハンドラ出入口処理
//
fn exc_entry() callconv(.Naked) void {
    asm volatile(" start_exc_entry:");

    //
    //  未定義命令
    //
    asm volatile(
     \\ undef_handler:
     \\ // ここには，未定義モードで分岐してくる．
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\ // IビットとFビットをセットし，スーパバイザモードに切り換え，
     \\ // スクラッチレジスタ＋αを保存する．
     \\  msr cpsr_c, %[cpsr_svc_intlock]
     \\  push {r0-r5,r12,lr,pc}         // pcはスペース確保のため
     \\
     \\ // 未定義モードに戻して，戻り番地（lr）と戻り先のcpsr（spsr）
     \\ // を取得する．
     \\  msr cpsr_c, %[cpsr_und_intlock]
     \\  mov r2, lr
     \\  mrs r1, spsr
     \\
     \\ // スーパバイザモードに切り換え，戻り番地と戻り先のcpsrを保
     \\ // 存する．
     \\  msr cpsr_c, %[cpsr_svc_intlock]
     \\  str r2, [sp,#0x20]             // 戻り番地をスタックに保存（pcの場所）
     \\  push {r1}                      // 戻り先のcpsrをスタックに保存
        else
     \\ // 戻り番地（lr）と戻り先のcpsr（spsr）をスーパバイザモード
     \\ // のスタックに保存する．
     \\  srsfd %[cpsr_svc]!
     \\
     \\ // スーパバイザモードに切り換え，スクラッチレジスタ＋αを保
     \\ // 存する．
     \\  cps %[cpsr_svc]
     \\  push {r0-r5,r12,lr}
        ) ++ "\n" ++
     \\  mov r4, %[excno_undef]
     \\  b exc_handler_1
     :
     : [cpsr_svc_intlock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_INTLOCK)),
       [cpsr_und_intlock] "n" (@as(u32, arm.CPSR_UND_MODE | CPSR_INTLOCK)),
       [cpsr_svc] "n" (@as(u32, arm.CPSR_SVC_MODE)),
       [excno_undef] "n" (@as(u32, EXCNO_UNDEF)),
    );

    //
    //  スーパバイザコール
    //
    asm volatile(
     \\ svc_handler:
     \\ // ここには，スーパバイザモードで分岐してくる．
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\ // IビットとFビットをセットし，戻り番地（lr），スクラッチレジ
     \\ // スタ＋α，戻り先のcpsr（spsr）を保存する（lrは二重に保存さ
     \\ // れる）．
     \\  msr cpsr_c, %[cpsr_svc_intlock]
     \\  push {lr}
     \\  push {r0-r5,r12,lr}
     \\  mrs r1, spsr
     \\  push {r1}
        else
     \\ // 戻り番地（lr）と戻り先のcpsr（spsr）をスーパバイザモードの
     \\ // スタックに保存する．
     \\  srsfd %[cpsr_svc]!
     \\
     \\ // スーパバイザモードで，スクラッチレジスタ＋αを保存する．
     \\  push {r0-r5,r12,lr}
        ) ++ "\n" ++
     \\  mov r4, %[excno_svc]
     \\  b exc_handler_1
     :
     : [cpsr_svc_intlock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_INTLOCK)),
       [cpsr_und_intlock] "n" (@as(u32, arm.CPSR_UND_MODE | CPSR_INTLOCK)),
       [cpsr_svc] "n" (@as(u32, arm.CPSR_SVC_MODE)),
       [excno_svc] "n" (@as(u32, EXCNO_SVC)),
    );

    //
    //  プリフェッチアボート
    //
    asm volatile(
     \\ pabort_handler:
     \\ // ここには，アボートモードで分岐してくる．
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\ // IビットとFビットをセットし，スーパバイザモードに切り換え，
     \\ // スクラッチレジスタ＋αを保存する．
     \\  msr cpsr_c, %[cpsr_svc_intlock]
     \\  push {r0-r5,r12,lr,pc}         // pcはスペース確保のため
     \\
     \\ // アボートモードに戻して，戻り番地（lr）と戻り先の
     \\ // cpsr（spsr）を取得する．
     \\  msr cpsr_c, %[cpsr_abt_intlock]
     \\  mov r2, lr
     \\  mrs r1, spsr
     \\
     \\ // スーパバイザモードに切り換え，戻り番地と戻り先のcpsrを保
     \\ // 存する．
     \\  msr cpsr_c, %[cpsr_svc_intlock]
     \\  str r2, [sp,#0x20]             // 戻り番地をスタックに保存（pcの場所）
     \\  push {r1}                      // 戻り先のcpsrをスタックに保存
        else
     \\ // 戻り番地（lr）と戻り先のcpsr（spsr）をスーパバイザモード
     \\ // のスタックに保存する．
     \\  srsfd %[cpsr_svc]!
     \\
     \\ // スーパバイザモードに切り換え，スクラッチレジスタ＋αを保
     \\ // 存する．
     \\  cps %[cpsr_svc]
     \\  push {r0-r5,r12,lr}
        ) ++ "\n" ++
     \\  mov r4, %[excno_pabort]
     \\  b exc_handler_1
     :
     : [cpsr_svc_intlock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_INTLOCK)),
       [cpsr_abt_intlock] "n" (@as(u32, arm.CPSR_ABT_MODE | CPSR_INTLOCK)),
       [cpsr_svc] "n" (@as(u32, arm.CPSR_SVC_MODE)),
       [excno_pabort] "n" (@as(u32, EXCNO_PABORT)),
    );

    //
    //  データアボート
    //
    asm volatile(
     \\ dabort_handler:
     \\ // ここには，アボートモードで分岐してくる．
     \\ //
     \\ // データアボートが，CPU例外の入口（start_exc_entryと
     \\ // end_exc_entryの間）で発生した場合には，
     \\ // fatal_dabort_handlerに分岐する．アボートモードのspを汎用
     \\ // レジスタの代わりに使用する（r13と記述している）．
     \\  adr r13, start_exc_entry+8
     \\  cmp lr, r13
     \\  bcc dabort_handler_1
     \\  adr r13, end_exc_entry+8
     \\  cmp lr, r13
     \\  bcc fatal_dabort_handler
     \\ dabort_handler_1:
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\ // IビットとFビットをセットし，スーパバイザモードに切り換え，
     \\ // スクラッチレジスタ＋αを保存する．
     \\  msr cpsr_c, %[cpsr_svc_intlock]
     \\  push {r0-r5,r12,lr,pc}         // pcはスペース確保のため
     \\
     \\ // アボートモードに戻して，戻り番地（lr）と戻り先の
     \\ // cpsr（spsr）を取得する．
     \\  msr cpsr_c, %[cpsr_abt_intlock]
     \\  mov r2, lr
     \\  mrs r1, spsr
     \\
     \\ // スーパバイザモードに切り換え，戻り番地と戻り先のcpsrを保
     \\ // 存する．
     \\  msr cpsr_c, %[cpsr_svc_intlock]
     \\  str r2, [sp,#0x20]             // 戻り番地をスタックに保存（pcの場所）
     \\  push {r1}                      // 戻り先のcpsrをスタックに保存
        else
     \\ // 戻り番地（lr）と戻り先のcpsr（spsr）をスーパバイザモード
     \\ // のスタックに保存する．
     \\  srsfd %[cpsr_svc]!
     \\
     \\ // スーパバイザモードに切り換え，スクラッチレジスタ＋αを保
     \\ // 存する．
     \\  cps %[cpsr_svc]
     \\  push {r0-r5,r12,lr}
        ) ++ "\n" ++
     \\  mov r4, %[excno_dabort]
     \\  b exc_handler_1
     :
     : [cpsr_svc_intlock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_INTLOCK)),
       [cpsr_abt_intlock] "n" (@as(u32, arm.CPSR_ABT_MODE | CPSR_INTLOCK)),
       [cpsr_svc] "n" (@as(u32, arm.CPSR_SVC_MODE)),
       [excno_dabort] "n" (@as(u32, EXCNO_DABORT)),
    );

    //
    //  CPU例外の入口で発生したデータアボート
    //
    asm volatile(
     \\ fatal_dabort_handler:
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\ // IビットとFビットをセットし，スーパバイザモードに切り換え，
     \\ // スタックポインタを初期化し，スクラッチレジスタ＋αを保存
     \\ // する．
     \\  msr cpsr_c, %[cpsr_svc_intlock]
     \\  ldr sp, 5f
     \\  ldr sp, [sp]
     \\  push {r0-r5,r12,lr,pc}         // pcはスペース確保のため
     \\
     \\ // アボートモードに戻して，戻り番地（lr）と戻り先の
     \\ // cpsr（spsr）を取得する．
     \\  msr cpsr_c, %[cpsr_abt_intlock]
     \\  mov r2, lr
     \\  mrs r1, spsr
     \\
     \\ // スーパバイザモードに切り換え，戻り番地と戻り先のcpsrを保
     \\ // 存する．
     \\  msr cpsr_c, %[cpsr_svc_intlock]
     \\  str r2, [sp,#0x20]             // 戻り番地をスタックに保存（pcの場所）
     \\  push {r1}                      // 戻り先のcpsrをスタックに保存
        else
     \\ // IビットとFビットをセットし，スーパバイザモードに切り換え，
     \\ // スタックポインタを初期化する．
     \\  cpsid if, %[cpsr_svc]
     \\  ldr sp, 5f
     \\  ldr sp, [sp]
     \\
     \\ // アボートモードに戻して，戻り番地（lr）と戻り先の
     \\ // cpsr（spsr）をスーパバイザモードのスタックに保存する．
     \\  cps %[cpsr_abt]
     \\  srsfd %[cpsr_svc]!
     \\
     \\ // スーパバイザモードに切り換え，スクラッチレジスタ＋αを保
     \\ // 存する．
     \\  cps %[cpsr_svc]
     \\  push {r0-r5,r12,lr}
        ) ++ "\n" ++
     \\
     \\ // 例外ネストカウントをインクリメントする．
     \\  ldr r2, 4f
     \\  ldr r3, [r2]
     \\  add r3, r3, #1
     \\  str r3, [r2]
     \\
     \\  mov r4, %[excno_fatal]
     \\  b exc_handler_1
     \\ 4:
     \\  .long %[excpt_nest_count]
     \\ 5:
     \\  .long _kernel_istkpt
     :
     : [cpsr_svc_intlock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_INTLOCK)),
       [cpsr_abt_intlock] "n" (@as(u32, arm.CPSR_ABT_MODE | CPSR_INTLOCK)),
       [cpsr_svc] "n" (@as(u32, arm.CPSR_SVC_MODE)),
       [cpsr_abt] "n" (@as(u32, arm.CPSR_ABT_MODE)),
       [excno_fatal] "n" (@as(u32, EXCNO_FATAL)),
       [excpt_nest_count] "s" (&excpt_nest_count),
    );

    //
    //  FIQ
    //
    asm volatile(
     \\ fiq_handler:
     \\ // ここには，FIQモードで分岐してくる．
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\ // IビットとFビットをセットし，スーパバイザモードに切り換え，
     \\ // スクラッチレジスタ＋αを保存する．
     \\  msr cpsr_c, %[cpsr_svc_intlock]
     \\  push {r0-r5,r12,lr,pc}         // pcはスペース確保のため
     \\
     \\ // FIQモードに戻して，戻り番地（lr）と戻り先のcpsr（spsr）
     \\ // を取得する．
     \\  msr cpsr_c, %[cpsr_fiq_intlock]
     \\  mov r2, lr
     \\  mrs r1, spsr
     \\
     \\ // スーパバイザモードに切り換え，戻り番地と戻り先のcpsrを保
     \\ // 存する．
     \\  msr cpsr_c, %[cpsr_svc_intlock]
     \\  str r2, [sp,#0x20]             // 戻り番地をスタックに保存（pcの場所）
     \\  push {r1}                      // 戻り先のcpsrをスタックに保存
        else
     \\ // 戻り番地（lr）と戻り先のcpsr（spsr）をスーパバイザモード
     \\ // のスタックに保存する．
     \\  srsfd %[cpsr_svc]!
     \\
     \\ // スーパバイザモードに切り換え，スクラッチレジスタ＋αを保
     \\ // 存する．
     \\  cps %[cpsr_svc]
     \\  push {r0-r5,r12,lr}
        ) ++ "\n" ++
     \\  mov r4, %[excno_fiq]
     \\  b exc_handler_1
     :
     : [cpsr_svc_intlock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_INTLOCK)),
       [cpsr_fiq_intlock] "n" (@as(u32, arm.CPSR_FIQ_MODE | CPSR_INTLOCK)),
       [cpsr_svc] "n" (@as(u32, arm.CPSR_SVC_MODE)),
       [excno_fiq] "n" (@as(u32, EXCNO_FIQ)),
    );

    asm volatile(" end_exc_entry:");

    //
    //  CPU例外ハンドラ出入口処理の共通部分
    //
    asm volatile(
     \\ exc_handler_1:
     \\ // 【この時点のレジスタ状態】
     \\ //  r4：CPU例外ハンドラ番号
     \\ //
     \\ // CPU例外が発生した状況の判断に用いるために，CPU例外発生前
     \\ // の割込み優先度マスクと例外ネストカウントをスタックに保存
     \\ // する．
     \\  bl irc_get_intpri
     \\  push {r0}                      // 割込み優先度マスクを保存
     \\  ldr r2, 4f
     \\  ldr r3, [r2]
     \\  push {r3}                      // 例外ネストカウントを保存
     \\  mov r5, sp                     // CPU例外の情報を記憶している領域の
     \\                                 //                先頭番地をr5に保存
     \\ // スタックポインタの調整
     \\  and r1, sp, #4
     \\  sub sp, sp, r1
     \\  push {r0,r1}                   // スタックポインタの調整値を保存
     \\                                 // r0はスペース確保のため
     \\ // カーネル管理外のCPU例外か判定する
     \\ //
     \\ // カーネル管理外のCPU例外は，カーネル実行中，全割込みロッ
     \\ // ク状態，CPUロック状態，カーネル管理外の割込みハンドラ実
     \\ // 行中に発生したCPU例外である．ARMコアの場合は，戻り先の
     \\ // CPSRのIビットかFビットのいずれかがセットされているなら，
     \\ // これに該当する．
     \\  ldr r1, [r5,%[t_excinf_cpsr]]  // 例外フレームからcpsrを取得
     \\  ands r1, r1, %[cpsr_fiq_irq]
     \\  bne nk_exc_handler_1           // カーネル管理外のCPU例外の処理へ
     \\
     \\ // 【この時点のレジスタ状態】
     \\ //  r2：excpt_nest_countの番地
     \\ //  r3：excpt_nest_countの値
     \\ //  r4：CPU例外ハンドラ番号
     \\ //  r5：CPU例外の情報を記憶している領域の先頭番地
     \\
     \\ // 例外ネストカウントをインクリメントする．
     \\  add r3, r3, #1
     \\  str r3, [r2]
     \\  teq r3, #1                     // CPU例外発生前が非タスクコンテキスト
     \\  bne exc_handler_2              //             ならexc_handler_2に分岐
     \\
        ++ "\n" ++
        (if (TOPPERS_SUPPORT_OVRHDR)
     \\  bl _kernel_overrun_stop
        else "") ++ "\n" ++
        (if (USE_ARM_FPU)
     \\ // FPUをディスエーブルする．
     \\  vmrs r0, fpexc
     \\  str r0, [sp]                   // FPEXCを保存（r0の場所）*/
     \\  bic r0, r0, %[fpexc_enable]
     \\  vmsr fpexc, r0                 // FPEXCを設定
        else "") ++ "\n" ++
     \\ 
     \\ // 非タスクコンテキスト用のスタックに切り換える．
     \\  mov r3, sp                     // この時点のスタックポインタをr3に
     \\  ldr r2, 5f                     // 非タスクコンテキスト用のスタックに
     \\  ldr sp, [r2]
     \\  push {r0,r3}                   // 切換え前のスタックポインタを保存
     \\                                 // r0はスペース確保のため
     \\ exc_handler_2:
     \\ // 【この時点のレジスタ状態】
     \\ //  r4：CPU例外ハンドラ番号
     \\ //  r5：CPU例外の情報を記憶している領域の先頭番地
     \\
     \\ // （必要なら）割込みコントローラを操作する．
     \\ //
     \\ // irc_begin_excは，スタックトップ（r0の場所）に，
     \\ // irc_end_excで用いる情報を保存する．
     \\  bl irc_begin_exc
     \\
     \\ // CPUロック解除状態にする．
     \\ //
     \\ // カーネル管理外のCPU例外ハンドラは別ルーチンで呼び出すた
     \\ // め，単純に割込みを許可するだけでよい．
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\  msr cpsr_c, %[cpsr_svc_unlock]
        else
     \\  cpsie if
        ) ++ "\n" ++
     \\
        ++ "\n" ++
        (if (LOG_EXC_ENTER)
     \\ // ログ出力の呼出し
     \\  mov r0, r4                     // CPU例外番号をパラメータに渡す
     \\  bl _kernel_log_exc_enter
        else "") ++ "\n" ++
     \\
     \\ // CPU例外ハンドラの呼出し
     \\  ldr r2, 7f                     // CPU例外ハンドラテーブルの読込み
     \\  ldr r3, [r2,r4,lsl #2]         // CPU例外ハンドラの番地 → r3
     \\  mov r0, r5                     // CPU例外の情報を記憶している領域の
     \\                                 //     先頭番地を第1パラメータに渡す
     \\  mov r1, r4                     // CPU例外番号を第2パラメータに渡す
     \\  mov lr, pc                     // CPU例外ハンドラの呼出し
     \\  bx r3
     \\
        ++ "\n" ++
        (if (LOG_EXC_LEAVE)
     \\ // ログ出力の呼出し
     \\  mov r0, r4                     // CPU例外番号をパラメータに渡す
     \\  bl _kernel_log_exc_leave
        else "") ++ "\n" ++
     \\
     \\ // カーネル管理の割込みを禁止する．
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\  msr cpsr_c, %[cpsr_svc_cpulock]
        else
     \\  cpsid i
        ) ++ "\n" ++
     \\
     \\ // 割込みコントローラを操作して，割込み優先度マスクを，CPU
     \\ // 例外発生時の値に設定する．
     \\  bl irc_end_exc
     \\
     \\ // 例外ネストカウントをデクリメントする．
     \\  ldr r2, 4f
     \\  ldr r3, [r2]
     \\  subs r3, r3, #1
     \\  str r3, [r2]                   // 戻り先が非タスクコンテキストなら
     \\  bne exc_handler_5              // exc_handler_5に分岐
     \\
     \\ // タスク用のスタックに戻す．
     \\  pop {r0,r3}
     \\  mov sp, r3
     \\
        ++ "\n" ++
        (if (USE_ARM_FPU)
     \\ // FPUを元に戻す．
     \\  ldr r0, [sp]                   // FPEXCを復帰
     \\  vmsr fpexc, r0
        else "") ++ "\n" ++
     \\ 
     \\ // p_runtskがNULLか判定する．
     \\  ldr r0, 2f                     // p_runtsk → r0
     \\  ldr r0, [r0]
     \\  tst r0, r0                     // p_runtskがNULLでなければ
     \\  bne exc_handler_3              // exc_handler_3に分岐
     \\
     \\ // タスクのスタックに保存したスクラッチレジスタ等を捨てる．
     \\  pop {r0,r1}                    // スタックポインタの調整を元に戻す
     \\  add sp, sp, r1
     \\  add sp, sp, #48                // スクラッチレジスタとCPU例外が発生した
     \\  b dispatcher_0                 // 状況を判断するための追加情報を捨てる
     \\
     \\ // ディスパッチが必要か判定する．
     \\ exc_handler_3:
     \\ // 【この時点のレジスタ状態】
     \\ //  r0：p_runtsk
     \\  ldr r1, 3f                     // p_schedtsk → r1
     \\  ldr r1, [r1]
     \\  teq r0, r1                     // p_runtskとp_schedtskが同じなら
     \\  beq exc_handler_4              //                exc_handler_4へ
     \\
     \\ // コンテキストを保存する．
     \\  push {r6-r11}                  // 残りのレジスタの保存
        ++ "\n" ++
        (if (USE_ARM_FPU)
     \\  ldr r2, [r0,%[tcb_p_tinib]]    // p_runtsk.p_tinib → r2
     \\  ldr r1, [r2,%[tinib_tskatr]]   // p_runtsk.p_tinib.tskatr → r1
     \\  tst r1, %[ta_fpu]
     \\  beq 1f                         // TA_FPU属性でない場合は分岐
        ++ "\n" ++
        (if (USE_ARM_FPU_D32)
     \\  vpush {d16-d31}
        else "") ++ "\n" ++
     \\  vpush {d0-d15}                 // 全FPUレジスタの保存
     \\  vmrs r1, fpscr
     \\  push {r1,r2}                   // FPSCRの保存
     \\ 1:                              // r2はアラインメントのため
        else "") ++ "\n" ++
     \\  str sp, [r0,%[tcb_sp]]         // スタックポインタを保存
     \\  adr r1, ret_exc_r              // 実行再開番地を保存
     \\  str r1, [r0,%[tcb_pc]]
     \\  b dispatcher                   // r0にはp_runtskが格納されている
     \\
     \\ ret_exc_r:
     \\ // コンテキストを復帰する．
     \\ //
     \\ // 【この時点のレジスタ状態】
     \\ //  r4：p_runtsk（タスク切換え後）
        ++ "\n" ++
        (if (USE_ARM_FPU)
     \\  ldr r2, [r4,%[tcb_p_tinib]]    // p_runtsk.p_tinib → r2
     \\  ldr r1, [r2,%[tinib_tskatr]]   // p_runtsk.p_tinib.tskatr → r1
     \\  tst r1, %[ta_fpu]
     \\  vmrs r0, fpexc
     \\  biceq r0, r0, %[fpexc_enable]
     \\  orrne r0, r0, %[fpexc_enable]
     \\  vmsr fpexc, r0                 // FPEXCを設定
     \\  beq 1f                         // TA_FPU属性でない場合は分岐
     \\  pop {r1,r2}                    // FPSCRの復帰
     \\  vmsr fpscr, r1
     \\  vpop {d0-d15}                  // 全FPUレジスタの復帰
        ++ "\n" ++
        (if (USE_ARM_FPU_D32)
     \\  vpop {d16-d31}
        else "") ++ "\n" ++
     \\ 1:
        else "") ++ "\n" ++
     \\  pop {r6-r11}                   // 残りのレジスタの復帰
     \\
     \\ exc_handler_4:
        ++ "\n" ++
        (if (TOPPERS_SUPPORT_OVRHDR)
     \\  bl _kernel_overrun_start
        else "") ++ "\n" ++
     \\
     \\ // CPU例外処理からのリターン
     \\ //
     \\ // CPU例外処理からのリターンにより，CPUロック解除状態に遷移
     \\ // するようにする必要があるが，ARMはCPSRのビットによってCPU
     \\ // ロック状態を表しているため，CPSRを元に戻してリターンすれ
     \\ // ばよい．
     \\ exc_handler_5:
     \\  pop {r0,r1}                    // スタックポインタの調整を元に戻す
     \\  add sp, sp, r1
     \\  add sp, sp, #8                 // スタック上の情報を捨てる
        ++ "\n" ++
        (if (comptime !arm.isEnabled(arm.Feature.has_v6))
     \\  pop {r0}                       // 戻り先のcpsrをspsrに設定
     \\  msr spsr_cxsf, r0
     \\  ldmfd sp!, {r0-r5,r12,lr,pc}^  // コンテキストの復帰
     \\                                 // ^付きなので，spsr → cpsr
        else
     \\  pop {r0-r5,r12,lr}             // スクラッチレジスタ＋αの復帰
     \\  rfefd sp!
     \\ 2:
     \\  .long %[p_runtsk]
     \\ 3:
     \\  .long %[p_schedtsk]
     \\ 4:
     \\  .long %[excpt_nest_count]
     \\ 5:
     \\  .long _kernel_istkpt
     \\ 7:
     \\  .long _kernel_exc_table
        )
     :
     : [cpsr_svc_cpulock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_CPULOCK)),
       [cpsr_svc_unlock] "n" (@as(u32, arm.CPSR_SVC_MODE | CPSR_UNLOCK)),
       [cpsr_fiq_irq] "n" (@as(u32, arm.CPSR_FIQ_IRQ_BIT)),
       [tcb_p_tinib] "J" (@as(i16, @byteOffsetOf(task.TCB, "p_tinib"))),
       [tinib_tskatr] "J" (@as(i16, @byteOffsetOf(task.TINIB, "tskatr"))),
       [t_excinf_cpsr] "J" (@as(i16, @byteOffsetOf(T_EXCINF, "cpsr"))),
       [tcb_sp] "J" (@as(i16, @byteOffsetOf(task.TCB, "tskctxb")
                             + @byteOffsetOf(TSKCTXB, "sp"))),
       [tcb_pc] "J" (@as(i16, @byteOffsetOf(task.TCB, "tskctxb")
                             + @byteOffsetOf(TSKCTXB, "pc"))),
       [ta_fpu] "n" (@as(u32, TA_FPU)),
       [fpexc_enable] "n" (@as(u32, arm.FPEXC_ENABLE)),
       [excpt_nest_count] "s" (&excpt_nest_count),
       [p_runtsk] "s" (&task.p_runtsk),
       [p_schedtsk] "s" (&task.p_schedtsk),
       [irc_get_intpri] "s" (target_impl.irc_get_intpri),
       [irc_begin_exc] "s" (target_impl.irc_begin_exc),
       [irc_end_exc] "s" (target_impl.irc_end_exc),
    );

    //
    //  カーネル管理外のCPU例外の出入口処理
    //
    asm volatile(
     \\ nk_exc_handler_1:
     \\ // 【この時点のレジスタ状態】
     \\ //  r1：CPU例外発生前のCPSRのFビットとIビットの値
     \\ //  r2：excpt_nest_countの番地
     \\ //  r3：excpt_nest_countの値
     \\ //  r4：CPU例外ハンドラ番号
     \\ //  r5：CPU例外の情報を記憶している領域の先頭番地
     \\
     \\ // 例外ネストカウントをインクリメントする．
     \\  add r3, r3, #1
     \\  str r3, [r2]
     \\  teq r3, #1                     // CPU例外発生前が非タスクコンテキスト
     \\  bne nk_exc_handler_2           //          ならnk_exc_handler_2に分岐
        ++ "\n" ++
        (if (USE_ARM_FPU)
     \\ // FPUをディスエーブルする．
     \\  vmrs r0, fpexc
     \\  str r0, [sp]                   // FPEXCを保存（r0の場所）
     \\  bic r0, r0, %[fpexc_enable]
     \\  vmsr fpexc, r0                 // FPEXCを設定
        else "") ++ "\n" ++
     \\ 
     \\ // 非タスクコンテキスト用のスタックに切り換える．
     \\  mov r3, sp                     // この時点のスタックポインタをr3に
     \\  ldr r2, 5f                     // 非タスクコンテキスト用のスタックに
     \\  ldr sp, [r2]
     \\  push {r0,r3}                   // 切換え前のスタックポインタを保存
     \\                                 // r0はアラインメントのため
     \\ nk_exc_handler_2:
     \\ // システム状態（コンテキストは除く）を，CPU例外発生時の状態へ
     \\  orr r1, r1, %[cpsr_svc]
     \\  msr cpsr_c, r1
     \\
     \\ // CPU例外ハンドラの呼出し
     \\  ldr r2, 7f                     // CPU例外ハンドラテーブルの読込み
     \\  ldr r3, [r2,r4,lsl #2]         // CPU例外ハンドラの番地 → r3
     \\  mov r0, r5                     // CPU例外の情報を記憶している領域の
     \\                                 //     先頭番地を第1パラメータに渡す
     \\  mov r1, r4                     // CPU例外番号を第2パラメータに渡す
     \\  mov lr, pc                     // CPU例外ハンドラの呼出し
     \\  bx r3
     \\
     \\ // 例外ネストカウントをデクリメントする．
     \\  ldr r2, 4f
     \\  ldr r3, [r2]
     \\  subs r3, r3, #1
     \\  str r3, [r2]                   // 戻り先が非タスクコンテキストなら
     \\  bne exc_handler_5              // exc_handler_5に分岐
     \\
     \\ // タスク用のスタックに戻す．
     \\  pop {r0,r3}
     \\  mov sp, r3
     \\
        ++ "\n" ++
        (if (USE_ARM_FPU)
     \\ // FPUを元に戻す．
     \\  ldr r0, [sp]                   // FPEXCを復帰
     \\  vmsr fpexc, r0
        else "") ++ "\n" ++
     \\  b exc_handler_5
     \\ 4:
     \\  .long %[excpt_nest_count]
     \\ 5:
     \\  .long _kernel_istkpt
     \\ 7:
     \\  .long _kernel_exc_table
     :
     : [fpexc_enable] "n" (@as(u32, arm.FPEXC_ENABLE)),
       [cpsr_svc] "n" (@as(u32, arm.CPSR_SVC_MODE)),
       [excpt_nest_count] "s" (&excpt_nest_count),
    );
    unreachable;
}

///
///  変換テーブルベースレジスタ（TTBR）の設定値
///
const TTBR_CONFIG =
    if (comptime arm.isEnabled(arm.Feature.has_v7))
        (arm.CP15_TTBR_RGN_SHAREABLE
             | arm.CP15_TTBR_RGN_WBWA
             | arm.CP15_TTBR_IRGN_WBWA)
    else if (comptime arm.isEnabled(arm.Feature.has_v6))
        (arm.CP15_TTBR_RGN_CACHEABLE
             | arm.CP15_TTBR_RGN_SHAREABLE
             | arm.CP15_TTBR_RGN_WBACK)
    else @compileError("not supported.");

///
///  MMUの設定情報のデータ型
///
pub const ARM_MMU_CONFIG = struct {
    vaddr: u32,     // 仮想アドレス
    paddr: u32,     // 物理アドレス
    size: u32,      // サイズ
    attr: u32,      // セクション属性
};

///
///  MMU関連の定義
///
const CP15_DACR_D0_CLIENT = 0x01;      // 変換テーブルに従いドメイン0にアクセス
const DEFAULT_ASID = 1;                // 使用するASID

///
///  セクションテーブル
///
var section_table: [arm.SECTION_TABLE_ENTRY]u32
    align(arm.SECTION_TABLE_ALIGN) = undefined;

///
///  MMUのセクションテーブルエントリの設定
///
fn config_section_entry(ammuc: ARM_MMU_CONFIG) void {
    var vaddr = ammuc.vaddr;
    var paddr = ammuc.paddr;
    var size = ammuc.size;

    assert(vaddr % arm.SECTION_SIZE == 0);
    assert(paddr % arm.SECTION_SIZE == 0);
    assert(size % arm.SECTION_SIZE == 0);
    while (size > 0) {
        if (USE_ARM_SSECTION
                and size >= arm.SSECTION_SIZE
                and (vaddr % arm.SSECTION_SIZE) == 0) {
            var i: usize = 0;
            while (i < 16) : (i += 1) {
                section_table[vaddr / arm.SECTION_SIZE]
                    = paddr | arm.MMU_DSCR1_SSECTION | ammuc.attr;
                vaddr +%= arm.SECTION_SIZE;
            }
            paddr +%= arm.SSECTION_SIZE;
            size -= arm.SSECTION_SIZE;
        }
        else {
            section_table[vaddr / arm.SECTION_SIZE]
                = paddr | arm.MMU_DSCR1_SECTION | ammuc.attr;
            vaddr +%= arm.SECTION_SIZE;
            paddr +%= arm.SECTION_SIZE;
            size -= arm.SECTION_SIZE;
        }
    }
}

///
///  MMUの初期化
///
fn arm_mmu_initialize() void {
    var reg: u32 = undefined;

    // MMUのセクションテーブルの設定
    for (section_table) |*entry| {
        entry.* = arm.MMU_DSCR1_FAULT;
    }
    for (target_impl.arm_memory_area) |area| {
        config_section_entry(area);
    }

    // TTBR0を用いるように指定（ARMv6以降）
    if (comptime arm.isEnabled(arm.Feature.has_v6)) {
        arm.CP15_WRITE_TTBCR(0);
    }

    // 変換テーブルとして，section_tableを使用する．
    reg = @intCast(u32, @ptrToInt(&section_table)) | TTBR_CONFIG;
    arm.CP15_WRITE_TTBR0(reg);

    // ドメインアクセス制御の設定
    arm.CP15_WRITE_DACR(CP15_DACR_D0_CLIENT);

    // ASIDの設定
    if (comptime arm.isEnabled(arm.Feature.has_v6)) {
        arm.CP15_WRITE_CONTEXTIDR(DEFAULT_ASID);
    }

    // TLB全体の無効化
    arm.invalidate_tlb();

    // MMUを有効にする．ARMv6では，拡張ページテーブル設定を使う（サブ
    // ページは使わない）ように設定する．
    reg = arm.CP15_READ_SCTLR();
    if (comptime arm.isEnabled(arm.Feature.has_v6)
            and !arm.isEnabled(arm.Feature.has_v7)) {
        reg |= (arm.CP15_SCTLR_MMU | arm.CP15_SCTLR_EXTPAGE);
    }
    else {
        reg |= arm.CP15_SCTLR_MMU;
    }
    arm.CP15_WRITE_SCTLR(reg);
    arm.inst_sync_barrier();
}

///
///  FPUの初期化
///
pub fn arm_fpu_initialize() void {
    // CP10とCP11をアクセス可能に設定する．
    var reg = arm.CP15_READ_CPACR();
    reg |= (arm.CP15_CPACR_CP10_FULLACCESS | arm.CP15_CPACR_CP11_FULLACCESS);
    arm.CP15_WRITE_CPACR(reg);

    // FPUをイネーブルする．
    arm.set_fpexc(arm.current_fpexc() | @as(u32, arm.FPEXC_ENABLE));
}

///
///  パフォーマンスモニタの初期化
///
fn arm_pmcnt_initialize() void {
    var reg: u32 = undefined;

    // パフォーマンスモニタをイネーブル
    //
    // USE_ARM_PMCNT_DIV64が定義されている場合は，64クロック毎にカウン
    // トアップする（長い時間を計測したい場合に有効）．
    //
    reg = arm.CP15_READ_PMCR();
    reg |= arm.CP15_PMCR_ALLCNTR_ENABLE;
    if (USE_ARM_PMCNT_DIV64) {
        reg |= arm.CP15_PMCR_PMCCNTR_DIVIDER;
    }
    else {
        reg &= ~@as(u32, arm.CP15_PMCR_PMCCNTR_DIVIDER);
    }
    arm.CP15_WRITE_PMCR(reg);

    // パフォーマンスモニタのサイクルカウンタをイネーブル
    reg = arm.CP15_READ_PMCNTENSET();
    reg |= arm.CP15_PMCNTENSET_CCNTR_ENABLE;
    arm.CP15_WRITE_PMCNTENSET(reg);
}

///
///  コア依存の初期化
///
pub fn core_initialize() void {
    // カーネル起動時は非タスクコンテキストとして動作させるために，例
    // 外のネスト回数を1に初期化する．
    excpt_nest_count = 1;

    // MMUを有効に
    if (USE_ARM_MMU) {
        arm_mmu_initialize();
    }

    // パフォーマンスモニタの初期化
    if (comptime arm.isEnabled(arm.Feature.has_v7) and USE_ARM_PMCNT) {
        arm_pmcnt_initialize();
    }
}

///
///  コア依存の終了処理
///
pub fn core_terminate() void {
}

///
///  CPU例外の発生状況のログ出力
///

///
///  CPU例外ハンドラの中から，CPU例外情報ポインタ（p_excinf）を引数と
///  して呼び出すことで，CPU例外の発生状況をシステムログに出力する．
///
fn xlog_sys(p_excinf: *T_EXCINF) void {
    syslog(LOG_EMERG, "pc = %08x, cpsr = %08x, lr = %08x, r12 = %08x",
           .{ p_excinf.pc, p_excinf.cpsr, p_excinf.lr, p_excinf.r12 });
    syslog(LOG_EMERG, "r0 = %08x, r1 = %08x, r2 = %08x, r3 = %08x",
           .{ p_excinf.r0, p_excinf.r1, p_excinf.r2, p_excinf.r3 });
    syslog(LOG_EMERG, "nest_count = %d, intpri = %d",
           .{ p_excinf.nest_count, p_excinf.intpri });
}

///
///  プリフェッチ／データアボートが発生した状況（状態とアドレス）をシ
///  ステムログに出力する．
///
fn xlog_fsr(fsr: u32, far: u32) void {
    var status: [*:0]const u8 = undefined;

    switch (fsr & arm.CP15_FSR_FS_MASK) {
        arm.CP15_FSR_FS_ALIGNMENT => {
            status = "alignment fault";
        },
        arm.CP15_FSR_FS_TRANSLATION1 => {
            status = "translation fault (1st level)";
        },
        arm.CP15_FSR_FS_TRANSLATION2 => {
            status = "translation fault (2nd level)";
        },
        arm.CP15_FSR_FS_PERMISSION1 => {
            status = "permission fault (1st level)";
        },
        arm.CP15_FSR_FS_PERMISSION2 => {
            status = "permission fault (2nd level)";
        },
        else => {
            status = "other fault";
        },
    }
    syslog(LOG_EMERG, "Fault status: 0x%04x (%s)", .{ fsr, status });
    syslog(LOG_EMERG, "Fault address: 0x%08x", .{ far });
}

///
///  未定義の割込みが入った場合の処理
///
fn default_int_handler() callconv(.C) void {
    syslog(LOG_EMERG, "Unregistered interrupt occurs.", .{});
    startup.ext_ker();
}

///
///  未定義の例外が入った場合の処理
///
fn default_exc_handler(p_excinf: *T_EXCINF, excno: EXCNO) void {
    if (OMIT_XLOG_SYS) {
        syslog(LOG_EMERG, "Unregistered exception %d occurs.", .{ excno });
    }
    else {
        switch (excno) {
            EXCNO_UNDEF => {
                syslog(LOG_EMERG,
                       "Undefined Instruction exception occurs.", .{});
            },
            EXCNO_SVC => {
                syslog(LOG_EMERG, "Supervisor Call exception occurs.", .{});
            },
            EXCNO_PABORT => {
                syslog(LOG_EMERG, "Prefetch Abort exception occurs.", .{});
            },
            EXCNO_DABORT => {
                syslog(LOG_EMERG, "Data Abort exception occurs.", .{});
            },
            EXCNO_IRQ => {
                syslog(LOG_EMERG, "IRQ exception occurs.", .{});
            },
            EXCNO_FIQ => {
                syslog(LOG_EMERG, "FIQ exception occurs.", .{});
            },
            EXCNO_FATAL => {
                syslog(LOG_EMERG, "Fatal Data Abort exception occurs.", .{});
            },
            else => {},
        }
        xlog_sys(p_excinf);

        if (excno == EXCNO_PABORT or excno == EXCNO_DABORT
                                  or excno == EXCNO_FATAL) {
            var fsr: u32 = undefined;
            var far: u32 = undefined;

            if (comptime arm.isEnabled(arm.Feature.has_v6)) {
                if (excno == EXCNO_PABORT) {
                    fsr = arm.CP15_READ_IFSR();
                    far = arm.CP15_READ_IFAR();
                }
                else {
                    fsr = arm.CP15_READ_DFSR();
                    far = arm.CP15_READ_DFAR();
                }
            }
            else {
                fsr = arm.CP15_READ_FSR();
                far = arm.CP15_READ_FAR();
            }
            xlog_fsr(fsr, far);
        }
    }
    startup.ext_ker();
}

//
//  例外ベクタテーブル
//
pub fn vector_table() linksection(".vector") callconv(.Naked) void {
    asm volatile(
     \\  ldr pc, reset_vector       // リセット
     \\  ldr pc, undef_vector       // 未定義命令
     \\  ldr pc, svc_vector         // ソフトウェア割込み
     \\  ldr pc, pabort_vector      // プリフェッチアボート
     \\  ldr pc, dabort_vector      // データアボート
     \\  ldr pc, reset_vector       // 未使用
     \\  ldr pc, irq_vector         // IRQ
     \\  ldr pc, fiq_vector         // FIQ
     \\
     \\ // 例外ベクタの命令から参照されるジャンプ先アドレス
     \\ reset_vector:
     \\  .long start
     \\ undef_vector:
     \\  .long undef_handler
     \\ svc_vector:
     \\  .long svc_handler
     \\ pabort_vector:
     \\  .long pabort_handler
     \\ dabort_vector:
     \\  .long dabort_handler
     \\ irq_vector:
     \\  .long irq_handler
     \\ fiq_vector:
     \\  .long fiq_handler
     :
     : [irq_handler] "s" (irq_handler),
       [exc_entry] "s" (exc_entry),
    );
}

///
///  コア依存部からexportする関数
///
pub const CoreExportDefs = struct {
    ///
    ///  未定義の割込みが入った場合の処理
    ///
    export fn _kernel_default_int_handler() void {
        default_int_handler();
    }

    ///
    ///  未定義の例外が入った場合の処理
    ///
    export fn _kernel_default_exc_handler(p_excinf: *T_EXCINF,
                                          excno: EXCNO) void {
        default_exc_handler(p_excinf, excno);
    }

    ///
    ///  非タスクコンテキスト用のスタックの初期値
    ///
    export var _kernel_istkpt: [*]u8 = undefined;

    ///
    ///  オーバランタイマの動作開始
    ///
    ///  この関数は，アセンブリコードから呼び出すために用意している．
    ///
    export fn _kernel_overrun_start() void {
        overrun.overrun_start();
    }

    ///
    ///  オーバランタイマの停止
    ///
    ///  この関数は，アセンブリコードから呼び出すために用意している．
    ///
    export fn _kernel_overrun_stop() void {
        overrun.overrun_stop();
    }

    ///
    ///  実行時間分布集計サービス向けの関数
    ///
    export fn arm_invalidate_all() void {
        arm.invalidate_all();
    }
};
