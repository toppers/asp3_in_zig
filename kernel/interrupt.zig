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
///  割込み管理機能
///
const std = @import("std");
usingnamespace @import("kernel_impl.zig");
usingnamespace task;
usingnamespace check;

///
///  割込みハンドラの範囲の判定
///
pub fn validInhnoDefInh(inhno: INHNO) bool {
    if (@hasDecl(target_impl, "validInhnoDefInh")) {
        return target_impl.validInhnoDefInh(inhno);
    }
    else {
        return target_impl.validInhno(inhno);
    }
}

///
///  割込み番号の範囲の判定
///
pub fn validIntnoCfgInt(intno: INTNO) bool {
    if (@hasDecl(target_impl, "validIntnoCfgInt")) {
        return target_impl.validIntnoCfgInt(intno);
    }
    else {
        return target_impl.validIntno(intno);
    }
}
pub fn validIntnoCreIsr(intno: INTNO) bool {
    if (@hasDecl(target_impl, "validIntnoCreIsr")) {
        return target_impl.validIntnoCreIsr(intno);
    }
    else {
        return target_impl.validIntno(intno);
    }
}
pub fn validIntnoDisInt(intno: INTNO) bool {
    if (@hasDecl(target_impl, "validIntnoDisInt")) {
        return target_impl.validIntnoDisInt(intno);
    }
    else {
        return target_impl.validIntno(intno);
    }
}
pub fn validIntnoClrInt(intno: INTNO) bool {
    if (@hasDecl(target_impl, "validIntnoClrInt")) {
        return target_impl.validIntnoClrInt(intno);
    }
    else {
        return target_impl.validIntno(intno);
    }
}
pub fn validIntnoRasInt(intno: INTNO) bool {
    if (@hasDecl(target_impl, "validIntnoRasInt")) {
        return target_impl.validIntnoRasInt(intno);
    }
    else {
        return target_impl.validIntno(intno);
    }
}
pub fn validIntnoPrbInt(intno: INTNO) bool {
    if (@hasDecl(target_impl, "validIntnoPrbInt")) {
        return target_impl.validIntnoPrbInt(intno);
    }
    else {
        return target_impl.validIntno(intno);
    }
}

///
///  割込み優先度の範囲の判定
///
pub fn validIntPriCfgInt(intpri : PRI) bool {
    if (@hasDecl(target_impl, "validIntPriCfgInt")) {
        return target_impl.validIntPriCfgInt(intpri);
    }
    else {
        return TMIN_INTPRI <= intpri and intpri <= TMAX_INTPRI;
    }
}
pub fn validIntPriChgIpm(intpri : PRI) bool {
    if (@hasDecl(target_impl, "validIntPriChgIpm")) {
        return target_impl.validIntPriChgIpm(intpri);
    }
    else {
        return TMIN_INTPRI <= intpri and intpri <= TIPM_ENAALL;
    }
}

///
///  割込み番号と割込みハンドラ番号の対応
///
fn inhnoToIntno(inhno: INHNO) ?INTNO {
    if (@hasDecl(target_impl, "inhnoToIntno")) {
        return target_impl.inhnoToIntno(inhno);
    }
    else {
        return @intCast(INTNO, inhno);
    }
}
pub fn intnoToInhno(intno: INTNO) INHNO {
    if (@hasDecl(target_impl, "intnoToInhno")) {
        return target_impl.intnoToInhno(intno);
    }
    else {
        return @intCast(INHNO, intno);
    }
}

///
///  ターゲット依存の割込み要求ライン属性
///
const TARGET_INTATR = decl(ATR, target_impl, "TARGET_INTATR", 0);

///
///  ターゲット依存の割込みハンドラ属性
///
const TARGET_INHATR = decl(ATR, target_impl, "TARGET_INHATR", 0);

///
///  ターゲット依存の割込みサービスルーチン属性
///
const TARGET_ISRATR = decl(ATR, target_impl, "TARGET_ISRATR", 0);

///
///  割込み要求ライン初期化ブロック
///
pub const INTINIB =
    if (@hasDecl(target_impl, "INTINIB")) target_impl.INTINIB
    else struct {
        intno: INTNO,           // 割込み番号
        intatr: ATR,            // 割込み属性
        intpri: PRI,            // 割込み優先度
    };

