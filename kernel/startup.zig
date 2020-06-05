///
///  TOPPERS/ASP Kernel
///      Toyohashi Open Platform for Embedded Real-Time Systems/
///      Advanced Standard Profile Kernel
/// 
///  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
///                                 Toyohashi Univ. of Technology, JAPAN
///  Copyright (C) 2005-2020 by Embedded and Real-Time Systems Laboratory
///                 Graduate School of Informatics, Nagoya Univ., JAPAN
///
///  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
///  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
///  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
///  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
///      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
///      スコード中に含まれていること．
///  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
///      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
///      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
///      の無保証規定を掲載すること．
///  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
///      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
///      と．
///    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
///        作権表示，この利用条件および下記の無保証規定を掲載すること．
///    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
///        報告すること．
///  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
///      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
///      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
///      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
///      免責すること．
///
///  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
///  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
///  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
///  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
///  の責任を負わない．
///
///  $Id$
///

///
///  カーネルの初期化と終了処理
///
usingnamespace @import("kernel_impl.zig");
usingnamespace time_event;
usingnamespace check;

///
///  非タスクコンテキスト用のスタックの初期値を使用するか
///
const TOPPERS_ISTKPT = isTrue(target_impl, "TOPPERS_ISTKPT");

///
///  非タスクコンテキスト用スタックサイズの最小値
///
const TARGET_MIN_ISTKSZ = decl(usize, target_impl, "TARGET_MIN_ISTKSZ", 1);

///
///  スタックサイズのアライン単位
///
const CHECK_STKSZ_ALIGN = decl(usize, target_impl, "CHECK_STKSZ_ALIGN", 1);

///
///  スタック領域のアライン単位（チェック用）
///
const CHECK_STACK_ALIGN = decl(usize, target_impl, "CHECK_STACK_ALIGN", 1);

///
///  スタック領域のアライン単位（確保用）
///
const STACK_ALIGN = decl(usize, target_impl, "STACK_ALIGN", CHECK_STACK_ALIGN);

///
///  初期化ルーチンブロック
///
pub const INIRTNB = struct {
    inirtn: INIRTN,             // 初期化ルーチンの先頭番地
    exinf: EXINF,               // 初期化ルーチンの拡張情報
};

///
///  終了処理ルーチンブロック
///
pub const TERRTNB = struct {
    terrtn: TERRTN,             // 終了処理ルーチンの先頭番地
    exinf: EXINF,               // 終了処理ルーチンの拡張情報
};

///
///  初期化ルーチンブロックの取り込み
///
pub const ExternIniRtnB = struct {
    ///
    ///  初期化ルーチンの数
    ///
    pub extern const _kernel_tnum_inirtn: c_uint;

    ///
    ///  初期化ルーチンブロックテーブル
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern const _kernel_inirtnb_table: [100]INIRTNB;
};

///
///  終了処理ルーチンブロックの取り込み
///
pub const ExternTerRtnB = struct {
    ///
    ///  終了処理ルーチンの数
    ///
    pub extern const _kernel_tnum_terrtn: c_uint;

    ///
    ///  終了処理ルーチンブロックテーブル
    ///
    // zigの不具合と思われる現象の回避（*c を大きい数字に置き換えた）
    pub extern const _kernel_terrtnb_table: [100]TERRTNB;
};

///
///  非タスクコンテキスト用スタック領域に関するコンフィギュレーション
///  データの取り込み
///
pub const ExternIcs = struct {
    ///
    ///  非タスクコンテキスト用スタック領域のサイズ（丸めた値）
    ///
    pub extern const _kernel_istksz: usize;

    ///
    ///  非タスクコンテキスト用スタック領域の先頭番地
    ///
    pub extern const _kernel_istk: [*]u8;

    ///
    ///  非タスクコンテキスト用のスタックの初期値
    ///
    pub usingnamespace if (TOPPERS_ISTKPT) struct {
        pub extern var _kernel_istkpt: [*]u8;
    } else struct {};
};

///
///  TECSの初期化（init_tecs.c）
///
extern fn initialize_tecs() void;

///
///  カーネル動作状態フラグ
///
///  スタートアップルーチンで，false（＝0）に初期化されることを期待し
///  ている．
///
pub var kerflg: bool = false;

///
///  カーネルの起動
///
pub fn sta_ker() noreturn {
    // TECSの初期化
    if (!option.TOPPERS_OMIT_TECS) {
        initialize_tecs();
    }

    // ターゲット依存の初期化
    target_impl.initialize();

    // 各モジュールの初期化
    initialize_tmevt();                             //［ASPD1061］
    cfg._kernel_initialize_object();

    // 初期化ルーチンの実行
    for (cfg._kernel_inirtnb_table[0 .. cfg._kernel_tnum_inirtn]) |inirtnb| {
        inirtnb.inirtn(inirtnb.exinf);
    }

    // 高分解能タイマの設定
    current_hrtcnt = target_timer.hrt.get_current();    //［ASPD1063］
    set_hrt_event();                                    //［ASPD1064］

    // カーネル動作の開始
    kerflg = true;
    traceLog("kernelEnter", .{});
    target_impl.startDispatch();
}

