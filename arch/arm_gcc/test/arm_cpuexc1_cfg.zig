///
///  ARM向けCPU例外処理のテスト(1)のシステムコンフィギュレーション記述
///
///  $Id$
///
usingnamespace @import("../../../kernel/kernel_cfg.zig");

const tecs = @import("../../../" ++ TECSGENDIR ++ "/tecsgen_cfg.zig");

usingnamespace @cImport({
    @cDefine("UINT_C(val)", "val");
    @cInclude("test_common.h");
});

fn configuration(comptime cfg: *CfgData) void {
    tecs.configuration(cfg);
    cfg.CRE_TSK("TASK1", CTSK(TA_ACT, 1, task1, MID_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK2", CTSK(TA_NULL, 2, task2, HIGH_PRIORITY,
                              STACK_SIZE, null));
    cfg.DEF_EXC(EXCNO_UNDEF, DEXC(TA_NULL, cpuexc1_handler));
    cfg.DEF_EXC(EXCNO_SVC, DEXC(TA_NULL, cpuexc2_handler));
    cfg.DEF_EXC(EXCNO_PABORT, DEXC(TA_NULL, cpuexc3_handler));
    cfg.DEF_EXC(EXCNO_DABORT, DEXC(TA_NULL, cpuexc4_handler));
    cfg.DEF_EXC(EXCNO_FATAL, DEXC(TA_NULL, cpuexc5_handler));
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
