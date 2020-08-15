///
///  TOPPERS/ASP Kernel
///      Toyohashi Open Platform for Embedded Real-Time Systems/
///      Advanced Standard Profile Kernel
/// 
///  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
///                              Toyohashi Univ. of Technology, JAPAN
///  Copyright (C) 2004-2020 by Embedded and Real-Time Systems Laboratory
///              Graduate School of Information Science, Nagoya Univ., JAPAN
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
///  サンプルプログラム(1)の本体
///
///  ASPカーネルの基本的な動作を確認するためのサンプルプログラム．サン
///  プルプログラム本体とコンフィギュレーション記述を，1つのZigファイ
///  ルに記述する（★まだそうなっていない）．
///
///  プログラムの概要:
///
///  ユーザインタフェースを受け持つメインタスク（MAIN_TASK）と，3つの並
///  行実行されるタスク（TASK1〜TASK3），例外処理タスク（EXC_TASK）の5
///  つのタスクを用いる．これらの他に，システムログタスクが動作する．ま
///  た，周期ハンドラ，アラームハンドラ，割込みサービスルーチン，CPU例
///  外ハンドラ，オーバランハンドラをそれぞれ1つ用いる．
///
///  並行実行されるタスクは，task_loop回のループを実行する度に，タスク
///  が実行中であることをあらわすメッセージを表示する．ループを実行する
///  のは，プログラムの動作を確認しやすくするためである．また，低速なシ
///  リアルポートを用いてメッセージを出力する場合に，すべてのメッセージ
///  が出力できるように，メッセージの量を制限するという理由もある．
///
///  周期ハンドラ，アラームハンドラ，割込みサービスルーチンは，3つの優
///  先度（HIGH_PRIORITY，MID_PRIORITY，LOW_PRIORITY）のレディキューを
///  回転させる．周期ハンドラは，プログラムの起動直後は停止状態になって
///  いる．
///
///  CPU例外ハンドラは，CPU例外からの復帰が可能な場合には，例外処理タス
///  クを起動する．例外処理タスクは，CPU例外を起こしたタスクに対して，
///  終了要求を行う．
///
///  メインタスクは，シリアルポートからの文字入力を行い（文字入力を待っ
///  ている間は，並行実行されるタスクが実行されている），入力された文字
///  に対応した処理を実行する．入力された文字と処理の関係は次の通り．
///  Control-Cまたは'Q'が入力されると，プログラムを終了する．
///
///  '1' : 対象タスクをTASK1に切り換える（初期設定）．
///  '2' : 対象タスクをTASK2に切り換える．
///  '3' : 対象タスクをTASK3に切り換える．
///  'a' : 対象タスクをact_tskにより起動する．
///  'A' : 対象タスクに対する起動要求をcan_actによりキャンセルする．
///  'e' : 対象タスクにext_tskを呼び出させ，終了させる．
///  't' : 対象タスクをter_tskにより強制終了する．
///  '>' : 対象タスクの優先度をHIGH_PRIORITYにする．
///  '=' : 対象タスクの優先度をMID_PRIORITYにする．
///  '<' : 対象タスクの優先度をLOW_PRIORITYにする．
///  'G' : 対象タスクの優先度をget_priで読み出す．
///  's' : 対象タスクにslp_tskを呼び出させ，起床待ちにさせる．
///  'S' : 対象タスクにtslp_tsk(10秒)を呼び出させ，起床待ちにさせる．
///  'w' : 対象タスクをwup_tskにより起床する．
///  'W' : 対象タスクに対する起床要求をcan_wupによりキャンセルする．
///  'l' : 対象タスクをrel_waiにより強制的に待ち解除にする．
///  'u' : 対象タスクをsus_tskにより強制待ち状態にする．
///  'm' : 対象タスクの強制待ち状態をrsm_tskにより解除する．
///  'd' : 対象タスクにdly_tsk(10秒)を呼び出させ，時間経過待ちにさせる．
///  'x' : 対象タスクにras_terにより終了要求する．
///  'y' : 対象タスクにdis_terを呼び出させ，タスク終了を禁止する．
///  'Y' : 対象タスクにena_terを呼び出させ，タスク終了を許可する．
///  'r' : 3つの優先度（HIGH_PRIORITY，MID_PRIORITY，LOW_PRIORITY）のレ
///        ディキューを回転させる．
///  'c' : 周期ハンドラを動作開始させる．
///  'C' : 周期ハンドラを動作停止させる．
///  'b' : アラームハンドラを5秒後に起動するよう動作開始させる．
///  'B' : アラームハンドラを動作停止させる．
///  'z' : 対象タスクにCPU例外を発生させる（ターゲットによっては復帰可能）．
///  'Z' : 対象タスクにCPUロック状態でCPU例外を発生させる（復帰不可能）．
///  'V' : 短いループを挟んで，fch_hrtで高分解能タイマを2回読む．
///  'o' : 対象タスクに対してオーバランハンドラを動作開始させる．
///  'O' : 対象タスクに対してオーバランハンドラを動作停止させる．
///  'v' : 発行したシステムコールを表示する（デフォルト）．
///  'q' : 発行したシステムコールを表示しない．
///

