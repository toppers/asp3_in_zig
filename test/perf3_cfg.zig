///
///  カーネル性能評価プログラム(3)のシステムコンフィギュレーション記述
///
///  $Id$
///
usingnamespace @import("../kernel/kernel_cfg.zig");

const tecs = @import("../" ++ TECSGENDIR ++ "/tecsgen_cfg.zig");

usingnamespace @cImport({
    @cDefine("UINT_C(val)", "val");
    @cInclude("perf3.h");
});

fn configuration(comptime cfg: *CfgData) void {
    tecs.configuration(cfg);
    cfg.CRE_TSK("TASK1", CTSK(TA_NULL, 1, task, TASK_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK2", CTSK(TA_NULL, 2, task, TASK_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK3", CTSK(TA_NULL, 3, task, TASK_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK4", CTSK(TA_NULL, 4, task, TASK_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK5", CTSK(TA_NULL, 5, task, TASK_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK6", CTSK(TA_NULL, 6, task, TASK_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK7", CTSK(TA_NULL, 7, task, TASK_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK8", CTSK(TA_NULL, 8, task, TASK_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK9", CTSK(TA_NULL, 9, task, TASK_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_TSK("TASK10", CTSK(TA_NULL, 10, task, TASK_PRIORITY,
                               STACK_SIZE, null));
    cfg.CRE_TSK("TASK11", CTSK(TA_NULL, 11, task, TASK_PRIORITY,
                               STACK_SIZE, null));
    cfg.CRE_TSK("TASK12", CTSK(TA_NULL, 12, task, TASK_PRIORITY,
                               STACK_SIZE, null));
    cfg.CRE_TSK("TASK13", CTSK(TA_NULL, 13, task, TASK_PRIORITY,
                               STACK_SIZE, null));
    cfg.CRE_TSK("TASK14", CTSK(TA_NULL, 14, task, TASK_PRIORITY,
                               STACK_SIZE, null));
    cfg.CRE_TSK("TASK15", CTSK(TA_NULL, 15, task, TASK_PRIORITY,
                               STACK_SIZE, null));
    cfg.CRE_TSK("TASK16", CTSK(TA_NULL, 16, task, TASK_PRIORITY,
                               STACK_SIZE, null));
    cfg.CRE_TSK("TASK17", CTSK(TA_NULL, 17, task, TASK_PRIORITY,
                               STACK_SIZE, null));
    cfg.CRE_TSK("TASK18", CTSK(TA_NULL, 18, task, TASK_PRIORITY,
                               STACK_SIZE, null));
    cfg.CRE_TSK("TASK19", CTSK(TA_NULL, 19, task, TASK_PRIORITY,
                               STACK_SIZE, null));
    cfg.CRE_TSK("TASK20", CTSK(TA_NULL, 20, task, TASK_PRIORITY,
                               STACK_SIZE, null));
    cfg.CRE_TSK("MAIN_TASK", CTSK(TA_ACT, 0, main_task, MAIN_PRIORITY,
                                  STACK_SIZE, null));
    cfg.CRE_FLG("FLG1", CFLG(TA_WMUL, 0x00));
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
