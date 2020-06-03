///
///  fch_hrtに関するテスト(1)のシステムコンフィギュレーション記述
///
///  $Id$
///
usingnamespace @import("../kernel/kernel_cfg.zig");

const tecs = @import("../" ++ TECSGENDIR ++ "/tecsgen_cfg.zig");

usingnamespace @cImport({
    @cDefine("UINT_C(val)", "val");
    @cInclude("test_hrt1.h");
});

fn configuration(comptime cfg: *CfgData) void {
    tecs.configuration(cfg);
    cfg.CRE_CYC("CYC1", CCYC(TA_STA, NFY_TMEHDR(0, cyclic_handler),
                             CYC1_CYCLE, CYC1_CYCLE));
    cfg.CRE_TSK("TASK1", CTSK(TA_ACT, 0, main_task, MAIN_PRIORITY,
                              STACK_SIZE, null));
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