///
///  割込みハンドラ初期化ブロック
///
pub const INHINIB =
    if (@hasDecl(target_impl, "INHINIB")) target_impl.INHINIB
    else struct {
        inhno: INHNO,           // 割込みハンドラ番号
        inhatr: ATR,            // 割込みハンドラ属性
        inthdr: INTHDR,         // 割込みハンドラの先頭の番地
    };

///
///  割込み要求ライン初期化ブロックの取り込み
///
pub const ExternIntIniB =
    if (@hasDecl(target_impl, "ExternIntIniB")) target_impl.ExternIntIniB
    else struct {
        ///
        /// 定義する割込みハンドラ番号の数
        ///
        pub extern const _kernel_tnum_def_inhno: c_uint;

        ///
        /// 割込みハンドラ初期化ブロックのエリア
        ///
        // zigの制限の回避（配列のサイズを大きい値にしている）
        pub extern const _kernel_inhinib_table: [100]INHINIB;
    };

///
///  標準的な割込みハンドラ初期化ブロックの取り込み
///
pub const ExternInhIniB =
    if (@hasDecl(target_impl, "ExternInhIniB")) target_impl.ExternInhIniB
    else struct {
        ///
        ///  設定する割込み要求ラインの数
        ///
        pub extern const _kernel_tnum_cfg_intno: c_uint;

        ///
        ///  割込み要求ライン初期化ブロックのエリア
        ///
        // zigの制限の回避（配列のサイズを大きい値にしている）
        pub extern const _kernel_intinib_table: [100]INTINIB;
    };

///
///  割込み管理機能の初期化
///
pub fn initialize_interrupt() void {
    if (@hasDecl(target_impl, "initialize_interrupt")) {
        target_impl.initialize_interrupt();
    }
    else {
        // 標準的な初期化処理
        for (cfg._kernel_inhinib_table
                 [0 .. cfg._kernel_tnum_def_inhno]) |*p_inhinib| {
            target_impl.define_inh(p_inhinib.inhno, p_inhinib.inhatr,
                                   p_inhinib.inthdr);
        }
        for (cfg._kernel_intinib_table
                 [0 .. cfg._kernel_tnum_cfg_intno]) |*p_intinib| {
            target_impl.config_int(p_intinib.intno, p_intinib.intatr,
                                   p_intinib.intpri);
        }
    }
}

///
///  割込みの禁止［NGKI3555］
///
pub fn dis_int(intno: INTNO) ItronError!void {
    traceLog("disIntEnter", .{ intno });
    errdefer |err| traceLog("disIntLeave", .{ err });
    comptime try checkNotSupported(TOPPERS_SUPPORT_DIS_INT);    //［NGKI3093］
    try checkParameter(validIntnoDisInt(intno));    //［NGKI3083］［NGKI3087］
    {
        var locked = target_impl.senseLock();
        if (!locked) {
            target_impl.lockCpu();
        }
        defer {
            if (!locked) {
                target_impl.unlockCpu();
            }
        }

        if (target_impl.checkIntnoCfg(intno)) {
            target_impl.disableInt(intno);      //［NGKI3086］
        }
        else {                                  //［NGKI3085］
            return ItronError.ObjectStateError;
        }
    }
    traceLog("disIntLeave", .{ null });
}

///
///  割込みの許可［NGKI3556］
///
pub fn ena_int(intno: INTNO) ItronError!void {
    traceLog("enaIntEnter", .{ intno });
    errdefer |err| traceLog("enaIntLeave", .{ err });
    comptime try checkNotSupported(TOPPERS_SUPPORT_DIS_INT);    //［NGKI3106］
    try checkParameter(validIntnoDisInt(intno));    //［NGKI3096］［NGKI3100］
                                                
    {
        var locked = target_impl.senseLock();
        if (!locked) {
            target_impl.lockCpu();
        }
        defer {
            if (!locked) {
                target_impl.unlockCpu();
            }
        }

        if (target_impl.checkIntnoCfg(intno)) {
            target_impl.enableInt(intno);       //［NGKI3099］
        }
        else {                                  //［NGKI3098］
            return ItronError.ObjectStateError;
        }
    }
    traceLog("enaIntLeave", .{ null });
}

