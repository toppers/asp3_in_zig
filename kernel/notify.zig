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
///  通知処理
///
usingnamespace @import("kernel_impl.zig");

///
///  呼び出すC言語APIの宣言
///
const c_api = struct {
    extern fn act_tsk(tskid: ID) ER;
    extern fn wup_tsk(tskid: ID) ER;
    extern fn sig_sem(semid: ID) ER;
    extern fn set_flg(flgid: ID, setptn: FLGPTN) ER;
    extern fn psnd_dtq(dtqid: ID, data: usize) ER;
    extern fn loc_cpu() ER;
    extern fn unl_cpu() ER;
    pub const E_OK = 0;
};

///
///  通知ブロックに入れる拡張情報の生成
///
///  拡張情報に入れるパラメータが，C言語による実装の場合と異なっている．
///
pub fn genExinf(comptime nfyinfo: T_NFYINFO) EXINF {
    switch (comptime nfyinfo.nfy) {
        .Handler => |handler| {
            return handler.exinf;
        },
        .SetVar => |setvar| {
            return setvar.p_var;
        },
        .IncVar => |incvar| {
            return incvar.p_var;
        },
        else => {},
    }
    if (comptime nfyinfo.enfy) |enfy| {
        switch (comptime enfy) {
            .SetVar => |setvar| {
                return setvar.p_var;
            },
            .IncVar => |incvar| {
                return incvar.p_var;
            },
            else => {},
        }
    }
    return castToExinf(0);
}

///
///  通知関数の生成
///
fn genNotifyFunction(comptime nfyinfo: T_NFYINFO) type {
    return struct {
        pub fn handler(exinf: EXINF) callconv(.C) void {
            var ercd: ER = undefined;

            switch (comptime nfyinfo.nfy) {
                .Handler => unreachable,
                .SetVar => |setvar| {
                    ptrAlignCast(*usize, exinf).* = setvar.value;
                    if (nfyinfo.enfy != null) {
                        // エラー通知を指定した場合（E_PAR）［NGKI3721］
                        @compileError("E_PAR: illegal error notification.");
                    }
                    ercd = c_api.E_OK;
                },
                .IncVar => {
                    _ = c_api.loc_cpu();
                    ptrAlignCast(*usize, exinf).* += 1;
                    _ = c_api.unl_cpu();
                    if (nfyinfo.enfy != null) {
                        // エラー通知を指定した場合（E_PAR）［NGKI3721］
                        @compileError("E_PAR: illegal error notification.");
                    }
                    ercd = c_api.E_OK;
                },
                .ActTsk => |acttsk| {
                    ercd = c_api.act_tsk(acttsk.tskid);
                },
                .WupTsk => |wuptsk| {
                    ercd = c_api.wup_tsk(wuptsk.tskid);
                },
                .SigSem => |sigsem| {
                    ercd = c_api.sig_sem(sigsem.semid);
                },
                .SetFlg => |setflg| {
                    ercd = c_api.set_flg(setflg.flgid, setflg.flgptn);
                },
                .SndDtq => |snddtq| {
                    ercd = c_api.psnd_dtq(snddtq.dtqid, snddtq.data);
                },
            }
            if (ercd != c_api.E_OK) {
                if (comptime nfyinfo.enfy) |enfy| {
                    switch (comptime enfy) {
                        .SetVar => {
                            ptrAlignCast(*usize, exinf).* =
                                @bitCast(usize, @intCast(isize, ercd));
                        },
                        .IncVar => {
                            _ = c_api.loc_cpu();
                            ptrAlignCast(*usize, exinf).* += 1;
                            _ = c_api.unl_cpu();
                        },
                        .ActTsk => |acttsk| {
                            _ = c_api.act_tsk(acttsk.tskid);
                        },
                        .WupTsk => |wuptsk| {
                            _ = c_api.wup_tsk(wuptsk.tskid);
                        },
                        .SigSem => |sigsem| {
                            _ = c_api.sig_sem(sigsem.semid);
                        },
                        .SetFlg => |setflg| {
                            _ = c_api.set_flg(setflg.flgid, setflg.flgptn);
                        },
                        .SndDtq => |snddtq| {
                            _ = c_api.psnd_dtq(snddtq.dtqid,
                                    @bitCast(usize, @intCast(isize, ercd)));
                        },
                    }
                }
            }
        }
    };
}

///
///  通知ブロックに入れる通知ハンドラの生成
///
pub fn genHandler(comptime nfyinfo: T_NFYINFO) NFYHDR {
    switch (nfyinfo.nfy) {
        .Handler => |handler| {
            if (nfyinfo.enfy != null) {
                // エラー通知を指定した場合（E_PAR）［NGKI3721］
                @compileError("E_PAR: illegal error notification.");
            }
            return handler.tmehdr;
        },
        else => {
            return genNotifyFunction(nfyinfo).handler;
        },
    }
}

///
///  チェック処理のための情報の生成
///
///  拡張情報に入れるパラメータが，usizeへのポインタ型であることをチェッ
///  クする必要がある場合に，TA_CHECK_USIZEを返す．
///
pub fn genFlag(comptime nfyinfo: T_NFYINFO) ATR {
    switch (comptime nfyinfo.nfy) {
        .Handler => |handler| { return 0; },
        .SetVar, .IncVar => { return TA_CHECK_USIZE; },
        else => {},
    }
    if (comptime nfyinfo.enfy) |enfy| {
        switch (comptime enfy) {
            .SetVar, .IncVar => { return TA_CHECK_USIZE; },
            else => {},
        }
    }
    return 0;
}
