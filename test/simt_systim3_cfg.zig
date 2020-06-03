///
///  システム時刻管理機能のテスト(3)のシステムコンフィギュレーション記
///  述
///
///  $Id$
///
usingnamespace @import("../kernel/kernel_cfg.zig");

const tecs = @import("../" ++ TECSGENDIR ++ "/tecsgen_cfg.zig");

usingnamespace @cImport({
    @cDefine("UINT_C(val)", "val");
    @cInclude("simt_systim3.h");
});

fn configuration(comptime cfg: *CfgData) void {
    tecs.configuration(cfg);
    cfg.CRE_TSK("TASK1", CTSK(TA_ACT, 1, task1, MID_PRIORITY,
                              STACK_SIZE, null));
    cfg.CRE_CYC("CYC1", CCYC(TA_STA, NFY_TMEHDR(1, cyclic1_handler), 1000, 0));
    cfg.CRE_CYC("CYC2", CCYC(TA_STA, NFY_TMEHDR(1, cyclic2_handler), 500, 499));
    cfg.CRE_ALM("ALM1", CALM(TA_NULL, NFY_TMEHDR(1, alarm1_handler)));
    cfg.CRE_ALM("ALM2", CALM(TA_NULL, NFY_TMEHDR(1, alarm2_handler)));
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