///
///  割込み要求のクリア［NGKI3920］
///
pub fn clr_int(intno: INTNO) ItronError!void {
    traceLog("clrIntEnter", .{ intno });
    errdefer |err| traceLog("clrIntLeave", .{ err });
    comptime try checkNotSupported(TOPPERS_SUPPORT_CLR_INT);    //［NGKI3927］
    try checkParameter(validIntnoClrInt(intno));    //［NGKI3921］［NGKI3930］
                                                
    {
        var locked = target_impl.senseLock();
        if (!locked) {
            target_impl.lockCpu();
        }
        defer {
            if (!locked) {
                target_impl.unlockCpu();
            }
        }

        if (target_impl.checkIntnoCfg(intno)
                and target_impl.checkIntnoClear(intno)) {
            target_impl.clearInt(intno);        //［NGKI3924］
        }
        else {                                  //［NGKI3923］［NGKI3929］
            return ItronError.ObjectStateError;
        }
    }
    traceLog("clrIntLeave", .{ null });
}

///
///  割込みの要求［NGKI3932］
///
pub fn ras_int(intno: INTNO) ItronError!void {
    traceLog("rasIntEnter", .{ intno });
    errdefer |err| traceLog("rasIntLeave", .{ err });
    comptime try checkNotSupported(TOPPERS_SUPPORT_RAS_INT);    //［NGKI3939］
    try checkParameter(validIntnoRasInt(intno));    //［NGKI3933］［NGKI3942］
                                                
    {
        var locked = target_impl.senseLock();
        if (!locked) {
            target_impl.lockCpu();
        }
        defer {
            if (!locked) {
                target_impl.unlockCpu();
            }
        }

        if (target_impl.checkIntnoCfg(intno)
                and target_impl.checkIntnoRaise(intno)) {
            target_impl.raiseInt(intno);        //［NGKI3936］
        }
        else {                                  //［NGKI3935］［NGKI3941］
            return ItronError.ObjectStateError;
        }
    }
    traceLog("rasIntLeave", .{ null });
}

///
///  割込み要求のチェック［NGKI3944］
///
pub fn prb_int(intno: INTNO) ItronError!bool {
    traceLog("prbIntEnter", .{ intno });
    errdefer |err| traceLog("prbIntLeave", .{ err });
    comptime try checkNotSupported(TOPPERS_SUPPORT_PRB_INT);    //［NGKI3951］
    try checkParameter(validIntnoPrbInt(intno));    //［NGKI3945］［NGKI3952］
    {
        var locked = target_impl.senseLock();
        if (!locked) {
            target_impl.lockCpu();
        }
        defer {
            if (!locked) {
                target_impl.unlockCpu();
            }
        }

        if (target_impl.checkIntnoCfg(intno)) {
            return target_impl.probeInt(intno); //［NGKI3948］
        }
        else {                                  //［NGKI3947］
            return ItronError.ObjectStateError;
        }
    }
    traceLog("prbIntLeave", .{ null });
}

///
///  割込み優先度マスクの変更［NGKI3107］
///
pub fn chg_ipm(intpri: PRI) ItronError!void {
    traceLog("chgIpmEnter", .{ intpri });
    errdefer |err| traceLog("chgIpmLeave", .{ err });
    try checkContextTaskUnlock();               //［NGKI3108］［NGKI3109］
    try checkParameter(validIntPriChgIpm(intpri));
                                                //［NGKI3113］［NGKI3114］
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        target_impl.setIpm(intpri);             //［NGKI3111］
        if (intpri == TIPM_ENAALL and enadsp) {
            set_dspflg();
            if (p_runtsk.?.flags.raster and p_runtsk.?.flags.enater) {
                if (TOPPERS_SUPPORT_OVRHDR) {
                    if (p_runtsk.?.flags.staovr) {
                        _ = target_timer.ovrtimer.stop();
                    }
                }
                task_terminate(p_runtsk.?);
                target_impl.exitAndDispatch();
            }
            else {
                taskDispatch();
            }
        }
        else {
            dspflg = false;
        }
    }
    traceLog("chgIpmLeave", .{ null });
}

///
///  割込み優先度マスクの参照［NGKI3115］
///
pub fn get_ipm(p_intpri: *PRI) ItronError!void {
    traceLog("getIpmEnter", .{ p_intpri });
    errdefer |err| traceLog("getIpmLeave", .{ err, p_intpri });
    try checkContextTaskUnlock();               //［NGKI3116］［NGKI3117］
    {
        target_impl.lockCpu();
        defer target_impl.unlockCpu();

        p_intpri.* = target_impl.getIpm();      //［NGKI3120］
    }
    traceLog("getIpmLeave", .{ null, p_intpri });
}