///
///  使用するカーネルおよびライブラリ
///
usingnamespace @import("../include/kernel.zig");
usingnamespace @import("../include/t_syslog.zig");

///
///  コンフィギュレーションオプションの取り込み
///
pub const option = @import("../include/option.zig");

///
///  C言語ヘッダファイルの取り込み
///
const c = @cImport({
    @cDefine("UINT_C(val)", "val");
    @cDefine("ULONG_C(val)", "val");
    @cInclude("sample3.h");
    @cInclude("include/t_stdlib.h");
    @cInclude("syssvc/serial.h");
    @cInclude("syssvc/syslog.h");
});

//#include "kernel_cfg.h"
extern const TASK1: ID;
extern const TASK2: ID;
extern const TASK3: ID;
extern const EXC_TASK: ID;
extern const CYCHDR1: ID;
extern const ALMHDR1: ID;

///
///  サービスコールのエラーのログ出力
///
fn svc_perror(ercd: ER) void {
    if (ercd < 0) {
        syslog(LOG_ERROR, "%s (%d) reported.",
               .{ c.itron_strerror(ercd), SERCD(ercd) });
    }
}

///
///  プロセッサ時間の消費
///
///  ループによりプロセッサ時間を消費する．最適化ができないように，ルー
///  プ内でvolatile変数を読み込む．
///
var volatile_var: u32 = undefined;

noinline fn consume_time(ctime: u32) void {
    var i: u32 = 0;
    while (i < ctime) : (i += 1) {
        const dummy = @ptrCast(*volatile u32, &volatile_var).*;
    }
}

///
///  並行実行されるタスクへのメッセージ領域
///
var message = [_]u8{ 0, 0, 0, };

///
///  ループ回数
///
var task_loop: u32 = undefined;         // タスク内でのループ回数

///
///  タスクの表示用文字列
///
const graph = [3][]const u8{ "|    ", "  +  ", "    *", };

///
///  並行実行されるタスク
///
export fn task(exinf: EXINF) void {
    var n: u32 = 0;
    var tskno: u32 = @intCast(u32, @ptrToInt(exinf));
    var ch: u8 = undefined;
    var pk_rovr: if (TOPPERS_SUPPORT_OVRHDR) T_ROVR else void = undefined;

    while (true) {
        n += 1;
        if (TOPPERS_SUPPORT_OVRHDR) {
            svc_perror(c.ref_ovr(TSK_SELF, &pk_rovr));
            if ((pk_rovr.ovrstat & TOVR_STA) != 0) {
                syslog(LOG_NOTICE, "task%d is running (%03d).   %s  [%ld]",
                       .{ tskno, n, graph[tskno-1], pk_rovr.leftotm });
            }
            else {
                syslog(LOG_NOTICE, "task%d is running (%03d).   %s",
                       .{ tskno, n, graph[tskno-1]});
            }
        }
        else {
            syslog(LOG_NOTICE, "task%d is running (%03d).   %s",
                   .{ tskno, n, graph[tskno-1] });
        }

        consume_time(task_loop);
        ch = message[tskno-1];
        message[tskno-1] = 0;
        switch (ch) {
            'e' => {
                syslog(LOG_INFO, "#%d#ext_tsk()", .{ tskno });
                svc_perror(c.ext_tsk());
                assert(false);
            },
            's' => {
                syslog(LOG_INFO, "#%d#slp_tsk()", .{ tskno });
                svc_perror(c.slp_tsk());
            },
            'S' => {
                syslog(LOG_INFO, "#%d#tslp_tsk(10_000_000)", .{ tskno });
                svc_perror(c.tslp_tsk(10_000_000));
            },
            'd' => {
                syslog(LOG_INFO, "#%d#dly_tsk(10_000_000)", .{ tskno });
                svc_perror(c.dly_tsk(10_000_000));
            },
            'y' => {
                syslog(LOG_INFO, "#%d#dis_ter()", .{ tskno });
                svc_perror(c.dis_ter());
            },
            'Y' => {
                syslog(LOG_INFO, "#%d#ena_ter()", .{ tskno });
                svc_perror(c.ena_ter());
            },
            'z' => {
                if (@hasDecl(option.target._test, "CPUEXC1")) {
                    syslog(LOG_NOTICE, "#%d#raise CPU exception", .{ tskno });
                    option.target._test.raiseCpuException();
                }
                else {
                    syslog(LOG_NOTICE, "CPU exception is not supported.", .{});
                }
            },
            'Z' => {
                if (@hasDecl(option.target._test, "CPUEXC1")) {
                    svc_perror(c.loc_cpu());
                    syslog(LOG_NOTICE, "#%d#raise CPU exception", .{ tskno });
                    option.target._test.raiseCpuException();
                    svc_perror(c.unl_cpu());
                }
                else {
                    syslog(LOG_NOTICE, "CPU exception is not supported.", .{});
                }
            },
            else => {},
        }
    }
}

