///
///  TOPPERS Software
///      Toyohashi Open Platform for Embedded Real-Time Systems/
///      Advanced Standard Profile Kernel
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
///  TOPPERS共通定義ファイル
///
///  TOPPERS関連のすべてのソースファイルでインクルードすべき定義ファイ
///  ル．各種のカーネルやソフトウェア部品で共通に用いることを想定して
///  いる．TOPPERSの各種のカーネルやソフトウェア部品で共通に用いるデー
///  タ型，定数，関数の定義などを含む．
///
const std = @import("std");

///
///  コンフィギュレーションオプションの取り込み
///
const option = @import("../include/option.zig");
const isTrue = option.isTrue;

///
///  ターゲット依存部
///
const target = @import("../target/" ++ option.TARGET ++ "/target_stddef.zig");

///
///  ターゲット依存の定義の取り込み
///
const USE_64BIT_SYSTIM = isTrue(target, "USE_64BIT_SYSTIM");
const USE_64BIT_HRTCNT = isTrue(target, "USE_64BIT_HRTCNT");

///
///  システムログ機能
///
usingnamespace @import("t_syslog.zig");

///
///  共通データ型
///
pub const FN = c_int;               // 機能コード
pub const ER = c_int;               // エラーコード
pub const ID = c_int;               // オブジェクトのID番号
pub const ATR = c_uint;             // オブジェクトの属性
pub const STAT = c_uint;            // オブジェクトの状態
pub const MODE = c_uint;            // サービスコールの動作モード
pub const PRI = c_int;              // 優先度
pub const TMO = u32;                // タイムアウト指定
pub const EXINF = ?*c_void;         // 拡張情報（★Zigの制限に対応）
pub const RELTIM = u32;             // 相対時間［NGKI0550］
pub const SYSTIM = if (USE_64BIT_SYSTIM) u64 else u32;
                                    // システム時刻［NGKI0548］
pub const PRCTIM = u32;             // プロセッサ時間［NGKI0573］
pub const HRTCNT = if (USE_64BIT_HRTCNT) u64 else u32;
                                    // 高分解能タイマのカウント値
pub const FP = fn() callconv(.C) void;
                                    // プログラムの起動番地

pub const ER_BOOL = c_int;          // エラーコードまたは真偽値
pub const ER_ID = c_int;            // エラーコードまたはID番号
pub const ER_UINT = c_int;          // エラーコードまたは符号無し整数

pub const MB_T = usize;             // 管理領域を確保するためのデータ型

pub const ACPTN = u32;              // アクセス許可パターン
pub const ACVCT = struct {          // アクセス許可ベクタ
    acptn1: ACPTN,                  // 通常操作1のアクセス許可パターン
    acptn2: ACPTN,                  // 通常操作2のアクセス許可パターン
    acptn3: ACPTN,                  // 管理操作のアクセス許可パターン
    acptn4: ACPTN,                  // 参照操作のアクセス許可パターン
};

///
///  EXINF型への強制変換
///
pub fn castToExinf(exinf: var) EXINF {
    return switch (@typeInfo(@TypeOf(exinf))) {
        .Null => null,
        .Bool => @intToPtr(EXINF, @boolToInt(exinf)),
        .Int, .ComptimeInt => @intToPtr(EXINF, exinf),
        .Enum => @intToPtr(EXINF, @enumToInt(arg)),
        .Pointer => |pointer|
            @ptrCast(EXINF, if (pointer.size == .Slice) exinf.ptr else exinf),
        .Array => @ptrCast(EXINF, &exinf),
        .Optional =>
            if (exinf) |_exinf| castToExinf(_exinf) else @intToPtr(EXINF, 0),
        else => @compileLog(@typeInfo(@TypeOf(exinf))),
    };
}

///
///  サービスコールにおけるエラー
///
pub const ItronError = error {
    SystemError,
    NotSupported,
    ReservedFunction,
    ReservedAttribute,
    ParameterError,
    IdError,
    ContextError,
    MemoryAccessViolation,
    ObjectAccessViolation,
    IllegalUse,
    NoMemory,
    NoId,
    NoResource,
    ObjectStateError,
    NonExistent,
    QueueingOverflow,
    ReleasedFromWaiting,
    TimeoutError,
    ObjectDeleted,
    ConnectionClosed,
    TerminationRequestRaised,
    WouldBlock,
    BufferOverflow,
    CommunicationError,
};

///
///  オブジェクト属性
///
pub const TA_NULL = 0;          // オブジェクト属性を指定しない

///
///  タイムアウト指定
///
pub const TMO_POL  = 0;                         // ポーリング
pub const TMO_FEVR = std.math.maxInt(TMO);      // 永久待ち
pub const TMO_NBLK = std.math.maxInt(TMO) - 1;  // ノンブロッキング

///
///  エラーコード生成・分解マクロ
///
pub fn ERCD(mercd: ER, sercd: ER) ER {
    return @intCast(ER, (@bitCast(c_uint, sercd) << 8)
                        | @intCast(u8, @bitCast(c_uint, mercd)));
}
pub fn MERCD(ercd: ER) ER {
    return @intCast(ER, @truncate(i8, ercd));
}
pub fn SERCD(ercd: ER) ER {
    return ercd >> 8;
}

///
///  アクセス許可パターン
///
pub const TACP_KERNEL = @as(ACPTN, 0);  // カーネルドメインだけにアクセスを許可
pub const TACP_SHARED = ~@as(ACPTN, 0); // すべてのドメインからアクセスを許可

// アクセス許可パターン生成マクロ
pub fn TACP(domid: ID) ACPTN {          // domidだけにアクセスを許可
    return @as(ACPTN, 1) << @intCast(u5, domid - 1);
}

///
///  相対時間（RELTIM）に指定できる最大値［NGKI0551］
///
pub const TMAX_RELTIM = 4000000000;     // 66分40秒まで指定可

///
///  assert（デバッグ用）
///
noinline fn assert_fail() noreturn {
    syslog(LOG_EMERG, "assertion failed at %x.\x07",
                      .{ @returnAddress() - 4 });
    target.assert_abort();
}

pub fn assert(ok: bool) void {
    // release-fast/smallでは，NDEBUGがtrueになり，assertは削除される．
    if (!option.NDEBUG and !ok) {
        assert_fail();
    }
}

///
///  panic（デバッグ用）
///
pub noinline fn panic(message: []const u8,
             stack_trace: ?*std.builtin.StackTrace) noreturn {
    syslog(LOG_EMERG, "panic: %s at %x.\x07",
                      .{ message, @returnAddress() - 4 });
    target.assert_abort();
}

///
///  warn（デバッグ用）
///
var buffer: std.io.FixedBufferStream([256]u8) = undefined;

pub fn warn(comptime fmt: []const u8, args: var) void {
    buffer.reset();
    buffer.outStream().print(fmt, args) catch {};
    buffer.buffer[buffer.pos] = 0;
    syslog(LOG_EMERG, "%s", .{ buffer.buffer });
}
