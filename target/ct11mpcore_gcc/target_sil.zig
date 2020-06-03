///
///  sil.zigのターゲット依存部（CT11MPCore用）
///

///
///  微少時間待ちのための定義
///
const DLY_TIM1 = 26;
const DLY_TIM2 = 2;

///
///  コア依存部
///
pub usingnamespace @import("../../arch/arm_gcc/common/core_sil.zig");

///
///  微少時間待ち
///
///  キャッシュラインのどの場所にあるかのよって実行時間が変わるため，
///  大きめの単位でアラインしている．インライン展開されると，アライン
///  指定が無効になるため，インライン展開しないようにしている．
///
pub noinline fn dly_nse(dlytim: usize) align(256) void {
    core_dly_nse(dlytim, DLY_TIM1, DLY_TIM2);
}
