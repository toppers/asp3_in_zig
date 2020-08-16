///
///  システムコンフィギュレーションファイル向けの宣言
///

///
///  コンフィギュレーションオプションの取り込み
///
pub const option = @import("../include/option.zig");

///
///  アプリケーションと共通の定義ファイル
///
pub const zig = @import("../include/kernel.zig");
usingnamespace zig;

///
///  静的APIの記述を楽にするための関数
///
pub fn CTSK(tskatr: ATR, exinf: anytype, task_main: TASK, itskpri: PRI,
            stksz: usize, stk: ?[*]u8) T_CTSK {
    return T_CTSK{
            .tskatr = tskatr, .exinf = comptime castToExinf(exinf),
            .task = task_main, .itskpri = itskpri,
            .stksz = stksz, .stk = stk,
    };
}

pub fn CSEM(sematr: ATR, isemcnt: c_uint, maxsem: c_uint) T_CSEM {
    return T_CSEM{
        .sematr = sematr, .isemcnt = isemcnt, .maxsem = maxsem,        
    };
}

pub fn CFLG(flgatr: ATR, iflgptn: FLGPTN) T_CFLG {
    return T_CFLG{
        .flgatr = flgatr, .iflgptn = iflgptn,
    };
}

pub fn CDTQ(dtqatr: ATR, dtqcnt: c_uint, dtqmb: ?[*]u8) T_CDTQ {
    return T_CDTQ{
        .dtqatr = dtqatr, .dtqcnt = dtqcnt, .dtqmb = dtqmb,
    };
}

pub fn CPDQ(pdqatr: ATR, pdqcnt: c_uint, maxdpri: PRI, pdqmb: ?[*]u8) T_CPDQ {
    return T_CPDQ{
        .pdqatr = pdqatr, .pdqcnt = pdqcnt, .maxdpri = maxdpri, .pdqmb = pdqmb,
    };
}

pub fn CMTX(mtxatr: ATR, ceilpri: PRI) T_CMTX {
    return T_CMTX{
        .mtxatr = mtxatr, .ceilpri = ceilpri,
    };
}

pub fn CMPF(mpfatr: ATR, blkcnt: c_uint, blksz: c_uint,
            mpf: ?[*]u8, mpfmb: ?[*]u8) T_CMPF {
    return T_CMPF{
        .mpfatr = mpfatr, .blkcnt = blkcnt, .blksz = blksz,
        .mpf = mpf, .mpfmb = mpfmb,
    };
}

pub fn DEXC(excatr: ATR, exchdr: EXCHDR) T_DEXC {
    return T_DEXC{
        .excatr = excatr, .exchdr = exchdr,
    };
}

pub fn CCYC(cycatr: ATR, nfyinfo: T_NFYINFO,
            cyctim: RELTIM, cycphs: RELTIM) T_CCYC {
    return T_CCYC{
        .cycatr = cycatr, .nfyinfo = nfyinfo,
        .cyctim = cyctim, .cycphs = cycphs,
    };
}

pub fn CALM(almatr: ATR, nfyinfo: T_NFYINFO) T_CALM {
    return T_CALM{
        .almatr = almatr, .nfyinfo = nfyinfo,
    };
}

pub fn DOVR(ovratr: ATR, ovrhdr: OVRHDR) T_DOVR {
    return T_DOVR{
        .ovratr = ovratr, .ovrhdr = ovrhdr,
    };
}

pub fn CINT(intatr: ATR, intpri: PRI) T_CINT {
    return T_CINT{
        .intatr = intatr, .intpri = intpri,
    };
}

pub fn DINH(inhatr: ATR, inthdr: INTHDR) T_DINH {
    return T_DINH{
        .inhatr = inhatr, .inthdr = inthdr,
    };
}

pub fn CISR(isratr: ATR, exinf: anytype, intno: INTNO, isr_main: ISR,
            isrpri: PRI) T_CISR {
    return T_CISR{
        .isratr = isratr, .exinf = comptime castToExinf(exinf),
        .intno = intno, .isr = isr_main, .isrpri = isrpri,
    };
}

pub fn DICS(istksz: usize, comptime istk: *u8) T_DICS {
    comptime const dics = T_DICS{
        .istksz = istksz, .istk = istk,
    };
}

pub fn AINI(iniatr: ATR, exinf: anytype, inirtn_main: INIRTN) T_AINI {
    return T_AINI{
        .iniatr = iniatr, .exinf = comptime castToExinf(exinf),
        .inirtn = inirtn_main,
    };
}

pub fn ATER(teratr: ATR, exinf: anytype, comptime terrtn_main: TERRTN) T_ATER {
    return T_ATER{
        .teratr = teratr, .exinf = comptime castToExinf(exinf),
        .terrtn = terrtn_main,
    };
}

pub fn NFY_TMEHDR(comptime exinf: anytype, comptime tmehdr: TMEHDR) T_NFYINFO {
    return T_NFYINFO{ .nfy = .{ .Handler =
                                   .{ .exinf = comptime castToExinf(exinf),
                                      .tmehdr = @ptrCast(TMEHDR, tmehdr), }}};
}

