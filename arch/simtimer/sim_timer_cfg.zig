///
///  タイマドライバシミュレータのシステムコンフィギュレーション記述
///
usingnamespace @import("../../kernel/kernel_cfg.zig");
usingnamespace zig;

///
///  タイマドライバ
///
const sim_timer = @import("sim_timer.zig");
usingnamespace sim_timer.ExternDefs;

///
///  システムコンフィギュレーション記述
///
pub fn configuration(comptime cfg: *CfgData) void {
    // 高分解能タイマ，オーバランタイマ共通
    cfg.ATT_INI(AINI(TA_NULL, 0, _kernel_target_timer_initialize));
    cfg.ATT_TER(ATER(TA_NULL, 0, _kernel_target_timer_terminate));

    // 高分解能タイマドライバ
    cfg.CFG_INT(sim_timer.hrt.INTNO_HRT,
                CINT(TA_ENAINT | sim_timer.hrt.INTATR_HRT,
                     sim_timer.hrt.INTPRI_HRT));
    cfg.DEF_INH(sim_timer.hrt.INHNO_HRT,
                DINH(TA_NULL, _kernel_target_hrt_handler));

    // オーバランタイマドライバ
    if (TOPPERS_SUPPORT_OVRHDR) {
        cfg.CFG_INT(sim_timer.ovrtimer.INTNO_OVRTIMER,
                    CINT(TA_ENAINT | sim_timer.ovrtimer.INTATR_OVRTIMER,
                         sim_timer.ovrtimer.INTPRI_OVRTIMER));
        cfg.DEF_INH(sim_timer.ovrtimer.INHNO_OVRTIMER,
                    DINH(TA_NULL, _kernel_target_ovrtimer_handler));
    }
}
