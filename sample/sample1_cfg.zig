///
///  サンプルプログラム(1)のシステムコンフィギュレーション記述
///
usingnamespace @import("../kernel/kernel_cfg.zig");

///
///  TECSが生成するコンフィギュレーション記述
///
const tecs = @import("../" ++ TECSGENDIR ++ "/tecsgen_cfg.zig");

///
///  C言語ヘッダファイルの取り込み
///
usingnamespace @cImport({
    @cDefine("UINT_C(val)", "val");
    @cInclude("sample1.h");
});

///
///  システムコンフィギュレーション記述本体
///
fn configuration(comptime cfg: *CfgData) void {
    tecs.configuration(cfg);
    cfg.CRE_TSK("TASK1", CTSK(TA_NULL, 1, task, MID_PRIORITY,
                              STACK_SIZE, null));
//  代案
//  cfg.CRE_TSK("TASK1", .{ .exinf = @castToExinf(1),
//                          .task = task,
//                          .itskpri = MID_PRIORITY,
//                          .stksz = STACK_SIZE, });
    cfg.CRE_TSK("TASK2", CTSK(TA_NULL, 2, task, MID_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK3", CTSK(TA_NULL, 3, task, MID_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("MAIN_TASK", CTSK(TA_ACT, 0, main_task, MAIN_PRIORITY,
                                  STACK_SIZE, null));
    cfg.CRE_TSK("EXC_TASK", CTSK(TA_NULL, 0, exc_task, EXC_PRIORITY,
                                 STACK_SIZE, null));
    cfg.CRE_CYC("CYCHDR1", CCYC(TA_NULL, NFY_TMEHDR(0, cyclic_handler),
                                2_000_000, 0));
//    cfg.CRE_CYC("CYCHDR1", CCYC(TA_NULL,
//                                NFYINFO(.{ TNFY_ACTTSK, "TASK1" }, cfg),
//                                2_000_000, 0));
    cfg.CRE_ALM("ALMHDR1", CALM(TA_NULL, NFY_TMEHDR(0, alarm_handler)));
    if (zig.TOPPERS_SUPPORT_OVRHDR) {
        cfg.DEF_OVR(DOVR(TA_NULL, overrun_handler));
    }
    if (@hasDecl(option.target._test, "INTNO1")) {
        cfg.CFG_INT(option.target._test.INTNO1,
                    CINT(option.target._test.INTNO1_INTATR,
                         option.target._test.INTNO1_INTPRI));
        cfg.CRE_ISR("INTNO1_ISR",
                    CISR(TA_NULL, 0, option.target._test.INTNO1,
                         intno1_isr, 1));
    }
    if (@hasDecl(option.target._test, "CPUEXC1")) {
        cfg.DEF_EXC(option.target._test.CPUEXC1,
                    DEXC(TA_NULL, cpuexc_handler));
    }
}

//
//  静的APIの読み込みとコンフィギュレーションデータの生成
//
//  以下は変更する必要がない．
//
//  genConfigにvoid型のパラメータを渡すのは，Zigコンパイラの不具合の回
//  避のため（これがないと，genConfigが2回実行される）．
//
//  genConfigをpubにするのは，BIND_CFGに対応するため．
//
pub fn genConfig(comptime dummy: void) type {
    comptime var cfg = CfgData{};
    target.configuration(&cfg);
    configuration(&cfg);
    return GenCfgData(&cfg);
}
export const _ = if (@hasDecl(@This(), "BIND_CFG")) {} else genConfig({}){};
