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
const std = @import("std");

///
///  タイムイベント管理モジュール
///
usingnamespace @import("kernel_impl.zig");

///
///  ターゲット依存の定義の取り込み
///
const HRTCNT_BOUND: ?comptime_int =
    if (@hasDecl(target_timer.hrt, "HRTCNT_BOUND"))
        target_timer.hrt.HRTCNT_BOUND
    else null;

//
//  TSTEP_HRTCNTの範囲チェック
//
comptime {
    if (TSTEP_HRTCNT > 4000) {
        @compileError("TSTEP_HRTCNT is too large.");
    }
}

//
//  HRTCNT_BOUNDの定義のチェック
//
comptime {
    if (HRTCNT_BOUND) |hrtcnt_bound| {
        var tcyc_hrtcnt: comptime_int = undefined;
        if (TCYC_HRTCNT != null) {
            tcyc_hrtcnt = TCYC_HRTCNT.?;
        }
        else {
            tcyc_hrtcnt = std.math.maxInt(HRTCNT) + 1;
        }
        if (hrtcnt_bound > tcyc_hrtcnt - 50_000) {
            @compileError("HRTCNT_BOUND is too large.");
        }
    }
    else {
        if (HRTCNT != u64 and TCYC_HRTCNT != null) {
            @compileError("HRTCNT_BOUND must be defined.");
        }
    }
}

///
///  イベント時刻のデータ型の定義［ASPD1001］
///
///  タイムイベントヒープに登録するタイムイベントの発生時刻を表現するた
///  めのデータ型．オーバヘッド低減のために，32ビットで扱う．
///
pub const EVTTIM = u32;

///
///  イベント時刻の前後関係の判定［ASPD1009］
///
///  イベント時刻は，boundary_evttimからの相対値で比較する．すなわち，
///  boundary_evttimを最も早い時刻，boundary_evttim−1が最も遅い時刻と
///  みなして比較する．
///
fn EVTTIM_ADVANCE(t: EVTTIM) EVTTIM {
    return t -% boundary_evttim;
}
fn EVTTIM_LT(t1: EVTTIM, t2: EVTTIM) bool {
    return EVTTIM_ADVANCE(t1) < EVTTIM_ADVANCE(t2);
}
fn EVTTIM_LE(t1: EVTTIM, t2: EVTTIM) bool {
    return EVTTIM_ADVANCE(t1) <= EVTTIM_ADVANCE(t2);
}

///
///  コールバック関数のデータ型の定義
///
pub const CBACK = fn (usize) void;

///
///  タイムイベントブロックのデータ型の定義
///
pub const TMEVTB = struct {
    evttim: EVTTIM,     // タイムイベントの発生時刻
    index: usize,       // タイムイベントヒープ中での位置
    callback: CBACK,    // コールバック関数
    arg: usize,         // コールバック関数へ渡す引数
};

///
///  タイムイベントヒープ中のタイムイベントの数
///
var num_tmevt: usize = undefined;

///
///  タイムイベントヒープ操作関数
///

// 親ノードを求める
fn PARENT(index: usize) usize {
    return (index - 1) / 2;
}

// 左の子ノードを求める
fn LCHILD(index: usize) usize {
    return index * 2 + 1;
}

///
///  タイムイベントヒープ中の先頭のイベントの発生時刻
///
fn top_evttim() EVTTIM {
    return cfg._kernel_tmevt_heap[0].evttim;
}

///
///  境界イベント時刻［ASPD1008］
///
pub var boundary_evttim: EVTTIM = undefined;

///
///  現在のイベント時刻と境界イベント時刻の差［ASPD1010］
///
pub const BOUNDARY_MARGIN = 200_000_000;

///
///  最後に現在時刻を算出した時点でのイベント時刻［ASPD1012］
///
pub var current_evttim: EVTTIM = undefined;

///
///  最後に現在時刻を算出した時点での高分解能タイマのカウント値［ASPD1012］
///
pub var current_hrtcnt: HRTCNT = undefined;