///
///  割込み要求ラインの設定（静的APIの処理）
///
pub fn cfg_int(intno: INTNO, cint: T_CINT) ItronError!INTINIB {
    // intnoが有効範囲外の場合（E_PAR）［NGKI2972］
    try checkParameter(validIntnoCfgInt(intno));

    // intatrが無効の場合（E_RSATR）［NGKI2969］［NGKI2944］［NGKI2945］
    //（TA_ENAINT，TA_EDGE，TARGET_INTATR以外のビットがセットされている場合）
    try checkValidAtr(cint.intatr, TA_ENAINT|TA_EDGE|TARGET_INTATR);

    // intpriがCFG_INTに対する割込み優先度として正しくない場合（E_PAR）
    // ［NGKI2973］
    try checkParameter(validIntPriCfgInt(cint.intpri));

    // ターゲット依存のエラーチェック［NGKI2983］［NGKI2984］［NGKI2985］
    if (@hasDecl(target_impl, "checkCfgInt")) {
        try target_impl.checkCfgInt(into, cint);
    }

    // 割込み要求ライン初期化ブロックを返す
    return if (@hasDecl(target_impl, "buildIntIniB"))
               target_impl.buildIntIniB(intno, cint)
           else INTINIB{ .intno = intno,
                         .intatr = cint.intatr,
                         .intpri = cint.intpri, };
}

///
///  割込み要求ライン初期化ブロックの生成（静的APIの処理）
///
pub fn ExportIntIniB(intinib_table: []INTINIB) type {
    const tnum_int = intinib_table.len;
    return struct {
        export const _kernel_tnum_cfg_intno: c_uint = tnum_int;
        export const _kernel_intinib_table = intinib_table[0 .. tnum_int].*;
    };
}

///
///  割込みハンドラの定義（静的APIの処理）
///
pub fn def_inh(inhno: INHNO, dinh: T_DINH,
               comptime cfg_data: *static_api.CfgData) ItronError!INHINIB {
    // inhnoが有効範囲外の場合（E_PAR）［NGKI3055］
    try checkParameter(validInhnoDefInh(inhno));

    // inhatrが無効の場合（E_RSATR）［NGKI3052］［NGKI2957］［NGKI2959］
    //（TARGET_INHATR以外のビットがセットされている場合）
    try checkValidAtr(dinh.inhatr, TARGET_INHATR);

    if (inhnoToIntno(inhno)) |intno| {
        // 割込みハンドラ番号に対応する割込み番号がある場合

        // intnoに対するCFG_INTがない場合（E_OBJ）［NGKI3062］
        try checkObjectState(cfg_data.referIntIniB(intno) != null);

        // inhnoに対応するintnoに対してCRE_ISRがある場合（E_OBJ）［NGKI3063］
        try checkObjectState(cfg_data.referCreIsr(intno) == null);
    }

    // ターゲット依存のエラーチェック［NGKI3065］［NGKI3066］［NGKI3078］
    if (@hasDecl(target_impl, "checkDefInh")) {
        try target_impl.checkDefInh(inho, dinh, cfg_data);
    }

    // 割込みハンドラ初期化ブロックを返す
    return if (@hasDecl(target_impl, "buildInhIniB"))
               target_impl.buildInhIniB(inhno, dinh)
           else INHINIB{ .inhno = inhno,
                         .inhatr = dinh.inhatr,
                         .inthdr = dinh.inthdr, };
}

///
///  割込みハンドラ初期化ブロックの生成（静的APIの処理）
///
pub fn ExportInhIniB(inhinib_table: []INHINIB) type {
    // チェック処理用の定義の生成
    exportCheck(@sizeOf(INHINIB), "sizeof_INHINIB");
    exportCheck(@sizeOf(INHNO), "sizeof_INHNO");
    exportCheck(@sizeOf(INTHDR), "sizeof_INTHDR");
    exportCheck(@byteOffsetOf(INHINIB, "inhno"), "offsetof_INHINIB_inhno");
    exportCheck(@byteOffsetOf(INHINIB, "inthdr"), "offsetof_INHINIB_inthdr");

    const tnum_inh = inhinib_table.len;
    return struct {
        export const _kernel_tnum_def_inhno: c_uint = tnum_inh;
        export const _kernel_inhinib_table = inhinib_table[0 .. tnum_inh].*;
    };
}

