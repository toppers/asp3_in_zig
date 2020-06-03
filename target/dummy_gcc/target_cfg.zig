///
///  システムコンフィギュレーション記述のターゲット依存部（ダミーターゲット用）
///
usingnamespace @import("../../kernel/kernel_cfg.zig");
usingnamespace zig;

///
///  タイマドライバ
///
const target_timer = @import("target_timer.zig");
usingnamespace target_timer.ExternDefs;

///
///  システムコンフィギュレーション記述
///
pub fn configuration(comptime cfg: *CfgData) void {
    // 高分解能タイマドライバ
    cfg.ATT_INI(AINI(TA_NULL, 0, _kernel_target_hrt_initialize));
    cfg.ATT_TER(ATER(TA_NULL, 0, _kernel_target_hrt_terminate));

    cfg.CFG_INT(target_timer.hrt.INTNO_HRT,
                CINT(TA_ENAINT | target_timer.hrt.INTATR_HRT,
                     target_timer.hrt.INTPRI_HRT));
    cfg.DEF_INH(target_timer.hrt.INHNO_HRT,
                DINH(TA_NULL, _kernel_target_hrt_handler));

    // オーバランタイマドライバ
    if (TOPPERS_SUPPORT_OVRHDR) {
        cfg.ATT_INI(AINI(TA_NULL, 0, _kernel_target_ovrtimer_initialize));
        cfg.ATT_TER(ATER(TA_NULL, 0, _kernel_target_ovrtimer_terminate));

        cfg.CFG_INT(target_timer.ovrtimer.INTNO_OVRTIMER,
                    CINT(TA_ENAINT | target_timer.ovrtimer.INTATR_OVRTIMER,
                         target_timer.ovrtimer.INTPRI_OVRTIMER));
        cfg.DEF_INH(target_timer.ovrtimer.INHNO_OVRTIMER,
                    DINH(TA_NULL, _kernel_target_ovrtimer_handler));
    }
}
