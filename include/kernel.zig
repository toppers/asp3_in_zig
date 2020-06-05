///
///  TOPPERS/ASP Kernel
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
///  TOPPERS/ASPカーネル 標準定義ファイル
///
///  TOPPERS/ASPカーネルがサポートするサービスコールの宣言と，必要なデー
///  タ型，定数，関数の定義を含むヘッダファイル．
///
const std = @import("std");

///
///  コンフィギュレーションオプションの取り込み
///
const option = @import("../include/option.zig");
const isTrue = option.isTrue;
const decl = option.decl;

///
///  TOPPERS共通のデータ型・定数・関数
///
pub usingnamespace @import("t_stddef.zig");

///
///  ターゲット依存部
///
const target = @import("../target/" ++ option.TARGET ++ "/target_kernel.zig");
pub usingnamespace target.publish;

///
///  サポートする機能
///
pub const TOPPERS_SUPPORT_DIS_INT =     // dis_intがサポートされている
    isTrue(target, "TOPPERS_SUPPORT_DIS_INT");
pub const TOPPERS_SUPPORT_ENA_INT =     // ena_intがサポートされている
    isTrue(target, "TOPPERS_SUPPORT_ENA_INT");
pub const TOPPERS_SUPPORT_CLR_INT =     // clr_intがサポートされている
    isTrue(target, "TOPPERS_SUPPORT_CLR_INT");
pub const TOPPERS_SUPPORT_RAS_INT =     // ras_intがサポートされている
    isTrue(target, "TOPPERS_SUPPORT_RAS_INT");
pub const TOPPERS_SUPPORT_PRB_INT =     // prb_intがサポートされている
    isTrue(target, "TOPPERS_SUPPORT_PRB_INT");

pub const TOPPERS_SUPPORT_OVRHDR =      // オーバランハンドラ機能拡張
    if (option.SUPPORT_OVRHDR) isTrue(target, "TOPPERS_SUPPORT_OVRHDR")
    else false;

///
///  データ型の定義
///

///
///  ビットパターンやオブジェクト番号の型定義
///
pub const FLGPTN = c_uint;      // イベントフラグのビットパターン
pub const INTNO  = c_uint;      // 割込み番号
pub const INHNO  = c_uint;      // 割込みハンドラ番号
pub const EXCNO  = c_uint;      // CPU例外ハンドラ番号

///
///  処理単位の型定義
///
pub const TASK   = fn(exinf: EXINF) callconv(.C) void;
pub const TMEHDR = fn(exinf: EXINF) callconv(.C) void;
pub const OVRHDR = fn(tskid: ID, exinf: EXINF) callconv(.C) void;
pub const ISR    = fn(exinf: EXINF) callconv(.C) void;
pub const INTHDR = fn() callconv(.C) void;
pub const EXCHDR = fn(p_excinf: *c_void) callconv(.C) void;
pub const INIRTN = fn(exinf: EXINF) callconv(.C) void;
pub const TERRTN = fn(exinf: EXINF) callconv(.C) void;

///
///  パケット形式の定義
///
pub const T_CTSK = struct {
    tskatr: ATR = TA_NULL,          // タスク属性
    exinf: EXINF = castToExinf(0),  // タスクの拡張情報
    task: TASK,                     // タスクのメインルーチンの先頭番地
    itskpri: PRI,                   // タスクの起動時優先度
    stksz: usize,                   // タスクのスタック領域のサイズ
    stk: ?[*]u8 = null,             // タスクのスタック領域
};

pub const T_RTSK = extern struct {
    tskstat: STAT,      // タスク状態
    tskpri: PRI,        // タスクの現在優先度
    tskbpri: PRI,       // タスクのベース優先度
    tskwait: STAT,      // 待ち要因
    wobjid: ID,         // 待ち対象のオブジェクトのID
    lefttmo: TMO,       // タイムアウトするまでの時間
    actcnt: c_uint,     // 起動要求キューイング数
    wupcnt: c_uint,     // 起床要求キューイング数
    raster: c_int,      // タスク終了要求状態
    dister: c_int,      // タスク終了禁止状態
};

pub const T_CSEM = struct {
    sematr: ATR = TA_NULL,      // セマフォ属性
    isemcnt: c_uint,            // セマフォの初期資源数
    maxsem: c_uint,             // セマフォの最大資源数
};