///
///  カーネルの終了
///
pub fn ext_ker() noreturn {
    var silLock = sil.PRE_LOC();

    traceLog("extKerEnter", .{});

    // 割込みロック状態に移行
    sil.LOC_INT(&silLock);

    // カーネル動作の終了
    traceLog("kernelLeave", .{});
    kerflg = false;

    // カーネルの終了処理の呼出し
    target_impl.call_exit_kernel();
}

/// カーネルの終了処理
pub fn exit_kernel() noreturn {
    // 終了処理ルーチンの実行
    for (cfg._kernel_terrtnb_table[0 .. cfg._kernel_tnum_terrtn]) |terrtnb| {
        terrtnb.terrtn(terrtnb.exinf);
    }

    // ターゲット依存の終了処理
    target_impl.exit();
}

///
///  非タスクコンテキスト用スタック領域の定義（静的APIの処理）
///
pub fn defineInterruptStack(dics: T_DICS) ItronError!T_DICS {
    // istkszがターゲット定義の最小値（TARGET_MIN_ISTKSZ，未定義の場合
    // は1）よりも小さい場合（E_PAR）［NGKI3254］
    try checkParameterError(dics.istksz >= TARGET_MIN_ISTKSZ);

    // istkszがターゲット定義の制約に合致しない場合（E_PAR）［NGKI3222］
    try checkParameter((ctsk.istksz & (CHECK_STKSZ_ALIGN - 1)) == 0);

    // 非タスクコンテキスト用スタック領域の定義情報をそのまま返す
    return dics;
}

///
///  初期化ルーチンの追加（静的APIの処理）
///
pub fn attachInitializeRoutine(aini: T_AINI) ItronError!INIRTNB {
    // iniatrが無効の場合（E_RSATR）［NGKI3241］［NGKI3202］［NGKI3203］
    //（TA_NULLでない場合）
    try checkValidAtr(aini.iniatr, TA_NULL);

    // 初期化ルーチンブロックを返す
    return INIRTNB{ .inirtn = aini.inirtn, .exinf = aini.exinf, };
}

///
///  終了処理ルーチンの追加（静的APIの処理）
///
pub fn attachTerminateRoutine(ater: T_ATER) ItronError!TERRTNB {
    // teratrが無効の場合（E_RSATR）［NGKI3248］［NGKI3208］［NGKI3209］
    //（TA_NULLでない場合）
    try checkValidAtr(ater.teratr, TA_NULL);

    // 終了処理ルーチンブロックを返す
    return TERRTNB{ .terrtn = ater.terrtn, .exinf = ater.exinf, };
}

///
///  初期化ルーチンブロックの生成（静的APIの処理）
///
pub fn ExportIniRtnB(inirtnb_table: []INIRTNB) type {
    // チェック処理用の定義の生成
    exportCheck(@sizeOf(INIRTNB), "sizeof_INIRTNB");
    exportCheck(@sizeOf(INIRTN), "sizeof_INIRTN");
    exportCheck(@byteOffsetOf(INIRTNB, "inirtn"), "offsetof_INIRTNB_inirtn");

    const tnum_inirtn = inirtnb_table.len;
    const Exports = struct {
        pub export const _kernel_tnum_inirtn: c_uint = tnum_inirtn;
        pub export const _kernel_inirtnb_table =
                                        inirtnb_table[0 .. tnum_inirtn].*;
    };
    return Exports;
}

///
///  終了処理ルーチンブロックの生成（静的APIの処理）
///
pub fn ExportTerRtnB(terrtnb_table: []TERRTNB) type {
    // チェック処理用の定義の生成
    exportCheck(@sizeOf(TERRTNB), "sizeof_TERRTNB");
    exportCheck(@sizeOf(TERRTN), "sizeof_TERRTN");
    exportCheck(@byteOffsetOf(TERRTNB, "terrtn"), "offsetof_TERRTNB_terrtn");

    const tnum_terrtn = terrtnb_table.len;
    return struct {
        pub export const _kernel_tnum_terrtn: c_uint = tnum_terrtn;
        pub export const _kernel_terrtnb_table =
                                        terrtnb_table[0 .. tnum_terrtn].*;
    };
}

///
///  非タスクコンテキスト用スタック領域関係のデータの生成（静的APIの処理）
///
pub fn ExportIcs(dics: T_DICS) type {
    const istksz = TOPPERS_ROUND_SZ(dics.istksz, STACK_ALIGN);
    return struct {
        pub export const _kernel_istksz: usize = istksz;
        pub export const _kernel_istk: [*]u8 =
            if (dics.istk) |istk| istk
            else &struct {
                var istack: [istksz]u8 align(STACK_ALIGN) = undefined;
            }.istack;
        pub usingnamespace if (TOPPERS_ISTKPT) struct {
            pub export var _kernel_istkpt: [*]u8 = undefined;
        } else struct {};
    };
}