pub fn NFYINFO(comptime args: anytype, comptime cfg_data: *CfgData) T_NFYINFO {
    // 通知モードを変数に格納
    comptime const nfymode: u32 = args.@"0";
    comptime const nfymode1 = nfymode & @as(u32, 0x0f);
    comptime const nfymode2 = nfymode & ~@as(u32, 0x0f);

    // 不要なエラー通知処理が設定されている場合［NGKI3721］
    if (nfymode1 == TNFY_HANDLER
            or nfymode1 == TNFY_SETVAR
            or nfymode1 == TNFY_INCVAR) {
        if (nfymode2 != 0) {
            @compileError("illegal error notification mode.");
        }
    }

    // 通知処理のパラメータ数を求める
    comptime var numpar =
        if (nfymode1 != TNFY_HANDLER
                and nfymode1 != TNFY_SETVAR
                and nfymode1 != TNFY_SETFLG
                and nfymode1 != TNFY_SNDDTQ) 1
        else 2;

    // エラー通知処理のパラメータ数を求める
    comptime var numepar =
        if (nfymode2 == 0) 0
        else if (nfymode2 != TENFY_SETFLG) 1
        else 2;

    // パラメータが足りない場合
    if (args.len < 1 + numpar + numepar) {
        @compileError("too few parameters for notification information.");
    }

    // パラメータが多すぎる場合
    if (args.len > 1 + numpar + numepar) {
        @compileError("too may parameters for notification information.");
    }

    // 通知処理のパラメータを変数に格納
    comptime const par1 = if (args.len > 1) args.@"1" else null;
    comptime const par2 = if (args.len > 2) args.@"2" else null;

    // エラー通知処理のパラメータを変数に格納
    comptime const epar1 =
        if (numpar == 2) (if (args.len > 3) args.@"3" else null)
        else  (if (args.len > 2) args.@"2" else null);
    comptime const epar2 =
        if (numpar == 2) (if (args.len > 4) args.@"4" else null)
        else  (if (args.len > 3) args.@"3" else null);

    return T_NFYINFO{
        .nfy = switch (nfymode1) {
            TNFY_HANDLER => .{ .Handler = .{ .exinf = castToExinf(par1),
                                          .tmehdr = @ptrCast(TMEHDR, par2), }},
            TNFY_SETVAR => .{ .SetVar = .{ .p_var = @ptrCast(*usize, par1),
                                           .value = par2, }},
            TNFY_INCVAR => .{ .IncVar = .{ .p_var = @ptrCast(*usize, par1), }},
            TNFY_ACTTSK => .{ .ActTsk = .{ .tskid = cfg_data.getTskId(par1), }},
            TNFY_WUPTSK => .{ .WupTsk = .{ .tskid = cfg_data.getTskId(par1), }},
            TNFY_SIGSEM => .{ .SigSem = .{ .semid = cfg_data.getSemId(par1), }},
            TNFY_SETFLG => .{ .SetFlg = .{ .flgid = cfg_data.getFlgId(par1),
                                           .flgptn = par2, }},
            TNFY_SNDDTQ => .{ .SndDtq = .{ .dtqid = cfg_data.getDtqId(par1),
                                           .data = par2, }},
            else => {
                // 不正な通知モード（E_PAR）［NGKI3730］
                @compileError("illegal notification mode.");
            },
        },
        .enfy = switch (nfymode2) {
            0 => null,
            TENFY_SETVAR => .{ .SetVar = .{ .p_var = @ptrCast(*usize, epar1),}},
            TENFY_INCVAR => .{ .IncVar = .{ .p_var = @ptrCast(*usize, epar1),}},
            TENFY_ACTTSK => .{ .ActTsk = .{ .tskid =
                                               cfg_data.getTskId(epar1), }},
            TENFY_WUPTSK => .{ .WupTsk = .{ .tskid =
                                               cfg_data.getTskId(epar1), }},
            TENFY_SIGSEM => .{ .SigSem = .{ .semid =
                                               cfg_data.getSemId(epar1), }},
            TENFY_SETFLG => .{ .SetFlg = .{ .flgid = cfg_data.getFlgId(epar1),
                                            .flgptn = epar2, }},
            TENFY_SNDDTQ => .{ .SndDtq = .{ .dtqid =
                                               cfg_data.getDtqId(epar1), }},
            else => {
                // 不正なエラー通知モード（E_PAR）［NGKI3730］
                @compileError("illegal error notification mode.");
            },
        },
    };
}

///
///  静的APIの処理プログラム（コンフィギュレータ）
///
const static_api = @import("static_api.zig");
pub const CfgData = static_api.CfgData;
pub const GenCfgData = static_api.GenCfgData;

///
///  システムコンフィギュレーション記述のターゲット依存部
///
pub const target = @import("../target/" ++ option.TARGET ++ "/target_cfg.zig");

///
///  C言語の変数へのポインタの取り込み
///
///  Zigの機能制限の回避のため（thanks to 河田君）
///
pub fn importSymbol(comptime T: type, comptime name: []const u8) *T {
    return &struct {
        var placeholder: T = undefined;
        comptime { @export(placeholder, .{ .name = name, .linkage = .Weak,
                                           .section = ".discard", }); }
    }.placeholder;
}

///
///  静的APIの読み込みとコンフィギュレーションデータの生成
///
///  genConfigをここで定義することが可能と思われるが，configurationの
///  型が不一致というコンパイルエラーになる（そのためpubにしていない）．
///  コンパイラの不具合ではないかと思われる．
///
fn genConfig(comptime configuration: fn(*CfgData) void) type {
    @setEvalBranchQuota(10000);
    comptime var cfg = CfgData{};
    configuration(&cfg);
    return GenCfgData(&cfg);
}