pub const T_RSEM = extern struct {
    wtskid: ID,         // セマフォの待ち行列の先頭のタスクのID番号
    semcnt: c_uint,     // セマフォの現在の資源数
};

pub const T_CFLG = struct {
    flgatr: ATR = TA_NULL,      // イベントフラグ属性
    iflgptn: FLGPTN,            // イベントフラグの初期ビットパターン
};

pub const T_RFLG = extern struct {
    wtskid: ID,         // イベントフラグの待ち行列の先頭のタスクのID番号
    flgptn: FLGPTN,     // イベントフラグの現在のビットパターン
};

pub const T_CDTQ = struct {
    dtqatr: ATR = TA_NULL,      // データキュー属性
    dtqcnt: c_uint,             // データキュー管理領域に格納できるデータ数
    dtqmb: ?[*]u8 = null,       // データキュー管理領域
};

pub const T_RDTQ = extern struct {
    stskid: ID,         // データキューの送信待ち行列の先頭のタスクのID番号
    rtskid: ID,         // データキューの受信待ち行列の先頭のタスクのID番号
    sdtqcnt: c_uint,    // データキュー管理領域に格納されているデータの数
};

pub const T_CPDQ = struct {
    pdqatr: ATR = TA_NULL,      // 優先度データキュー属性
    pdqcnt: c_uint,             // 優先度データキュー管理領域に格納できる
                                //                               データ数
    maxdpri: PRI,               // 優先度データキューに送信できるデータ
                                 //                        優先度の最大値
    pdqmb: ?[*]u8 = null,       // 優先度データキュー管理領域
};

pub const T_RPDQ = extern struct {
    stskid: ID,         // 優先度データキューの送信待ち行列の先頭のタスク
                        // のID番号
    rtskid: ID,         // 優先度データキューの受信待ち行列の先頭のタスク
                        // のID番号
    spdqcnt: c_uint,    // 優先度データキュー管理領域に格納されているデー
                        // タの数
};

pub const T_CMTX = struct {
    mtxatr: ATR = TA_NULL,      // ミューテックス属性
    ceilpri: PRI,               // ミューテックスの上限優先度
};

pub const T_RMTX = extern struct {
    htskid: ID,         // ミューテックスをロックしているタスクのID番号
    wtskid: ID,         // ミューテックスの待ち行列の先頭のタスクのID番号
};

pub const T_CMPF = struct {
    mpfatr: ATR = TA_NULL,      // 固定長メモリプール属性
    blkcnt: c_uint,             // 獲得できる固定長メモリブロックの数
    blksz: c_uint,              // 固定長メモリブロックのサイズ（バイト数）
    mpf: ?[*]u8 = null,         // 固定長メモリプール領域
    mpfmb: ?[*]u8 = null,       // 固定長メモリプール管理領域の
};

pub const T_RMPF = extern struct {
    wtskid: ID,         // 固定長メモリプールの待ち行列の先頭のタスクの
                        // ID番号
    fblkcnt: c_uint,    // 固定長メモリプール領域の空きメモリ領域に割り
                        // 付けることができる固定長メモリブロックの数
};

const NfyMode = enum {
    Handler,            // タイムイベントハンドラの呼出し
    SetVar,             // 変数の設定
    IncVar,             // 変数のインクリメント
    ActTsk,             // タスクの起動
    WupTsk,             // タスクの起床
    SigSem,             // セマフォの資源の返却
    SetFlg,             // イベントフラグのセット
    SndDtq,             // データキューへの送信
};

const ErrNfyMode = enum {
    SetVar,             // 変数の設定
    IncVar,             // 変数のインクリメント
    ActTsk,             // タスクの起動
    WupTsk,             // タスクの起床
    SigSem,             // セマフォの資源の返却
    SetFlg,             // イベントフラグのセット
    SndDtq,             // データキューへの送信
};

