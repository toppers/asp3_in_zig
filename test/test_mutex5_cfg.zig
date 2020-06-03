///
///  ミューテックスのテスト(5)のシステムコンフィギュレーション記述
///
///  $Id$
///
usingnamespace @import("../kernel/kernel_cfg.zig");

const tecs = @import("../" ++ TECSGENDIR ++ "/tecsgen_cfg.zig");

usingnamespace @cImport({
    @cDefine("UINT_C(val)", "val");
    @cInclude("test_mutex5.h");
});

fn configuration(comptime cfg: *CfgData) void {
    tecs.configuration(cfg);
    cfg.CRE_TSK("TASK1", CTSK(TA_ACT, 1, task1, LOW_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK2", CTSK(TA_NULL, 2, task2, LOW_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK3", CTSK(TA_NULL, 3, task3, MID_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK4", CTSK(TA_NULL, 4, task4, MID_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK5", CTSK(TA_NULL, 5, task5, HIGH_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_MTX("MTX1", CMTX(TA_CEILING, MID_PRIORITY));
    cfg.CRE_MTX("MTX2", CMTX(TA_CEILING, MID_PRIORITY));
    cfg.CRE_MTX("MTX3", CMTX(TA_CEILING, LOW_PRIORITY));
    cfg.CRE_MTX("MTX4", CMTX(TA_CEILING, HIGH_PRIORITY));
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