///
///  最も進んでいた時のイベント時刻［ASPD1041］
///
pub var monotonic_evttim: EVTTIM = undefined;

///
///  システム時刻のオフセット［ASPD1043］
///
///  getTimeで参照するシステム時刻とmonotonic_evttimの差を保持する．
///
pub var systim_offset: SYSTIM = undefined;

///
///  高分解能タイマ割込みの処理中であることを示すフラグ［ASPD1032］
///
pub var in_signal_time: bool = undefined;

///
///  タイムイベント管理モジュールの初期化［ASPD1061］
///
pub fn initialize_tmevt() void {
    current_evttim = 0;                         //［ASPD1047］
    boundary_evttim = current_evttim -% BOUNDARY_MARGIN;
                                                //［ASPD1048］
    monotonic_evttim = 0;                       //［ASPD1046］
    systim_offset = 0;                          //［ASPD1044］
    in_signal_time = false;                     //［ASPD1033］
    num_tmevt = 0;
}

///
///  タイムイベントの挿入位置を上向きに探索
///
///  時刻evttimに発生するタイムイベントを挿入するノードを空けるために，
///  ヒープの上に向かって空ノードを移動させる．移動前の空ノードの位置
///  をp_tmevtnに渡すと，移動後の空ノードの位置（すなわち挿入位置）を
///  返す．
///
fn tmevt_up(index: usize, evttim: EVTTIM) usize {
    var current = index;
    var parent: usize = undefined;

    while (current > 0) {
        // 親ノードのイベント発生時刻の方が早い（または同じ）ならば，
        // currentが挿入位置なのでループを抜ける．
        parent = PARENT(current);
        if (EVTTIM_LE(cfg._kernel_tmevt_heap[parent].evttim, evttim)) {
            break;
        }

        // 親ノードをcurrentの位置に移動させる．
        cfg._kernel_tmevt_heap[current] = cfg._kernel_tmevt_heap[parent];
        cfg._kernel_tmevt_heap[current].index = current;

        // currentを親ノードの位置に更新．
        current = parent;
    }
    return(current);
}

///
///  タイムイベントの挿入位置を下向きに探索
///
///  時刻evttimに発生するタイムイベントを挿入するノードを空けるために，
///  ヒープの下に向かって空ノードを移動させる．移動前の空ノードの位置
///  をp_tmevtnに渡すと，移動後の空ノードの位置（すなわち挿入位置）を
///  返す．
///
fn tmevt_down(index: usize, evttim: EVTTIM) usize {
    var current = index;
    var child: usize = undefined;
    
    while (LCHILD(current) < num_tmevt) {
        // 左右の子ノードのイベント発生時刻を比較し，早い方の子ノード
        // の位置をchildに設定する．以下の子ノードは，ここで選ばれた方
        // の子ノードのこと．
        child = LCHILD(current);
        if (child + 1 < num_tmevt
                and EVTTIM_LT(cfg._kernel_tmevt_heap[child + 1].evttim,
                              cfg._kernel_tmevt_heap[child].evttim)) {
            child += 1;
        }

        // 子ノードのイベント発生時刻の方が遅い（または同じ）ならば，
        // currentが挿入位置なのでループを抜ける．
        if (EVTTIM_LE(evttim, cfg._kernel_tmevt_heap[child].evttim)) {
            break;
        }

        // 子ノードをcurrentの位置に移動させる．
        cfg._kernel_tmevt_heap[current] = cfg._kernel_tmevt_heap[child];
        cfg._kernel_tmevt_heap[current].index = current;

        // currentを子ノードの位置に更新．
        current = child;
    }
    return(current);
}