pub const T_NFYINFO = struct {
    nfy: union(NfyMode) {       // タイムイベントの通知に関する付随情報
        Handler: struct {
            exinf: EXINF = castToExinf(0),
            tmehdr: TMEHDR,
        },
        SetVar: struct {
            p_var: *usize,
            value: usize,
        },
        IncVar: struct {
            p_var: *usize,
        },
        ActTsk: struct {
            tskid: ID,
        },
        WupTsk: struct {
            tskid: ID,
        },
        SigSem: struct {
            semid: ID,
        },
        SetFlg: struct {
            flgid: ID,
            flgptn: FLGPTN,
        },
        SndDtq: struct {
            dtqid: ID,
            data: usize,
        },
    },
    enfy: ?union(ErrNfyMode) {  // エラーの通知に関する付随情報
        SetVar: struct {
            p_var: *usize,
        },
        IncVar: struct {
            p_var: *usize,
        },
        ActTsk: struct {
            tskid: ID,
        },
        WupTsk: struct {
            tskid: ID,
        },
        SigSem: struct {
            semid: ID,
        },
        SetFlg: struct {
            flgid: ID,
            flgptn: FLGPTN,
        },
        SndDtq: struct {
            dtqid: ID,
        },
    } = null,
};

pub const T_CCYC = struct {
    cycatr: ATR = TA_NULL,      // 周期通知属性
    nfyinfo: T_NFYINFO,         // 周期通知の通知方法
    cyctim: RELTIM,             // 周期通知の通知周期
    cycphs: RELTIM,             // 周期通知の通知位相
};

pub const T_RCYC = extern struct {
    cycstat: STAT,      // 周期通知の動作状態
    lefttim: RELTIM,    // 次回通知時刻までの相対時間
};

pub const T_CALM = struct {
    almatr: ATR = TA_NULL,      // アラーム通知属性
    nfyinfo: T_NFYINFO,         // アラーム通知の通知方法
};

pub const T_RALM = extern struct {
    almstat: STAT,      // アラーム通知の動作状態
    lefttim: RELTIM,    // 通知時刻までの相対時間
};

pub const T_DOVR = struct {
    ovratr: ATR = TA_NULL,      // オーバランハンドラ属性
    ovrhdr: OVRHDR,             // オーバランハンドラの先頭番地
};

pub const T_ROVR = extern struct {
    ovrstat: STAT,      // オーバランハンドラの動作状態
    leftotm: PRCTIM,    // 残りプロセッサ時間
};

pub const T_CINT = struct {
    intatr: ATR = TA_NULL,      // 割込み要求ライン属性
    intpri: PRI,                // 割込み優先度
};

pub const T_CISR = struct {
    isratr: ATR = TA_NULL,          // 割込みサービスルーチン属性
    exinf: EXINF = castToExinf(0),  // 割込みサービスルーチンの拡張情報
    intno: INTNO,                   // 割込みサービスルーチンを登録する
                                    //                       割込み番号
    isr: ISR,                       // 割込みサービスルーチンの先頭番地
    isrpri: PRI = 0,                // 割込みサービスルーチン優先度
};

pub const T_DINH = struct {
    inhatr: ATR = TA_NULL,      // 割込みハンドラ属性
    inthdr: INTHDR,             // 割込みハンドラの先頭番地
};

pub const T_DEXC = struct {
    excatr: ATR = TA_NULL,      // CPU例外ハンドラ属性
    exchdr: EXCHDR,             // CPU例外ハンドラの先頭番地
};

pub const T_DICS = struct {
    istksz: usize,              // 非タスクコンテキスト用スタック領域の
                                // サイズ（バイト数）
    istk: ?[*]u8 = null,        // 非タスクコンテキスト用スタック領域
};

pub const T_AINI = struct {
    iniatr: ATR = TA_NULL,          // 初期化ルーチン属性
    exinf: EXINF = castToExinf(0),  // 初期化ルーチンの拡張情報
    inirtn: INIRTN,                 // 初期化ルーチンの先頭番地
};

pub const T_ATER = struct {
    teratr: ATR = TA_NULL,          // 終了処理ルーチン属性
    exinf: EXINF = castToExinf(0),  // 終了処理ルーチンの拡張情報
    terrtn: TERRTN,                 // 終了処理ルーチンの先頭番地
};