///
///  割込みサービスルーチンの生成（静的APIの処理）
///
pub fn cre_isr(cisr: T_CISR,
               comptime cfg_data: *static_api.CfgData) ItronError!T_CISR {
    // isratrが無効の場合（E_RSATR）［NGKI2998］［NGKI2952］［NGKI5176］
    //（TARGET_ISRATR以外のビットがセットされている場合）
    try checkValidAtr(cisr.isratr, TARGET_ISRATR);

    // intnoが有効範囲外の場合（E_PAR）［NGKI3003］
    try checkParameter(validIntnoCreIsr(cisr.intno));

    // isrpriが有効範囲外の場合（E_PAR）［NGKI3005］
    //（TMIN_ISRPRI <= isrpri && isrpri <= TMAX_ISRPRIでない場合）
    try checkParameter(TMIN_ISRPRI <= cisr.isrpri
                           and cisr.isrpri <= TMAX_ISRPRI);

    // intnoに対応するinhnoに対してDEF_INHがある場合（E_OBJ）［NGKI3013］
    const inhno = intnoToInhno(cisr.intno);
    try checkObjectState(cfg_data.referInhIniB(inhno) == null);

    // intnoに対するCFG_INTがない場合（E_OBJ）［NGKI3012］
    try checkObjectState(cfg_data.referIntIniB(cisr.intno) != null);
                           
    // ターゲット依存のエラーチェック［NGKI3014］
    if (@hasDecl(target_impl, "checkCreIsr")) {
        try target_impl.checkCreIsr(cisr, cfg_data);
    }

    // 割込みサービスルーチンの生成情報をそのまま返す
    return cisr;
}

///
///  割込みサービスルーチンのコンフィギュレーション情報
///
pub const ISRCFG = struct {
    cisr: T_CISR,           // 割込みサービスルーチンの生成情報
    isrid: ID,              // 割込みサービスルーチンID
    genflag: bool,          // 生成済みであることを示すフラグ
};

///
///  呼び出すC言語APIの宣言
///
const c_api = struct {
    extern fn unl_cpu() c_int;
    extern fn sns_loc() ER;
};

///
///  割込みサービスルーチンを呼び出す割込みハンドラの生成
///
fn GenInterruptHandler(comptime isrcfg_table: []ISRCFG) type {
    return struct {
        pub fn handler() callconv(.C) void {
            inline for (isrcfg_table) |isrcfg, i| {
                if (i > 0) {
                    if (c_api.sns_loc() != 0) {
                        _ = c_api.unl_cpu();
                    }
                }
                traceLog("isrEnter", .{ isrcfg.isrid });
                isrcfg.cisr.isr(isrcfg.cisr.exinf);
                traceLog("isrLeave", .{ isrcfg.isrid });
            }
        }
    };
}

///
///  割込みサービスルーチン優先度の比較
///
fn isrcfgLessThan(lhs: ISRCFG, rhs: ISRCFG) bool {
    return lhs.cisr.isrpri < rhs.cisr.isrpri;
}

///
///  割込みサービスルーチンを呼び出す割込みハンドラの生成（静的APIの処理）
///
pub fn generateInhForIsr(isrcfg_table: []ISRCFG,
                         comptime cfg_data: *static_api.CfgData) void {
    // 各ISRに対して割込みハンドラを生成する
    inline for (isrcfg_table) |isrcfg| {
        // 生成済みのISRをスキップ
        if (isrcfg.genflag) continue;

        // 割込み番号が同じISRの数を数える
        comptime var count: usize = 0;
        inline for (isrcfg_table) |*p_isrcfg2| {
            if (isrcfg.cisr.intno == p_isrcfg2.cisr.intno) {
                count += 1;
                p_isrcfg2.genflag = true;
            }
        }

        // 割込み番号が同じISRのテーブルを作成
        comptime var isrcfg_table_intno: [count]ISRCFG = undefined;
        comptime var j: usize = 0;
        inline for (isrcfg_table) |isrcfg2| {
            if (isrcfg.cisr.intno == isrcfg2.cisr.intno) {
                isrcfg_table_intno[j] = isrcfg2;
                j += 1;
            }
        }

        // ISR優先度順にソート
        std.sort.sort(ISRCFG, &isrcfg_table_intno, isrcfgLessThan);

        // ISRを呼び出す割込みハンドラの生成
        cfg_data.addInh(INHINIB{
            .inhno = intnoToInhno(isrcfg.cisr.intno),
            .inhatr = TA_NULL,
            .inthdr = GenInterruptHandler(&isrcfg_table_intno).handler,
        });
    }
}
