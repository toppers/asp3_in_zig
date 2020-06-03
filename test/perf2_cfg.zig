///
///  カーネル性能評価プログラム(2)のシステムコンフィギュレーション記述
///
///  $Id$
///
usingnamespace @import("../kernel/kernel_cfg.zig");

const tecs = @import("../" ++ TECSGENDIR ++ "/tecsgen_cfg.zig");

usingnamespace @cImport({
    @cDefine("UINT_C(val)", "val");
    @cInclude("perf2.h");
});

fn configuration(comptime cfg: *CfgData) void {
    tecs.configuration(cfg);
    cfg.CRE_TSK("MAIN_TASK", CTSK(TA_ACT, 0, main_task, MAIN_PRIORITY,
                                  STACK_SIZE, null));
    cfg.CRE_PDQ("PDQ1", CPDQ(TA_NULL, 301, 16, null));
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