///
///  割込みサービスルーチン
///
///  HIGH_PRIORITY，MID_PRIORITY，LOW_PRIORITY の各優先度のレディキュー
///  を回転させる．
///
export fn intno1_isr(exinf: EXINF) void {
    if (@hasDecl(option.target._test, "INTNO1")) {
        option.target._test.intno1_clear();
        svc_perror(c.rot_rdq(c.HIGH_PRIORITY));
        svc_perror(c.rot_rdq(c.MID_PRIORITY));
        svc_perror(c.rot_rdq(c.LOW_PRIORITY));
    }
}

///
///  CPU例外ハンドラ
///
var cpuexc_tskid: ID = undefined;       // CPU例外を起こしたタスクのID
//
export fn cpuexc_handler(p_excinf: *c_void) void {
    syslog(LOG_NOTICE, "CPU exception handler (p_excinf = %08p).",
           .{ p_excinf });
    if (c.sns_ctx() == 0) {
        syslog(LOG_WARNING,
               "sns_ctx() is not true in CPU exception handler.", .{});
    }
    if (c.sns_dpn() == 0) {
        syslog(LOG_WARNING,
               "sns_dpn() is not true in CPU exception handler.", .{});
    }
    syslog(LOG_INFO, "sns_loc = %d, sns_dsp = %d, xsns_dpn = %d",
           .{ c.sns_loc(), c.sns_dsp(), c.xsns_dpn(p_excinf) });

    if (c.xsns_dpn(p_excinf) != 0) {
        syslog(LOG_NOTICE, "Sample program ends with exception.", .{});
        svc_perror(c.ext_ker());
        assert(false);
    }

    svc_perror(c.get_tid(&cpuexc_tskid));
    svc_perror(c.act_tsk(EXC_TASK));
}

///
///  周期ハンドラ
///
///  HIGH_PRIORITY，MID_PRIORITY，LOW_PRIORITY の各優先度のレディキュー
///  を回転させる．
///
export fn cyclic_handler(exinf: EXINF) void {
    svc_perror(c.rot_rdq(c.HIGH_PRIORITY));
    svc_perror(c.rot_rdq(c.MID_PRIORITY));
    svc_perror(c.rot_rdq(c.LOW_PRIORITY));
}

///
///  アラームハンドラ
///
///  HIGH_PRIORITY，MID_PRIORITY，LOW_PRIORITY の各優先度のレディキュー
///  を回転させる．
///
export fn alarm_handler(exinf: EXINF) void {
    svc_perror(c.rot_rdq(c.HIGH_PRIORITY));
    svc_perror(c.rot_rdq(c.MID_PRIORITY));
    svc_perror(c.rot_rdq(c.LOW_PRIORITY));
}

///
///  例外処理タスク
///
export fn exc_task(exinf: EXINF) void {
    svc_perror(c.ras_ter(cpuexc_tskid));
}

///
///  オーバランハンドラ
///
export fn overrun_handler(tskid: ID, exinf: EXINF) void {
    const tskno = @intCast(u32, @ptrToInt(exinf));
    syslog(LOG_NOTICE, "Overrun handler for task%d.", .{ tskno });
}

