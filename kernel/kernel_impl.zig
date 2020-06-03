///
///  TOPPERS/ASP Kernel
///      Toyohashi Open Platform for Embedded Real-Time Systems/
///      Advanced Standard Profile Kernel
/// 
///  Copyright (C) 2020 by Embedded and Real-Time Systems Laboratory
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
///  TOPPERS/ASPカーネル内部向け標準定義ファイル
///
///  このファイルは，ターゲット依存部からusingnamespaceで取り込まれる．
///  そのため，ターゲット依存部で定義されるシンボルをtarget_implから取
///  り込み，このファイル中でも定義すると，二重定義になる．
///

///
///  コンフィギュレーションオプションの取り込み
///
pub const option = @import("../include/option.zig");

///
///  アプリケーションと共通の定義ファイル
///
pub usingnamespace @import("../include/kernel.zig");

///
///  システムログ機能
///
pub usingnamespace @import("../include/t_syslog.zig");

///
///  ターゲット依存情報の定義
///
pub const target_impl = @import("../target/" ++ option.TARGET
                                    ++ "/target_kernel_impl.zig");

///
///  タイマドライバ
///
pub const target_timer = @import("../target/" ++ option.TARGET
                                     ++ "/target_timer.zig");

///
///  カーネル内部で用いるライブラリ
///
pub const sil = @import("../include/sil.zig");
pub const queue = @import("../library/queue.zig");
pub const prio_bitmap = @import("../library/prio_bitmap.zig");

///
///  カーネルを構成するモジュール
///
pub const task_manage = @import("task_manage.zig");
pub const task_refer = @import("task_refer.zig");
pub const task_sync = @import("task_sync.zig");
pub const task_term = @import("task_term.zig");
pub const semaphore = @import("semaphore.zig");
pub const eventflag = @import("eventflag.zig");
pub const dataqueue = @import("dataqueue.zig");
pub const pridataq = @import("pridataq.zig");
pub const mutex = @import("mutex.zig");
pub const mempfix = @import("mempfix.zig");
pub const time_manage = @import("time_manage.zig");
pub const cyclic = @import("cyclic.zig");
pub const alarm = @import("alarm.zig");
pub const overrun = @import("overrun.zig");
pub const sys_manage = @import("sys_manage.zig");
pub const interrupt = @import("interrupt.zig");
pub const exception = @import("exception.zig");
pub const startup = @import("startup.zig");
pub const task = @import("task.zig");
pub const wait = @import("wait.zig");
pub const time_event = @import("time_event.zig");
pub const notify = @import("notify.zig");
pub const check = @import("check.zig");
pub const static_api = @import("static_api.zig");

///
///  コンフィギュレーションデータの取り込み
///
pub const cfg = if (option.BIND_CFG) |CFG_FILE|
        @import("../" ++ CFG_FILE).genConfig({})
    else struct {
        usingnamespace task.ExternTskCfg;
        usingnamespace semaphore.ExternSemCfg;
        usingnamespace eventflag.ExternFlgCfg;
        usingnamespace dataqueue.ExternDtqCfg;
        usingnamespace pridataq.ExternPdqCfg;
        usingnamespace mutex.ExternMtxCfg;
        usingnamespace mempfix.ExternMpfCfg;
        usingnamespace cyclic.ExternCycCfg;
        usingnamespace alarm.ExternAlmCfg;
        usingnamespace overrun.ExternOvrIniB;
        usingnamespace target_impl.ExternIntIniB;
        usingnamespace if (comptime @hasDecl(target_impl, "ExternIntIniB"))
                           target_impl.ExternIntIniB
                       else interrupt.ExternIntIniB;
        usingnamespace if (comptime @hasDecl(target_impl, "ExternInhIniB"))
                           target_impl.ExternInhIniB
                       else interrupt.ExternInhIniB;
        usingnamespace if (comptime @hasDecl(target_impl, "ExternExcIniB"))
                           target_impl.ExternExcIniB
                       else exception.ExternExcIniB;
        usingnamespace startup.ExternIcs;
        usingnamespace startup.ExternIniRtnB;
        usingnamespace startup.ExternTerRtnB;
        pub extern var _kernel_tmevt_heap: [100]*time_event.TMEVTB;
        pub extern fn _kernel_initialize_object() void;
    };

///
///  オブジェクトIDの最小値の定義
///
pub const TMIN_TSKID = 1;       // タスクIDの最小値
pub const TMIN_SEMID = 1;       // セマフォIDの最小値
pub const TMIN_FLGID = 1;       // フラグIDの最小値
pub const TMIN_DTQID = 1;       // データキューIDの最小値
pub const TMIN_PDQID = 1;       // 優先度データキューIDの最小値
pub const TMIN_MTXID = 1;       // ミューテックスIDの最小値
pub const TMIN_MPFID = 1;       // 固定長メモリプールIDの最小値
pub const TMIN_CYCID = 1;       // 周期通知IDの最小値
pub const TMIN_ALMID = 1;       // アラーム通知IDの最小値

///
///  優先度の段階数の定義
///
pub const TNUM_TPRI   = TMAX_TPRI - TMIN_TPRI + 1;
pub const TNUM_DPRI   = TMAX_DPRI - TMIN_DPRI + 1;
pub const TNUM_INTPRI = TMAX_INTPRI - TMIN_INTPRI + 1;

///
///  通知ハンドラの型定義
///
pub const NFYHDR = TMEHDR;

///
///  トレースログの出力
///
pub fn traceLog(comptime log_type: []const u8, args: var) void {
    if (@hasDecl(option.log, log_type)) {
        @field(option.log, log_type)(args);
    }
}

///
///  アラインメントも含めてポインタをキャスト
///
pub fn ptrAlignCast(comptime T: type, ptr: var) T {
    return @ptrCast(T, @alignCast(@alignOf(T), ptr));
}

///
///  チェック処理用の定数値のexport
///
pub fn exportCheck(comptime val: u32, comptime name: []const u8) void {
    _ = struct {
        var placeholder = val;
        comptime { @export(placeholder, .{ .name = "check." ++ name,
                                           .section = ".TOPPERS.check", }); }
    }.placeholder;
}

///
///  インラインアセンブラ中に定数値を埋め込むために用いる関数
///
fn digitToChar(digit: u4) u8 {
    return switch (digit) {
        0...9 => digit + @as(u8, '0'),
        0xa...0xf => digit - 10 + @as(u8, 'a'),
    };
}

pub fn usizeToHexString(comptime val: usize) [8]u8 {
    return [1]u8{ digitToChar((val >> 28) & 0xf) }
        ++ [1]u8{ digitToChar((val >> 24) & 0xf) }
        ++ [1]u8{ digitToChar((val >> 20) & 0xf) }
        ++ [1]u8{ digitToChar((val >> 16) & 0xf) }
        ++ [1]u8{ digitToChar((val >> 12) & 0xf) }
        ++ [1]u8{ digitToChar((val >> 8) & 0xf) }
        ++ [1]u8{ digitToChar((val >> 4) & 0xf) }
        ++ [1]u8{ digitToChar((val >> 0) & 0xf) };
}
