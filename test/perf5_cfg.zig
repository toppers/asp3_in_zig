///
///  カーネル性能評価プログラム(5)のシステムコンフィギュレーション記述
///
///  $Id$
///
usingnamespace @import("../kernel/kernel_cfg.zig");

const tecs = @import("../" ++ TECSGENDIR ++ "/tecsgen_cfg.zig");

usingnamespace @cImport({
    @cDefine("UINT_C(val)", "val");
    @cInclude("perf5.h");
});

fn configuration(comptime cfg: *CfgData) void {
    tecs.configuration(cfg);
    cfg.CRE_ALM("ALM0", CALM(TA_NULL, NFY_TMEHDR(0, alarm_handler)));
    cfg.CRE_ALM("ALM1", CALM(TA_NULL, NFY_TMEHDR(1, alarm_handler)));
    cfg.CRE_ALM("ALM2", CALM(TA_NULL, NFY_TMEHDR(2, alarm_handler)));
    cfg.CRE_ALM("ALM3", CALM(TA_NULL, NFY_TMEHDR(3, alarm_handler)));
    cfg.CRE_ALM("ALM4", CALM(TA_NULL, NFY_TMEHDR(4, alarm_handler)));
    cfg.CRE_ALM("ALM5", CALM(TA_NULL, NFY_TMEHDR(5, alarm_handler)));
    cfg.CRE_ALM("ALM6", CALM(TA_NULL, NFY_TMEHDR(6, alarm_handler)));
    cfg.CRE_ALM("ALM7", CALM(TA_NULL, NFY_TMEHDR(7, alarm_handler)));
    cfg.CRE_ALM("ALM8", CALM(TA_NULL, NFY_TMEHDR(8, alarm_handler)));
    cfg.CRE_ALM("ALM9", CALM(TA_NULL, NFY_TMEHDR(9, alarm_handler)));
    cfg.CRE_ALM("ALM10", CALM(TA_NULL, NFY_TMEHDR(10, alarm_handler)));
    cfg.CRE_ALM("ALM11", CALM(TA_NULL, NFY_TMEHDR(11, alarm_handler)));
    cfg.CRE_ALM("ALM12", CALM(TA_NULL, NFY_TMEHDR(12, alarm_handler)));
    cfg.CRE_ALM("ALM13", CALM(TA_NULL, NFY_TMEHDR(13, alarm_handler)));
    cfg.CRE_ALM("ALM14", CALM(TA_NULL, NFY_TMEHDR(14, alarm_handler)));
    cfg.CRE_ALM("ALM15", CALM(TA_NULL, NFY_TMEHDR(15, alarm_handler)));
    cfg.CRE_ALM("ALM16", CALM(TA_NULL, NFY_TMEHDR(16, alarm_handler)));
    cfg.CRE_ALM("ALM17", CALM(TA_NULL, NFY_TMEHDR(17, alarm_handler)));
    cfg.CRE_ALM("ALM18", CALM(TA_NULL, NFY_TMEHDR(18, alarm_handler)));
    cfg.CRE_ALM("ALM19", CALM(TA_NULL, NFY_TMEHDR(19, alarm_handler)));
    cfg.CRE_ALM("ALM20", CALM(TA_NULL, NFY_TMEHDR(20, alarm_handler)));
    cfg.CRE_ALM("ALM21", CALM(TA_NULL, NFY_TMEHDR(21, alarm_handler)));
    cfg.CRE_ALM("ALM22", CALM(TA_NULL, NFY_TMEHDR(22, alarm_handler)));
    cfg.CRE_ALM("ALM23", CALM(TA_NULL, NFY_TMEHDR(23, alarm_handler)));
    cfg.CRE_ALM("ALM24", CALM(TA_NULL, NFY_TMEHDR(24, alarm_handler)));
    cfg.CRE_ALM("ALM25", CALM(TA_NULL, NFY_TMEHDR(25, alarm_handler)));
    cfg.CRE_ALM("ALM26", CALM(TA_NULL, NFY_TMEHDR(26, alarm_handler)));
    cfg.CRE_ALM("ALM27", CALM(TA_NULL, NFY_TMEHDR(27, alarm_handler)));
    cfg.CRE_ALM("ALM28", CALM(TA_NULL, NFY_TMEHDR(28, alarm_handler)));
    cfg.CRE_ALM("ALM29", CALM(TA_NULL, NFY_TMEHDR(29, alarm_handler)));
    cfg.CRE_ALM("ALM30", CALM(TA_NULL, NFY_TMEHDR(30, alarm_handler)));
    cfg.CRE_ALM("ALM31", CALM(TA_NULL, NFY_TMEHDR(31, alarm_handler)));
    cfg.CRE_ALM("ALM32", CALM(TA_NULL, NFY_TMEHDR(32, alarm_handler)));
    cfg.CRE_ALM("ALM33", CALM(TA_NULL, NFY_TMEHDR(33, alarm_handler)));
    cfg.CRE_ALM("ALM34", CALM(TA_NULL, NFY_TMEHDR(34, alarm_handler)));
    cfg.CRE_ALM("ALM35", CALM(TA_NULL, NFY_TMEHDR(35, alarm_handler)));
    cfg.CRE_ALM("ALM36", CALM(TA_NULL, NFY_TMEHDR(36, alarm_handler)));
    cfg.CRE_ALM("ALM37", CALM(TA_NULL, NFY_TMEHDR(37, alarm_handler)));
    cfg.CRE_ALM("ALM38", CALM(TA_NULL, NFY_TMEHDR(38, alarm_handler)));
    cfg.CRE_ALM("ALM39", CALM(TA_NULL, NFY_TMEHDR(39, alarm_handler)));
    cfg.CRE_ALM("ALM40", CALM(TA_NULL, NFY_TMEHDR(40, alarm_handler)));
    cfg.CRE_ALM("ALM41", CALM(TA_NULL, NFY_TMEHDR(41, alarm_handler)));
    cfg.CRE_ALM("ALM42", CALM(TA_NULL, NFY_TMEHDR(42, alarm_handler)));
    cfg.CRE_ALM("ALM43", CALM(TA_NULL, NFY_TMEHDR(43, alarm_handler)));
    cfg.CRE_ALM("ALM44", CALM(TA_NULL, NFY_TMEHDR(44, alarm_handler)));
    cfg.CRE_ALM("ALM45", CALM(TA_NULL, NFY_TMEHDR(45, alarm_handler)));
    cfg.CRE_ALM("ALM46", CALM(TA_NULL, NFY_TMEHDR(46, alarm_handler)));
    cfg.CRE_ALM("ALM47", CALM(TA_NULL, NFY_TMEHDR(47, alarm_handler)));
    cfg.CRE_ALM("ALM48", CALM(TA_NULL, NFY_TMEHDR(48, alarm_handler)));
    cfg.CRE_ALM("ALM49", CALM(TA_NULL, NFY_TMEHDR(49, alarm_handler)));
    cfg.CRE_ALM("ALM50", CALM(TA_NULL, NFY_TMEHDR(50, alarm_handler)));
    cfg.CRE_ALM("ALM51", CALM(TA_NULL, NFY_TMEHDR(51, alarm_handler)));
    cfg.CRE_ALM("ALM52", CALM(TA_NULL, NFY_TMEHDR(52, alarm_handler)));
    cfg.CRE_ALM("ALM53", CALM(TA_NULL, NFY_TMEHDR(53, alarm_handler)));
    cfg.CRE_ALM("ALM54", CALM(TA_NULL, NFY_TMEHDR(54, alarm_handler)));
    cfg.CRE_ALM("ALM55", CALM(TA_NULL, NFY_TMEHDR(55, alarm_handler)));
    cfg.CRE_ALM("ALM56", CALM(TA_NULL, NFY_TMEHDR(56, alarm_handler)));
    cfg.CRE_ALM("ALM57", CALM(TA_NULL, NFY_TMEHDR(57, alarm_handler)));
    cfg.CRE_ALM("ALM58", CALM(TA_NULL, NFY_TMEHDR(58, alarm_handler)));
    cfg.CRE_ALM("ALM59", CALM(TA_NULL, NFY_TMEHDR(59, alarm_handler)));
    cfg.CRE_ALM("ALM60", CALM(TA_NULL, NFY_TMEHDR(60, alarm_handler)));
    cfg.CRE_ALM("ALM61", CALM(TA_NULL, NFY_TMEHDR(61, alarm_handler)));
    cfg.CRE_ALM("ALM62", CALM(TA_NULL, NFY_TMEHDR(62, alarm_handler)));
    cfg.CRE_ALM("ALM63", CALM(TA_NULL, NFY_TMEHDR(63, alarm_handler)));
    cfg.CRE_ALM("ALM64", CALM(TA_NULL, NFY_TMEHDR(64, alarm_handler)));
    cfg.CRE_ALM("ALM65", CALM(TA_NULL, NFY_TMEHDR(65, alarm_handler)));
    cfg.CRE_ALM("ALM66", CALM(TA_NULL, NFY_TMEHDR(66, alarm_handler)));
    cfg.CRE_ALM("ALM67", CALM(TA_NULL, NFY_TMEHDR(67, alarm_handler)));
    cfg.CRE_ALM("ALM68", CALM(TA_NULL, NFY_TMEHDR(68, alarm_handler)));
    cfg.CRE_ALM("ALM69", CALM(TA_NULL, NFY_TMEHDR(69, alarm_handler)));
    cfg.CRE_ALM("ALM70", CALM(TA_NULL, NFY_TMEHDR(70, alarm_handler)));
    cfg.CRE_ALM("ALM71", CALM(TA_NULL, NFY_TMEHDR(71, alarm_handler)));
    cfg.CRE_ALM("ALM72", CALM(TA_NULL, NFY_TMEHDR(72, alarm_handler)));
    cfg.CRE_ALM("ALM73", CALM(TA_NULL, NFY_TMEHDR(73, alarm_handler)));
    cfg.CRE_ALM("ALM74", CALM(TA_NULL, NFY_TMEHDR(74, alarm_handler)));
    cfg.CRE_ALM("ALM75", CALM(TA_NULL, NFY_TMEHDR(75, alarm_handler)));
    cfg.CRE_ALM("ALM76", CALM(TA_NULL, NFY_TMEHDR(76, alarm_handler)));
    cfg.CRE_ALM("ALM77", CALM(TA_NULL, NFY_TMEHDR(77, alarm_handler)));
    cfg.CRE_ALM("ALM78", CALM(TA_NULL, NFY_TMEHDR(78, alarm_handler)));
    cfg.CRE_ALM("ALM79", CALM(TA_NULL, NFY_TMEHDR(79, alarm_handler)));
    cfg.CRE_ALM("ALM80", CALM(TA_NULL, NFY_TMEHDR(80, alarm_handler)));
    cfg.CRE_ALM("ALM81", CALM(TA_NULL, NFY_TMEHDR(81, alarm_handler)));
    cfg.CRE_ALM("ALM82", CALM(TA_NULL, NFY_TMEHDR(82, alarm_handler)));
    cfg.CRE_ALM("ALM83", CALM(TA_NULL, NFY_TMEHDR(83, alarm_handler)));
    cfg.CRE_ALM("ALM84", CALM(TA_NULL, NFY_TMEHDR(84, alarm_handler)));
    cfg.CRE_ALM("ALM85", CALM(TA_NULL, NFY_TMEHDR(85, alarm_handler)));
    cfg.CRE_ALM("ALM86", CALM(TA_NULL, NFY_TMEHDR(86, alarm_handler)));
    cfg.CRE_ALM("ALM87", CALM(TA_NULL, NFY_TMEHDR(87, alarm_handler)));
    cfg.CRE_ALM("ALM88", CALM(TA_NULL, NFY_TMEHDR(88, alarm_handler)));
    cfg.CRE_ALM("ALM89", CALM(TA_NULL, NFY_TMEHDR(89, alarm_handler)));
    cfg.CRE_ALM("ALM90", CALM(TA_NULL, NFY_TMEHDR(90, alarm_handler)));
    cfg.CRE_TSK("MAIN_TASK", CTSK(TA_ACT, 0, main_task, MAIN_PRIORITY,
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
    @setEvalBranchQuota(10000);
    comptime var cfg = CfgData{};
    target.configuration(&cfg);
    configuration(&cfg);
    return GenCfgData(&cfg);
}
export const _ = genConfig({}){};