///
///  非タスクコンテキストから呼び出せるサービスコール
///
pub const iact_tsk = act_tsk;
pub const iwup_tsk = wup_tsk;
pub const irel_wai = rel_wai;
pub const isns_ter = sns_ter;
pub const isig_sem = sig_sem;
pub const iset_flg = set_flg;
pub const ipsnd_dtq = psnd_dtq;
pub const ifsnd_dtq = fsnd_dtq;
pub const ipsnd_pdq = psnd_pdq;
pub const ifch_hrt = fch_hrt;
pub const ista_alm = sta_alm;
pub const istp_alm = stp_alm;
pub const ista_ovr = sta_ovr;
pub const istp_ovr = stp_ovr;
pub const irot_rdq = rot_rdq;
pub const iget_tid = get_tid;
pub const iloc_cpu = loc_cpu;
pub const iunl_cpu = unl_cpu;
pub const isns_ctx = sns_ctx;
pub const isns_loc = sns_loc;
pub const isns_dsp = sns_dsp;
pub const isns_dpn = sns_dpn;
pub const isns_ker = sns_ker;
pub const iext_ker = ext_ker;
pub const idis_int = dis_int;
pub const iena_int = ena_int;
pub const iclr_int = clr_int;
pub const iras_int = ras_int;
pub const iprb_int = prb_int;
pub const ixsns_dpn = xsns_dpn;

///
///  オブジェクト属性の定義
///
pub const TA_ACT       = 0x01;      // タスクを起動された状態で生成
pub const TA_NOACTQUE  = 0x02;      // 起動要求をキューイングしない

pub const TA_TPRI      = 0x01;      // タスクの待ち行列を優先度順に

pub const TA_WMUL      = 0x02;      // 複数の待ちタスク
pub const TA_CLR       = 0x04;      // イベントフラグのクリア指定

pub const TA_CEILING   = 0x03;      // 優先度上限プロトコル

pub const TA_STA       = 0x02;      // 周期通知を動作状態で生成

pub const TA_NONKERNEL = 0x02;      // カーネル管理外の割込み

pub const TA_ENAINT    = 0x01;      // 割込み要求禁止フラグをクリア
pub const TA_EDGE      = 0x02;      // エッジトリガ

///
///  サービスコールの動作モードの定義
///
pub const TWF_ORW  = 0x01;          // イベントフラグのOR待ち
pub const TWF_ANDW = 0x02;          // イベントフラグのAND待ち

///
///  通知処理モードの定義
///
pub const TNFY_HANDLER = 0x00;      // タイムイベントハンドラの呼出し
pub const TNFY_SETVAR  = 0x01;      // 変数の設定
pub const TNFY_INCVAR  = 0x02;      // 変数のインクリメント
pub const TNFY_ACTTSK  = 0x03;      // タスクの起動
pub const TNFY_WUPTSK  = 0x04;      // タスクの起床
pub const TNFY_SIGSEM  = 0x05;      // セマフォの資源の返却
pub const TNFY_SETFLG  = 0x06;      // イベントフラグのセット
pub const TNFY_SNDDTQ  = 0x07;      // データキューへの送信

pub const TENFY_SETVAR  = 0x10;     // 変数の設定
pub const TENFY_INCVAR  = 0x20;     // 変数のインクリメント
pub const TENFY_ACTTSK  = 0x30;     // タスクの起動
pub const TENFY_WUPTSK  = 0x40;     // タスクの起床
pub const TENFY_SIGSEM  = 0x50;     // セマフォの返却
pub const TENFY_SETFLG  = 0x60;     // イベントフラグのセット
pub const TENFY_SNDDTQ  = 0x70;     // データキューへの送信

///
///  オブジェクトの状態の定義
///
pub const TTS_RUN  = 0x01;          // 実行状態
pub const TTS_RDY  = 0x02;          // 実行可能状態
pub const TTS_WAI  = 0x04;          // 待ち状態
pub const TTS_SUS  = 0x08;          // 強制待ち状態
pub const TTS_WAS  = 0x0c;          // 二重待ち状態
pub const TTS_DMT  = 0x10;          // 休止状態

pub const TTW_SLP  = 0x0001;        // 起床待ち
pub const TTW_DLY  = 0x0002;        // 時間経過待ち
pub const TTW_SEM  = 0x0004;        // セマフォの資源獲得待ち
pub const TTW_FLG  = 0x0008;        // イベントフラグ待ち
pub const TTW_SDTQ = 0x0010;        // データキューへの送信待ち
pub const TTW_RDTQ = 0x0020;        // データキューからの受信待ち
pub const TTW_SPDQ = 0x0100;        // 優先度データキューへの送信待ち
pub const TTW_RPDQ = 0x0200;        // 優先度データキューからの受信待ち
pub const TTW_MTX  = 0x0080;        // ミューテックスのロック待ち状態
pub const TTW_MPF  = 0x2000;        // 固定長メモリブロックの獲得待ち

pub const TCYC_STP = 0x01;          // 周期通知が動作していない
pub const TCYC_STA = 0x02;          // 周期通知が動作している

