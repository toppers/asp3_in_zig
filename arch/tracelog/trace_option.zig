///
///  TOPPERS Software
///      Toyohashi Open Platform for Embedded Real-Time Systems
/// 
///  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
///                                 Toyohashi Univ. of Technology, JAPAN
///  Copyright (C) 2004-2020 by Embedded and Real-Time Systems Laboratory
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
///  トレースログ機能のサンプル設定
///
usingnamespace @import("../../kernel/kernel_impl.zig");

///
///  トレースログ方法の設定
///
pub fn taskStateChange(args: anytype) void {
    traceWrite(LOG_TYPE_TSKSTAT, .{ args.@"0", args.@"0".tstat });
}
pub fn dispatchLeave(args: anytype) void {
    traceWrite(LOG_TYPE_DSP|LOG_LEAVE, .{ args.@"0" });
}

///
///  トレースログのデータ構造
///
///  システムログ機能のログ情報のデータ構造と同じにしている．
///
const LOGTIM = HRTCNT;              // ログ時刻のデータ型
const TNUM_LOGPAR = 6;              // ログパラメータの数
const LOGPAR = usize;               // ログパラメータのデータ型

const TRACE = extern struct {
    logtype: c_uint,                // ログ情報の種別
    logtim: LOGTIM,                 // ログ時刻
    logpar: [TNUM_LOGPAR]LOGPAR,    // ログパラメータ
};

///
///  TECSで記述されたトレースログ機能を直接呼び出すための定義
///
///  C言語で記述されたアプリケーションから，TECSで記述されたトレースロ
///  グ機能を呼び出すためには，アダプタを用いるのが正当な方法であるが，
///  トレースログ機能がシングルトンであることを利用して直接呼び出す．
///
extern fn tTraceLog_eTraceLog_write(p_trace: *const TRACE) ER;

///
///  ログ情報のパラメータの強制変換
///
fn logPar(arg : anytype) usize {
    return switch (@typeInfo(@TypeOf(arg))) {
        .Bool => @boolToInt(arg),
        .Int, .ComptimeInt => @intCast(usize, arg),
        .Enum => @enumToInt(arg),
        .Pointer => |pointer|
            @ptrToInt(if (pointer.size == .Slice) arg.ptr else arg),
        .Array => @ptrToInt(&arg),
        .Optional => logPar(arg.?),
        else => @compileError("unsupported data type for syslog."),
    };
}

///
///  トレースログの書込み
///
fn traceWrite(logtype: c_uint, args: anytype) void {
    var tracebuf: TRACE = undefined;

    tracebuf.logtype = logtype;
    if (args.len > 0) { tracebuf.logpar[0] = logPar(args.@"0"); }
    if (args.len > 1) { tracebuf.logpar[1] = logPar(args.@"1"); }
    if (args.len > 2) { tracebuf.logpar[2] = logPar(args.@"2"); }
    if (args.len > 3) { tracebuf.logpar[3] = logPar(args.@"3"); }
    if (args.len > 4) { tracebuf.logpar[4] = logPar(args.@"4"); }
    if (args.len > 5) { tracebuf.logpar[5] = logPar(args.@"5"); }
    _ = tTraceLog_eTraceLog_write(&tracebuf);
}
