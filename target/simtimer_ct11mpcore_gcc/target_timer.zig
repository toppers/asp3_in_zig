///
///  TOPPERS/ASP Kernel
///      Toyohashi Open Platform for Embedded Real-Time Systems/
///      Advanced Standard Profile Kernel
/// 
///  Copyright (C) 2007-2020 by Embedded and Real-Time Systems Laboratory
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
///  タイマドライバ
///  （CT11MPCore＋タイマドライバシミュレータ用）
///
usingnamespace @import("../../kernel/kernel_impl.zig");

///
///  ターゲットのハードウェア資源の定義
///
const ct11mpcore = @import("../ct11mpcore_gcc/ct11mpcore.zig");
const mpcore = @import("../../arch/arm_gcc/common/mpcore.zig");

///
///  高分解能タイマ割込みハンドラ登録のための定数
///
pub const INHNO_HRT  = mpcore.IRQNO_TMR;                // 割込みハンドラ番号
pub const INTNO_HRT  = mpcore.IRQNO_TMR;                // 割込み番号
pub const INTPRI_HRT = TMAX_INTPRI - 1;                 // 割込み優先度
pub const INTATR_HRT = TA_NULL;                         // 割込み属性

///
///  オーバランタイマ割込みハンドラ登録のための定数
///
pub const INHNO_OVRTIMER = ct11mpcore.EB_IRQNO_TIMER23; // 割込みハンドラ番号
pub const INTNO_OVRTIMER = ct11mpcore.EB_IRQNO_TIMER23; // 割込み番号
pub const INTPRI_OVRTIMER = INTPRI_HRT;                 // 割込み優先度
pub const INTATR_OVRTIMER = TA_EDGE;                    // 割込み属性

///
///  シミュレートされた高分解能タイマ割込みの要求 
///
pub fn raise_hrt_int() void {
    target_impl.raiseInt(INTNO_HRT);
}

///
///  シミュレートされたオーバランタイマ割込みの要求
///
pub fn raise_ovrtimer_int() void {
    target_impl.raiseInt(INTNO_OVRTIMER);
}

///
///  シミュレートされたオーバランタイマ割込み要求のクリア
///
///  ここでオーバランタイマ割込み要求をクリアすると，割込み源の特定に
///  失敗する（QEMUで確認．QEMUだけの問題か，実機にもある問題かは未確
///  認）ため，クリアしない．
///
pub fn clear_ovrtimer_int() void {
//  target_impl.clearInt(INTNO_OVRTIMER);
}

///
///  タイマドライバシミュレータ
///
const sim_timer = @import("../../arch/simtimer/sim_timer.zig");
pub const hrt = sim_timer.hrt;
pub const ovrtimer = sim_timer.ovrtimer;
pub const ExportDefs = sim_timer.ExportDefs;