///
///  タイムイベントヒープへの追加
///
///  p_tmevtbで指定したタイムイベントブロックを，タイムイベントヒープ
///  に追加する．
///
fn tmevtb_insert(p_tmevtb: *TMEVTB) void {
    var index: usize = undefined;

    // 次に使用する領域から上に挿入位置を探す．
    index = tmevt_up(num_tmevt, p_tmevtb.evttim);

    // タイムイベントをindexの位置に挿入する．
    cfg._kernel_tmevt_heap[index] = p_tmevtb;
    p_tmevtb.index = index;

    // num_tmevtをインクリメントする．
    num_tmevt += 1;
}

///
///  タイムイベントヒープからの削除
///
fn tmevtb_delete(p_tmevtb: *TMEVTB) void {
    var index = p_tmevtb.index;
    var parent: usize = undefined;
    var event_evttim: EVTTIM = undefined;

    // 削除によりタイムイベントヒープが空になる場合は何もしない．
    num_tmevt -= 1;
    if (num_tmevt == 0) {
        return;
    }

    // 削除したノードの位置に最後のノード（num_tmevtの位置のノード）を
    // 挿入し，それを適切な位置へ移動させる．実際には，最後のノードを
    // 実際に挿入するのではなく，削除したノードの位置が空ノードになる
    // ので，最後のノードを挿入すべき位置へ向けて空ノードを移動させる．
    //
    // 最後のノードのイベント発生時刻が，削除したノードの親ノードのイ
    // ベント発生時刻より前の場合には，上に向かって挿入位置を探す．そ
    // うでない場合には，下に向かって探す．
    event_evttim = cfg._kernel_tmevt_heap[num_tmevt].evttim;
    if (index > 0 and EVTTIM_LT(event_evttim,
                                cfg._kernel_tmevt_heap[PARENT(index)].evttim)) {
        // 親ノードをindexの位置に移動させる．
        parent = PARENT(index);
        cfg._kernel_tmevt_heap[index] = cfg._kernel_tmevt_heap[parent];
        cfg._kernel_tmevt_heap[index].index = index;

        // 削除したノードの親ノードから上に向かって挿入位置を探す．
        index = tmevt_up(parent, event_evttim);
    }
    else {
        // 削除したノードから下に向かって挿入位置を探す．
        index = tmevt_down(index, event_evttim);
    }

    // 最後のノードをindexの位置に挿入する．
    cfg._kernel_tmevt_heap[index] = cfg._kernel_tmevt_heap[num_tmevt];
    cfg._kernel_tmevt_heap[index].index = index;
}

/// タイムイベントヒープの先頭のノードの削除
fn tmevtb_delete_top() *TMEVTB {
    var index: usize = undefined;
    var p_top_tmevtb = cfg._kernel_tmevt_heap[0];
    var event_evttim: EVTTIM = undefined;

    // 削除によりタイムイベントヒープが空になる場合は何もしない．
    num_tmevt -= 1;
    if (num_tmevt > 0) {
        // ルートノードに最後のノード（num_tmevtの位置のノード）を挿入
        // し，それを適切な位置へ移動させる．実際には，最後のノードを
        // 実際に挿入するのではなく，ルートノードが空ノードになるので，
        // 最後のノードを挿入すべき位置へ向けて空ノードを移動させる．
        event_evttim = cfg._kernel_tmevt_heap[num_tmevt].evttim;
        index = tmevt_down(0, event_evttim);

        // 最後のノードをindexの位置に挿入する．
        cfg._kernel_tmevt_heap[index] = cfg._kernel_tmevt_heap[num_tmevt];
        cfg._kernel_tmevt_heap[index].index = index;
    }
    return p_top_tmevtb;
}

