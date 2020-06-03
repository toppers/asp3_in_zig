///
///  サンプルプログラム(1)のシステムコンフィギュレーション記述
///
///  $Id$
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
    @cInclude("tSample2.h");
});

///
///  システムコンフィギュレーション記述本体
///
fn configuration(comptime cfg: *CfgData) void {
    tecs.configuration(cfg);
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