///
///  メインタスク
///
export fn main_task(exinf: EXINF) void {
    var ch: u8 = 0;
    var tskid: ID = TASK1;
    var tskno: u32 = 1;
    var ercd: ER_UINT = undefined;
    var tskpri: PRI = undefined;
    var stime1: SYSTIM = undefined;
    var stime2: SYSTIM = undefined;
    var hrtcnt1: HRTCNT = undefined;
    var hrtcnt2: HRTCNT = undefined;

    svc_perror(c.syslog_msk_log(c.LOG_UPTO(LOG_INFO), c.LOG_UPTO(LOG_EMERG)));
    syslog(LOG_NOTICE, "Sample program starts (exinf = %d).", .{ exinf });
           
    //
    //  シリアルポートの初期化
    //
    //  システムログタスクと同じシリアルポートを使う場合など，シリア
    //  ルポートがオープン済みの場合にはここでE_OBJエラーになるが，支
    //  障はない．
    //
    ercd = c.serial_opn_por(c.TASK_PORTID);
    if (ercd < 0 and MERCD(ercd) != c.E_OBJ) {
        syslog(LOG_ERROR, "%s (%d) reported by `serial_opn_por'.",
               .{ c.itron_strerror(ercd), SERCD(ercd) });

    }
    svc_perror(c.serial_ctl_por(c.TASK_PORTID,
                                (c.IOCTL_CRLF|c.IOCTL_FCSND|c.IOCTL_FCRCV)));

    //
    //  ループ回数の設定
    //
    //  並行実行されるタスク内でのループの回数（task_loop）は，ループ
    //  の実行時間が約0.4秒になるように設定する．この設定のために，
    //  LOOP_REF回のループの実行時間を，その前後でget_timを呼ぶことで
    //  測定し，その測定結果から空ループの実行時間が0.4秒になるループ
    //  回数を求め，task_loopに設定する．
    //
    //  LOOP_REFは，デフォルトでは1,000,000に設定しているが，想定した
    //  より遅いプロセッサでは，サンプルプログラムの実行開始に時間がか
    //  かりすぎるという問題を生じる．逆に想定したより速いプロセッサで
    //  は，LOOP_REF回のループの実行時間が短くなり，task_loopに設定す
    //  る値の誤差が大きくなるという問題がある．そこで，そのようなター
    //  ゲットでは，target_test.hで，LOOP_REFを適切な値に定義すること
    //  とする．
    //
    //  また，task_loopの値を固定したい場合には，その値をTASK_LOOPにマ
    //  クロ定義する．TASK_LOOPがマクロ定義されている場合，上記の測定
    //  を行わずに，TASK_LOOPに定義された値をループの回数とする．
    //
    //  ターゲットによっては，ループの実行時間の1回目の測定で，本来より
    //  も長めになるものがある．このようなターゲットでは，MEASURE_TWICE
    //  をマクロ定義することで，1回目の測定結果を捨てて，2回目の測定結
    //  果を使う．
    //
    if (@hasDecl(@This(), "TASK_LOOP")) {
        task_loop = TASK_LOOP;
    }
    else {
        if (@hasDecl(@This(), "MEASURE_TWICE")) {
            svc_perror(c.get_tim(&stime1));
            consume_time(c.LOOP_REF);
            svc_perror(c.get_tim(&stime2));
        }
        svc_perror(c.get_tim(&stime1));
        consume_time(c.LOOP_REF);
        svc_perror(c.get_tim(&stime2));

        task_loop = c.LOOP_REF * 400 / @intCast(u32, stime2 - stime1) * 1000;
    }

    //
    //  タスクの起動
    //
    svc_perror(c.act_tsk(TASK1));
    svc_perror(c.act_tsk(TASK2));
    svc_perror(c.act_tsk(TASK3));

    //
    //  メインループ
    //
    while (ch != '\x03' and ch != 'Q') {
        svc_perror(c.serial_rea_dat(c.TASK_PORTID, &ch, 1));
        switch (ch) {
            'e', 's', 'S', 'd', 'y', 'Y', 'z', 'Z' => {
                message[tskno-1] = ch;
            },
            '1' => {
                tskno = 1;
                tskid = TASK1;
            },
            '2' => {
                tskno = 2;
                tskid = TASK2;
            },
            '3' => {
                tskno = 3;
                tskid = TASK3;
            },
            'a' => {
                syslog(LOG_INFO, "#act_tsk(%d)", .{ tskno });
                svc_perror(c.act_tsk(tskid));
            },
            'A' => {
                syslog(LOG_INFO, "#can_act(%d)", .{ tskno });
                ercd = c.can_act(tskid);
                svc_perror(ercd);
                if (ercd >= 0) {
                    syslog(LOG_NOTICE, "can_act(%d) returns %d.",
                           .{ tskno, ercd });
                }
            },
            't' => {
                syslog(LOG_INFO, "#ter_tsk(%d)", .{ tskno });
                svc_perror(c.ter_tsk(tskid));
            },
            '>' => {
                syslog(LOG_INFO, "#chg_pri(%d, HIGH_PRIORITY)", .{ tskno });
                svc_perror(c.chg_pri(tskid, c.HIGH_PRIORITY));
            },
            '=' => {
                syslog(LOG_INFO, "#chg_pri(%d, MID_PRIORITY)", .{ tskno });
                svc_perror(c.chg_pri(tskid, c.MID_PRIORITY));
            },
            '<' => {
                syslog(LOG_INFO, "#chg_pri(%d, LOW_PRIORITY)", .{ tskno });
                svc_perror(c.chg_pri(tskid, c.LOW_PRIORITY));
            },
            'G' => {
                syslog(LOG_INFO, "#get_pri(%d, &tskpri)", .{ tskno });
                ercd = c.get_pri(tskid, &tskpri);
                svc_perror(ercd);
                if (ercd >= 0) {
                    syslog(LOG_NOTICE, "priority of task %d is %d",
                           .{ tskno, tskpri});
                }
            },
            'w' => {
                syslog(LOG_INFO, "#wup_tsk(%d)", .{ tskno });
                svc_perror(c.wup_tsk(tskid));
            },
            'W' => {
                syslog(LOG_INFO, "#can_wup(%d)", .{ tskno });
                ercd = c.can_wup(tskid);
                svc_perror(ercd);
                if (ercd >= 0) {
                    syslog(LOG_NOTICE, "can_wup(%d) returns %d",
                           .{ tskno, ercd });
                }
            },
            'l' => {
                syslog(LOG_INFO, "#rel_wai(%d)", .{ tskno });
                svc_perror(c.rel_wai(tskid));
            },
            'u' => {
                syslog(LOG_INFO, "#sus_tsk(%d)", .{ tskno });
                svc_perror(c.sus_tsk(tskid));
            },
            'm' => {
                syslog(LOG_INFO, "#rsm_tsk(%d)", .{ tskno });
                svc_perror(c.rsm_tsk(tskid));
            },
            'x' => {
                syslog(LOG_INFO, "#ras_ter(%d)", .{ tskno });
                svc_perror(c.ras_ter(tskid));
            },
            'r' => {
                syslog(LOG_INFO, "#rot_rdq(three priorities)", .{});
                svc_perror(c.rot_rdq(c.HIGH_PRIORITY));
                svc_perror(c.rot_rdq(c.MID_PRIORITY));
                svc_perror(c.rot_rdq(c.LOW_PRIORITY));
            },
            'c' => {
                syslog(LOG_INFO, "#sta_cyc(CYCHDR1)", .{});
                svc_perror(c.sta_cyc(CYCHDR1));
            },
            'C' => {
                syslog(LOG_INFO, "#stp_cyc(CYCHDR1)", .{});
                svc_perror(c.stp_cyc(CYCHDR1));
            },
            'b' => {
                syslog(LOG_INFO, "#sta_alm(ALMHDR1, 5_000_000)", .{});
                svc_perror(c.sta_alm(ALMHDR1, 5_000_000));
            },
            'B' => {
                syslog(LOG_INFO, "#stp_alm(ALMHDR1)", .{});
                svc_perror(c.stp_alm(ALMHDR1));
            },

            'V' => {
                hrtcnt1 = c.fch_hrt();
                consume_time(1000);
                hrtcnt2 = c.fch_hrt();
                syslog(LOG_NOTICE, "hrtcnt1 = %tu, hrtcnt2 = %tu",
                       .{ hrtcnt1, hrtcnt2 });
            },

            'o' => {
                if (TOPPERS_SUPPORT_OVRHDR) {
                    syslog(LOG_INFO, "#sta_ovr(%d, 2_000_000)", .{ tskno });
                    svc_perror(c.sta_ovr(tskid, 2_000_000));
                }
                else {
                    syslog(LOG_NOTICE, "sta_ovr is not supported.", .{});
                }
            },
            'O' => {
                if (TOPPERS_SUPPORT_OVRHDR) {
                    syslog(LOG_INFO, "#stp_ovr(%d)", .{ tskno });
                    svc_perror(c.stp_ovr(tskid));
                }
                else {
                    syslog(LOG_NOTICE, "stp_ovr is not supported.", .{});
                }
            },

            'v' => {
                svc_perror(c.syslog_msk_log(c.LOG_UPTO(LOG_INFO),
                                            c.LOG_UPTO(LOG_EMERG)));
            },
            'q' => {
                svc_perror(c.syslog_msk_log(c.LOG_UPTO(LOG_NOTICE),
                                            c.LOG_UPTO(LOG_EMERG)));
            },
            '\x03', 'Q' => {},
            else => {
                syslog(LOG_INFO, "Unknown command: '%c'.", .{ ch });
            },
        }
    }

    syslog(LOG_NOTICE, "Sample program ends.", .{});
    svc_perror(c.ext_ker());
    assert(false);
}