pub const TALM_STP = 0x01;          // アラーム通知が動作していない
pub const TALM_STA = 0x02;          // アラーム通知が動作している
  
pub const TOVR_STP = 0x01;          // オーバランハンドラが動作していない
pub const TOVR_STA = 0x02;          // オーバランハンドラが動作している

///
///  その他の定数の定義
///
pub const TSK_SELF = 0;             // 自タスク指定
pub const TSK_NONE = 0;             // 該当するタスクがない

pub const TPRI_SELF = 0;            // 自タスクのベース優先度
pub const TPRI_INI = 0;             // タスクの起動時優先度

pub const TIPM_ENAALL = 0;          // 割込み優先度マスク全解除

///
///  構成定数とマクロ
///

///
///  優先度の範囲
///
pub const TMIN_TPRI   = 1;          // タスク優先度の最小値（最高値）
pub const TMAX_TPRI   = 16;         // タスク優先度の最大値（最低値）
pub const TMIN_DPRI   = 1;          // データ優先度の最小値（最高値）
pub const TMAX_DPRI   = 16;         // データ優先度の最大値（最低値）
pub const TMIN_INTPRI = target.TMIN_INTPRI; // 割込み優先度の最小値（最高値）
pub const TMAX_INTPRI = target.TMAX_INTPRI; // 割込み優先度の最大値（最低値）
pub const TMIN_ISRPRI = 1;          // 割込みサービスルーチン優先度の最小値
pub const TMAX_ISRPRI = 16;         // 割込みサービスルーチン優先度の最大値

///
///  バージョン情報
///
pub const TKERNEL_MAKER = 0x0118;   // カーネルのメーカーコード
pub const TKERNEL_PRID  = 0x0007;   // カーネルの識別番号
pub const TKERNEL_SPVER = 0xf635;   // カーネル仕様のバージョン番号
pub const TKERNEL_PRVER = 0x3060;   // カーネルのバージョン番号

///
///  キューイング回数の最大値
///
pub const TMAX_ACTCNT = 1;          // 起動要求キューイング数の最大値
pub const TMAX_WUPCNT = 1;          // 起床要求キューイング数の最大値

///
///  ビットパターンのビット数
///
pub const TBIT_FLGPTN = @bitSizeOf(FLGPTN);
                                    // イベントフラグのビット数

///
///  システム時刻の調整できる範囲（単位：μ秒）
///
pub const TMIN_ADJTIM = -1000000;   // システム時刻の最小調整時間
pub const TMAX_ADJTIM = 1000000;    // システム時刻の最大調整時間

///
///  オーバランハンドラの残りプロセッサ時間の最大値（単位：μ秒）
///
pub const TMAX_OVRTIM = decl(u32, target, "TMAX_OVRTIM", std.math.maxInt(u32));

///
///  その他の構成定数
///
pub const TMAX_MAXSEM = std.math.maxInt(c_uint);
                                        // セマフォの最大資源数の最大値
pub const TCYC_HRTCNT: ?comptime_int =  // 高分解能タイマのタイマ周期
    decl(?comptime_int, target, "TCYC_HRTCNT", null);
pub const TSTEP_HRTCNT = target.TSTEP_HRTCNT;
                                        // 高分解能タイマのカウント値の進み幅

///
///  メモリ領域確保のための関数
///
///  以下のTOPPERS_ROUND_SZの定義は，unitが2の巾乗であることを仮定して
///  いる．
///
pub fn TOPPERS_COUNT_SZ(sz: usize, unit: usize) usize {
    return (sz + unit - 1) / unit;
}
pub fn TOPPERS_ROUND_SZ(sz: usize, unit: usize) usize {
    return (sz + unit - 1) & ~(unit - 1);
}

pub fn COUNT_STK_T(sz: usize) usize {
    return TOPPERS_COUNT_SZ(sz, sizeOf(STK_T));
}
pub fn ROUND_STK_T(sz: usize) usize {
    return TOPPERS_ROUND_SZ(sz, sizeof(STK_T));
}

pub fn COUNT_MPF_T(blksz: usize) usize {
    return TOPPERS_COUNT_SZ(blksz, sizeof(MPF_T));
}
pub fn ROUND_MPF_T(blksz: usize) usize {
    return TOPPERS_ROUND_SZ(blksz, sizeof(MPF_T));
}