///
///  現在のイベント時刻の更新
///
///  current_evttimとcurrent_hrtcntを，現在の値に更新する．
///
pub fn update_current_evttim() void {
    var new_hrtcnt: HRTCNT = undefined;
    var hrtcnt_advance: HRTCNT = undefined;
    var previous_evttim: EVTTIM = undefined;

    new_hrtcnt = target_timer.hrt.get_current();    //［ASPD1013］
    hrtcnt_advance = new_hrtcnt -% current_hrtcnt;  //［ASPD1014］
    if (TCYC_HRTCNT != null) {
        if (new_hrtcnt < current_hrtcnt) {
            hrtcnt_advance +%= TCYC_HRTCNT.?;
        }
    }
    current_hrtcnt = new_hrtcnt;                    //［ASPD1016］

    previous_evttim = current_evttim;
    current_evttim +%= @intCast(EVTTIM, hrtcnt_advance);    //［ASPD1015］
    boundary_evttim = current_evttim -% BOUNDARY_MARGIN;    //［ASPD1011］

    if (monotonic_evttim -% previous_evttim
                              < @intCast(EVTTIM, hrtcnt_advance)) {
        if (current_evttim < monotonic_evttim) {    //［ASPD1045］
            systim_offset +%= @as(SYSTIM, 1) << @bitSizeOf(EVTTIM);
        }
        monotonic_evttim = current_evttim;          //［ASPD1042］
    }
}

///
///  現在のイベント時刻を遅い方に丸めたイベント時刻の算出［ASPD1027］
///
///  現在のイベント時刻を更新した後に呼ぶことを想定している．
///
fn calc_current_evttim_ub() EVTTIM {
    return current_evttim +% TSTEP_HRTCNT;
}

///
///  高分解能タイマ割込みの発生タイミングの設定
///
///  現在のイベント時刻を取得した後に呼び出すことを想定している．
///
pub fn set_hrt_event() void {
    if (num_tmevt == 0) {
        // タイムイベントがない場合
        if (HRTCNT_BOUND == null) {
            target_timer.hrt.clear_event();
        }
        else {                                      //［ASPD1007］
            target_timer.hrt.set_event(HRTCNT_BOUND.?);
        }
    }
    else if (EVTTIM_LE(top_evttim(), current_evttim)) {
        target_timer.hrt.raise_event();             //［ASPD1017］
    }
    else {
        const hrtcnt = @intCast(HRTCNT, top_evttim() -% current_evttim);
        if (HRTCNT_BOUND == null or hrtcnt <= HRTCNT_BOUND.?) {
            target_timer.hrt.set_event(hrtcnt);     //［ASPD1006］
        }
        else {                                      //［ASPD1002］
            target_timer.hrt.set_event(HRTCNT_BOUND.?);
        }
    }
}

///
///  タイムイベントの登録
///
///  p_tmevtbで指定したタイムイベントブロックを登録する．タイムイベン
///  トの発生時刻，コールバック関数，コールバック関数へ渡す引数は，
///  p_tmevtbが指すタイムイベントブロック中に設定しておく．
///
///  高分解能タイマ割込みの発生タイミングの設定を行わないため，カーネ
///  ルの初期化時か，高分解能タイマ割込みの処理中で，それが必要ない場
///  合にのみ使用する．
///
pub fn tmevtb_register(p_tmevtb: *TMEVTB) void {
    tmevtb_insert(p_tmevtb);
}

///
///  相対時間指定によるタイムイベントの登録
///
///  timeで指定した相対時間が経過した後にコールバック関数が呼び出され
///  るように，p_tmevtbで指定したタイムイベントブロックを登録する．コー
///  ルバック関数，コールバック関数へ渡す引数は，p_tmevtbが指すタイム
///  イベントブロック中に設定しておく．
///
pub fn tmevtb_enqueue_reltim(p_tmevtb: *TMEVTB, time: RELTIM) void {
    // 現在のイベント時刻とタイムイベントの発生時刻を求める［ASPD1026］．
    update_current_evttim();
    p_tmevtb.evttim = calc_current_evttim_ub() +% time;

    // タイムイベントブロックをヒープに挿入する［ASPD1030］．
    tmevtb_insert(p_tmevtb);

    // 高分解能タイマ割込みの発生タイミングを設定する［ASPD1031］［ASPD1034］．
    if (!in_signal_time and p_tmevtb.index == 0) {
        set_hrt_event();
    }
}

