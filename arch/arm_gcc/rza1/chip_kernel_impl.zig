///
///  カーネルのチップ依存部（RZ/A1用）
///
usingnamespace @import("../../../kernel/kernel_impl.zig");

///
///  コンフィギュレーションオプションの取り込み
///
const GIC_ARM11MPCORE =
    if (@hasDecl(option.target, "GIC_ARM11MPCORE"))
        option.target.GIC_ARM11MPCORE
    else false;

///
///  RZ/A1のハードウェア資源の定義
///
const rza1 = @import("rza1.zig");

///
///  用いるライブラリ
///
const arm = @import("../common/arm.zig");

///
///  デフォルトの非タスクコンテキスト用のスタック領域の定義
///
pub const DEFAULT_ISTKSZ = 0x2000;

///
///  GIC 390 Errataへの対策を実施
///
pub const GIC_PL390_ERRATA = true;

///
///  MPCore依存部
///
///  GICレジスタのベースアドレスなどがMPCoreの標準と異なるため，MPCore
///  依存部をusingnamespaceで取り込むと，定義が衝突する．
///
pub const mpcore = @import("../common/mpcore_kernel_impl.zig");
pub const mpcore_initialize = mpcore.mpcore_initialize;
pub const mpcore_terminate = mpcore.mpcore_terminate;
pub const TNUM_INTNO = mpcore.TNUM_INTNO;
pub const TMAX_INTNO = mpcore.TMIN_INTNO;
pub const TMIN_INTNO = mpcore.TMAX_INTNO;
pub const externalIpm = mpcore.externalIpm;
pub const internalIpm = mpcore.internalIpm;
pub const validIntno = mpcore.validIntno;
pub const validInhno = mpcore.validInhno;
pub const USE_INTINIB_TABLE = mpcore.USE_INTINIB_TABLE;
pub const USE_INTCFG_TABLE = mpcore.USE_INTCFG_TABLE;
pub const checkIntnoCfg = mpcore.checkIntnoCfg;
pub const setIpm = mpcore.setIpm;
pub const getIpm = mpcore.getIpm;
pub const validIntnoDisInt = mpcore.validIntnoDisInt;
pub const disableInt = mpcore.disableInt;
pub const enableInt = mpcore.enableInt;
pub const validIntnoClrInt = mpcore.validIntnoClrInt;
pub const checkIntnoClear = mpcore.checkIntnoClear;
pub const clearInt = mpcore.clearInt;
pub const checkIntnoRaise = mpcore.checkIntnoRaise;
pub const raiseInt = mpcore.raiseInt;
pub const probeInt = mpcore.probeInt;
pub const irc_begin_int = mpcore.irc_begin_int;
pub const irc_end_int = mpcore.irc_end_int;
pub const irc_get_intpri = mpcore.irc_get_intpri;
pub const irc_begin_exc = mpcore.irc_begin_exc;
pub const irc_end_exc = mpcore.irc_end_exc;

///
///  コア依存部
///
///  MPCore依存部をusingnamespaceで取り込めないため，コア依存部を取り
///  込む．
///
pub usingnamespace @import("../common/core_kernel_impl.zig");

///
///  L2キャッシュコントローラ（PL310）の操作ライブラリ
///
const pl310 = @import("../common/pl310.zig");

///
///  チップ依存の初期化
///
pub fn chip_initialize() void {
    // MPCore依存の初期化
    mpcore_initialize();

    // L2キャッシュコントローラ（PL310）の初期化
    pl310.initialize(0x0, ~@as(u32, 0x0));
}

///
///  チップ依存の終了処理
///
pub fn chip_terminate() void {
    // MPCore依存の終了処理
    mpcore_terminate();
}

///
///  割込み要求ラインの属性の設定
///
///  ASPカーネルでの利用を想定して，パラメータエラーはアサーションで
///  チェックしている．
///
pub fn config_int(intno: INTNO, intatr: ATR, intpri: PRI) void {
    assert(validIntno(intno));
    assert(TMIN_INTPRI <= intpri and intpri <= TMAX_INTPRI);

    //  割込みを禁止
    //
    //  割込みを受け付けたまま，レベルトリガ／エッジトリガの設定や，割
    //  込み優先度の設定を行うのは危険なため，割込み属性にかかわらず，
    //  一旦マスクする．
    disableInt(intno);

    // 割込みをコンフィギュレーション
    if (rza1.INTNO_IRQ0 <= intno and intno <= rza1.INTNO_IRQ7) {
        var reg = sil.reh_mem(rza1.RZA1_ICR1);
        reg &= ~(@as(u16, 0x03) << @intCast(u4, (intno - rza1.INTNO_IRQ0) * 2));
        reg |= (@intCast(u16, intatr >> 2)
                                << @intCast(u4, (intno - rza1.INTNO_IRQ0) * 2));
        sil.wrh_mem(rza1.RZA1_ICR1, reg);
    }

    if ((intatr & TA_EDGE) != 0) {
        if (GIC_ARM11MPCORE) {
            mpcore.gicd_config(intno, mpcore.GICD_ICFGRn_EDGE
                                    | mpcore.GICD_ICFGRn_1_N);
        }
        else {
            mpcore.gicd_config(intno, mpcore.GICD_ICFGRn_EDGE);
        }
        target_impl.clearInt(intno);
    }
    else {
        if (GIC_ARM11MPCORE) {
            mpcore.gicd_config(intno, mpcore.GICD_ICFGRn_LEVEL
                                    | mpcore.GICD_ICFGRn_1_N);
        }
        else {
            mpcore.gicd_config(intno, mpcore.GICD_ICFGRn_LEVEL);
        }
    }

    // 割込み優先度とターゲットプロセッサを設定
    mpcore.gicd_set_priority(intno, internalIpm(intpri));
    mpcore.gicd_set_target(intno, @as(u32, 1)
                                    << @intCast(u5, arm.get_my_prcidx()));

    // 割込みを許可
    if ((intatr & TA_ENAINT) != 0) {
        enableInt(intno);
    }
}

///
///  割込み要求ライン初期化ブロック
///
const INTINIB = extern struct {
    intno: INTNO,               // 割込み番号
    intatr: ATR,                // 割込み属性
    intpri: PRI,                // 割込み優先度
};

///
///  設定する割込み要求ラインの数（kernel_cfg.c）
///
extern const _kernel_tnum_cfg_intno: c_uint;

///
///  割込み要求ライン初期化ブロックのエリア（kernel_cfg.c）
///
// zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
extern const _kernel_intinib_table: [100]INTINIB;

///
///  割込み管理機能の初期化
///
pub fn initialize_interrupt() void {
    for (_kernel_intinib_table[0 .. _kernel_tnum_cfg_intno]) |*p_intinib| {
        config_int(p_intinib.intno, p_intinib.intatr, p_intinib.intpri);
    }
}
