///
///  sil.zigのコア依存部（ARM用）
///

///
///  用いるライブラリ
///
const arm = @import("arm.zig");

///
///  すべての割込み（FIQとIRQ）の禁止
///
fn disint() u32 {
    var cpsr = arm.current_cpsr();
    const fiq_irq = cpsr & arm.CPSR_INT_MASK;
    if (comptime arm.isEnabled(arm.Feature.has_v6)) {
        arm.disable_fiq_irq();
    }
    else {
        cpsr |= arm.CPSR_FIQ_IRQ_BIT;
        arm.set_cpsr(cpsr);
    }
    arm.memory_changed();
    return fiq_irq;
}

///
///  FIQとIRQの禁止ビットの復帰
///
fn set_fiq_irq(fiq_irq: u32) void {
    arm.memory_changed();
    var cpsr = arm.current_cpsr();
    cpsr &= ~@as(u32, arm.CPSR_INT_MASK);
    cpsr |= fiq_irq;
    arm.set_cpsr(cpsr);
}

///
///  全割込みロック状態の制御
///
pub fn PRE_LOC() u32 {
    return 0;
}
pub fn LOC_INT(p_lock: *u32) void {
    p_lock.* = disint();
}
pub fn UNL_INT(p_lock: *u32) void {
    set_fiq_irq(p_lock.*);
}

///
///  メモリ同期バリア
///
pub const write_sync = arm.data_sync_barrier;

///
///  微少時間待ち
///
pub fn core_dly_nse(dlytim: usize, comptime dly_tim1: usize,
                                   comptime dly_tim2: usize) void {
    asm volatile(
        \\ // dlytimはr0に入っている
        \\  mov r1, #0
        \\  mcr p15, 0, r1, c7, c5, 6   // 分岐予測全体の無効化
        ++ "\n" ++
        arm.asm_inst_sync_barrier("r3")
        ++ "\n" ++
        \\  subs r0, r0, %[dly_tim1]
        \\  bxls lr
        \\ .Lcore_dly_nse1:
        \\  mcr p15, 0, r1, c7, c5, 6   // 分岐予測全体の無効化
        ++ "\n" ++
        arm.asm_inst_sync_barrier("r3")
        ++ "\n" ++
        \\  subs r0, r0, %[dly_tim2]
        \\  bhi .Lcore_dly_nse1
        :
        : [dlytim] "{r0}" (dlytim),
          [dly_tim1] "i" (dly_tim1),
          [dly_tim2] "i" (dly_tim2),
    );
}