///
///  タイムイベントの登録解除
///
pub fn tmevtb_dequeue(p_tmevtb: *TMEVTB) void {
    var current: usize = undefined;

    // タイムイベントブロックをヒープから削除する［ASPD1039］．
    current = p_tmevtb.index;
    tmevtb_delete(p_tmevtb);

    // 高分解能タイマ割込みの発生タイミングを設定する［ASPD1040］．
    if (!in_signal_time and current == 0) {
        update_current_evttim();
        set_hrt_event();
    }
}

///
///  システム時刻の調整時のエラーチェック
///
///  adjtimで指定された時間の分，システム時刻を調整してよいか判定する．
///  調整してはならない場合にtrue，そうでない場合にfalseを返す．現在の
///  イベント時刻を取得した後に呼び出すことを想定している．
///
pub fn check_adjtim(adjtim: i32) bool {
    if (adjtim > 0) {
        return num_tmevt > 0                    //［NGKI3588］
            and EVTTIM_LE(top_evttim() +% TMAX_ADJTIM, current_evttim);
    }
    else if (adjtim < 0) {                      //［NGKI3589］
        return monotonic_evttim -% current_evttim >= -TMIN_ADJTIM;
    }
    return false;
}

///
///  タイムイベントが発生するまでの時間の計算
///
pub fn tmevt_lefttim(p_tmevtb: *TMEVTB) RELTIM {
    var evttim: EVTTIM = undefined;
    var current_evttim_ub: EVTTIM = undefined;

    // 現在のイベント時刻を遅い方に丸めた時刻を求める［ASPD1050］．
    update_current_evttim();
    current_evttim_ub = calc_current_evttim_ub();

    // タイムイベント発生までの相対時間を求める［ASPD1049］．
    evttim = p_tmevtb.evttim;
    if (EVTTIM_LE(evttim, current_evttim_ub)) {
        // タイムイベントの発生時刻を過ぎている場合には0を返す［NGKI0552］．
        return 0;
    }
    else {
        return @intCast(RELTIM, evttim -% current_evttim_ub);
    }
}

///
///  高分解能タイマ割込みの処理
///
pub fn signal_time() void {
    var p_tmevtb: *TMEVTB = undefined;
    var callflag: bool = true;
    var nocall: c_uint = 0;

    assert(target_impl.senseContext());
    assert(!target_impl.senseLock());

    target_impl.lockCpu();
    defer target_impl.unlockCpu();
    in_signal_time = true;                          //［ASPD1033］
    defer in_signal_time = false;

    while (callflag) {                              //［ASPD1020］
        // コールバック関数を呼び出さなければループを抜ける［ASPD1020］．
        callflag = false;

        // 現在のイベント時刻を求める［ASPD1022］．
        update_current_evttim();

        // 発生時刻がcurrent_evttim以前のタイムイベントがあれば，タイ
        // ムイベントヒープから削除し，コールバック関数を呼び出す
        // ［ASPD1018］［ASPD1019］．
        while (num_tmevt > 0 and EVTTIM_LE(top_evttim(), current_evttim)) {
            p_tmevtb = tmevtb_delete_top();
            p_tmevtb.callback(p_tmevtb.arg);
            callflag = true;
            nocall += 1;
        }
    }

    // タイムイベントが処理されなかった場合．
    if (nocall == 0) {
        syslog(LOG_NOTICE, "no time event is processed in hrt interrupt.", .{});
    }

    // 高分解能タイマ割込みの発生タイミングを設定する［ASPD1025］．
    set_hrt_event();
}

///
///  カーネルの整合性検査のための関数
///

///
///  タイムイベントブロックのチェック
///
pub fn validTMEVTB(p_tmevtb: *TMEVTB) bool {
    // p_tmevtb.indexのチェック
    return (0 <= p_tmevtb.index and p_tmevtb.index < num_tmevt);
}
