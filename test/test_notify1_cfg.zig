///
///  通知処理のテスト(1)のシステムコンフィギュレーション記述
///
///  $Id$
///
usingnamespace @import("../kernel/kernel_cfg.zig");

const tecs = @import("../" ++ TECSGENDIR ++ "/tecsgen_cfg.zig");

usingnamespace @cImport({
    @cDefine("UINT_C(val)", "val");
    @cInclude("test_notify1.h");
});

const p_event_variable = importSymbol(usize, "event_variable");
const p_count_variable = importSymbol(usize, "count_variable");
const p_error_variable = importSymbol(isize, "error_variable");

fn configuration(comptime cfg: *CfgData) void {
    tecs.configuration(cfg);
    cfg.CRE_TSK("TASK1", CTSK(TA_ACT, 1, task1, MID_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK2", CTSK(TA_NULL, 2, task2, LOW_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_SEM("SEM1", CSEM(TA_NULL, 0, 1));
    cfg.CRE_FLG("FLG1", CFLG(TA_NULL, 0x00));
    cfg.CRE_DTQ("DTQ1", CDTQ(TA_NULL, 1, null));
    cfg.CRE_ALM("ALM1", CALM(TA_NULL, NFYINFO(.{ TNFY_SETVAR,
                                                p_event_variable, 1 }, cfg)));
    cfg.CRE_ALM("ALM2", CALM(TA_NULL, NFYINFO(.{ TNFY_ACTTSK, "TASK2" }, cfg)));
    cfg.CRE_ALM("ALM3", CALM(TA_NULL, NFYINFO(.{ TNFY_WUPTSK|TENFY_SETVAR,
                                            "TASK2", p_error_variable }, cfg)));
    cfg.CRE_ALM("ALM4", CALM(TA_NULL, NFYINFO(.{ TNFY_SIGSEM|TENFY_ACTTSK,
                                                "SEM1", "TASK2" }, cfg)));
    cfg.CRE_ALM("ALM5", CALM(TA_NULL, NFYINFO(.{ TNFY_SETFLG,
                                                "FLG1", 0x01 }, cfg)));
    cfg.CRE_ALM("ALM6", CALM(TA_NULL, NFYINFO(.{ TNFY_SNDDTQ|TENFY_WUPTSK,
                                                "DTQ1", 0x01, "TASK2" }, cfg)));
    cfg.CRE_ALM("ALM7", CALM(TA_NULL, NFYINFO(.{ TNFY_ACTTSK|TENFY_SIGSEM,
                                                "TASK2", "SEM1" }, cfg)));
    cfg.CRE_ALM("ALM8", CALM(TA_NULL, NFYINFO(.{ TNFY_ACTTSK|TENFY_SETFLG,
                                                "TASK2", "FLG1", 0x02 }, cfg)));
    cfg.CRE_ALM("ALM9", CALM(TA_NULL, NFYINFO(.{ TNFY_ACTTSK|TENFY_SNDDTQ,
                                                "TASK2", "DTQ1" }, cfg)));
    cfg.CRE_ALM("ALM10", CALM(TA_NULL, NFYINFO(.{ TNFY_INCVAR,
                                                 p_count_variable }, cfg)));
    cfg.CRE_ALM("ALM11", CALM(TA_NULL, NFYINFO(.{ TNFY_ACTTSK|TENFY_INCVAR,
                                            "TASK2", p_count_variable }, cfg)));
}

//
//  静的APIの読み込みとコンフィギュレーションデータの生成
//
//  以下は変更する必要がない．
//
//  genConfigにvoid型のパラメータを渡すのは，Zigコンパイラの不具合の回
//  避のため（これがないと，genConfigが2回実行される）．
//
fn genConfig(comptime dummy: void) type {
    comptime var cfg = CfgData{};
    target.configuration(&cfg);
    configuration(&cfg);
    return GenCfgData(&cfg);
}
export const _ = genConfig({}){};
