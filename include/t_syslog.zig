///
///  TOPPERS Software
///      Toyohashi Open Platform for Embedded Real-Time Systems
/// 
///  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
///                                 Toyohashi Univ. of Technology, JAPAN
///  Copyright (C) 2004-2021 by Embedded and Real-Time Systems Laboratory
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
///  システムログ出力を行うための定義
///
///  システムログサービスは，システムのログ情報を出力するためのサービ
///  スである．カーネルからのログ情報の出力にも用いるため，内部で待ち
///  状態にはいることはない．
///
///  ログ情報は，カーネル内のログバッファに書き込むか，低レベルの文字
///  出力関数を用いて出力する．どちらを使うかは，拡張サービスコールで
///  切り換えることができる．
///
///  ログバッファ領域がオーバフローした場合には，古いログ情報を消して
///  上書きする．
///

///
///  コンパイルオプションによるマクロ定義の取り込み
///
const opt = @cImport({});
const TOPPERS_OMIT_SYSLOG = @hasDecl(opt, "TOPPERS_OMIT_SYSLOG");

///
///  TOPPERS共通定義ファイル
///
usingnamespace @import("t_stddef.zig");

///
///  ログ情報の種別の定義
///
pub const LOG_TYPE_COMMENT = 0x01;          // コメント
pub const LOG_TYPE_ASSERT  = 0x02;          // アサーションの失敗

pub const LOG_TYPE_INH     = 0x11;          // 割込みハンドラ
pub const LOG_TYPE_ISR     = 0x12;          // 割込みサービスルーチン
pub const LOG_TYPE_CYC     = 0x13;          // 周期通知
pub const LOG_TYPE_ALM     = 0x14;          // アラーム通知
pub const LOG_TYPE_OVR     = 0x15;          // オーバランハンドラ
pub const LOG_TYPE_EXC     = 0x16;          // CPU例外ハンドラ
pub const LOG_TYPE_TSKSTAT = 0x21;          // タスク状態変化
pub const LOG_TYPE_DSP     = 0x31;          // ディスパッチャ
pub const LOG_TYPE_SVC     = 0x41;          // サービスコール

pub const LOG_ENTER        = 0x00;          // 入口／開始
pub const LOG_LEAVE        = 0x80;          // 出口／終了

///
///  ログ情報の重要度の定義
///
pub const LOG_EMERG   = 0;          //  シャットダウンに値するエラー
pub const LOG_ALERT   = 1;
pub const LOG_CRIT    = 2;
pub const LOG_ERROR   = 3;          // システムエラー
pub const LOG_WARNING = 4;          // 警告メッセージ
pub const LOG_NOTICE  = 5;
pub const LOG_INFO    = 6;
pub const LOG_DEBUG   = 7;          // デバッグ用メッセージ

///
///  ログ情報のデータ構造
///
const LOGTIM = HRTCNT;              // ログ時刻のデータ型
const TNUM_LOGPAR = 6;              // ログパラメータの数
const LOGPAR = usize;               // ログパラメータのデータ型

const SYSLOG = extern struct {
    logtype: c_uint,                // ログ情報の種別
    logtim: LOGTIM,                 // ログ時刻
    logpar: [TNUM_LOGPAR]LOGPAR,    // ログパラメータ
};

///
///  ログ情報の出力
///
///  ログ情報の出力は，システムログ機能のアダプタ経由で行う．
///
extern fn syslog_wri_log(prio: c_uint, p_syslog: *SYSLOG) ER;

///
///  ログ情報のパラメータの強制変換
///
fn logPar(arg: anytype) usize {
    return switch (@typeInfo(@TypeOf(arg))) {
        .Null => 0,
        .Bool => @boolToInt(arg),
        .Int => |int|
            if (int.is_signed) @bitCast(usize, @intCast(isize, arg))
            else @intCast(usize, arg),
        .ComptimeInt =>
            if (arg < 0) @bitCast(usize, @intCast(isize, arg))
            else @intCast(usize, arg),
        .Enum => @enumToInt(arg),
        .Pointer => |pointer|
            @ptrToInt(if (pointer.size == .Slice) arg.ptr else arg),
        .Array => @ptrToInt(&arg),
        .Optional => if (arg) |_arg| logPar(_arg) else 0,
        else => @compileError("unsupported data type for syslog."),
    };
}

///
///  システムログ出力のためのライブラリ関数
///
pub fn t_syslog(prio: c_uint, logtype: c_uint, args: anytype) void {
    if (!TOPPERS_OMIT_SYSLOG) {
        var logbuf: SYSLOG = undefined;

        logbuf.logtype = logtype;
        if (args.len > 0) { logbuf.logpar[0] = logPar(args.@"0"); }
        if (args.len > 1) { logbuf.logpar[1] = logPar(args.@"1"); }
        if (args.len > 2) { logbuf.logpar[2] = logPar(args.@"2"); }
        if (args.len > 3) { logbuf.logpar[3] = logPar(args.@"3"); }
        if (args.len > 4) { logbuf.logpar[4] = logPar(args.@"4"); }
        if (args.len > 5) { logbuf.logpar[5] = logPar(args.@"5"); }
        _ = syslog_wri_log(prio, &logbuf);
    }
}

///
///  ログ情報（コメント）を出力するためのライブラリ関数
///
pub fn syslog(prio: c_uint, format: [:0]const u8, args: anytype) void {
    if (!TOPPERS_OMIT_SYSLOG) {
        var logbuf: SYSLOG = undefined;

        logbuf.logtype = LOG_TYPE_COMMENT;
        logbuf.logpar[0] = logPar(&format[0]);
        if (args.len > 0) { logbuf.logpar[1] = logPar(args.@"0"); }
        if (args.len > 1) { logbuf.logpar[2] = logPar(args.@"1"); }
        if (args.len > 2) { logbuf.logpar[3] = logPar(args.@"2"); }
        if (args.len > 3) { logbuf.logpar[4] = logPar(args.@"3"); }
        if (args.len > 4) { logbuf.logpar[5] = logPar(args.@"4"); }
        _ = syslog_wri_log(prio, &logbuf);
    }
}
