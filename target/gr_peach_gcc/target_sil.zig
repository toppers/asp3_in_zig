///
///  sil.zigのターゲット依存部（GR-PEACH用）
///

///
///  微少時間待ちのための定義
///
const DLY_TIM1 = 110;
const DLY_TIM2 = 72;

///
///  コア依存部（チップ依存部は飛ばす）
///
pub usingnamespace @import("../../arch/arm_gcc/common/core_sil.zig");

///
///  微少時間待ち
///
///  ダブルワード（64ビット）のどちらに命令があるかのよって実行時間が
///  変わる可能性があると考え，64ビット境界にアラインしている．インラ
///  イン展開されると，アライン指定が無効になるため，インライン展開し
///  ないようにしている．
///
pub noinline fn dly_nse(dlytim: usize) align(8) void {
    core_dly_nse(dlytim, DLY_TIM1, DLY_TIM2);
}
