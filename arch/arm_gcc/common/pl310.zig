///
///  TOPPERS Software
///      Toyohashi Open Platform for Embedded Real-Time Systems
/// 
///  Copyright (C) 2013-2020 by Embedded and Real-Time Systems Laboratory
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
///  L2キャッシュコントローラ（PL310）の操作ライブラリ
///

///
///  コンフィギュレーションオプションの取り込み
///
const option = @import("../../../include/option.zig");
const PL310_BASE = option.target.PL310_BASE;

///
///  用いるライブラリ
///
const sil = @import("../../../include/sil.zig");

///
///  PL310のレジスタの番地の定義
///
pub const CACHE_ID       = @intToPtr(*u32, PL310_BASE + 0x000);
pub const CACHE_TYPE     = @intToPtr(*u32, PL310_BASE + 0x004);
pub const CTRL           = @intToPtr(*u32, PL310_BASE + 0x100);
pub const AUX_CTRL       = @intToPtr(*u32, PL310_BASE + 0x104);
pub const TAG_RAM_CTRL   = @intToPtr(*u32, PL310_BASE + 0x108);
pub const DATA_RAM_CTRL  = @intToPtr(*u32, PL310_BASE + 0x10c);
pub const EVENT_CNT_CTRL = @intToPtr(*u32, PL310_BASE + 0x200);
pub const EVENT_CNT1_CFG = @intToPtr(*u32, PL310_BASE + 0x204);
pub const EVENT_CNT0_CFG = @intToPtr(*u32, PL310_BASE + 0x208);
pub const EVENT_CNT1     = @intToPtr(*u32, PL310_BASE + 0x20c);
pub const EVENT_CNT0     = @intToPtr(*u32, PL310_BASE + 0x210);
pub const INT_MASK       = @intToPtr(*u32, PL310_BASE + 0x214);
pub const INT_MASK_STAT  = @intToPtr(*u32, PL310_BASE + 0x218);
pub const INT_RAW_STAT   = @intToPtr(*u32, PL310_BASE + 0x21c);
pub const INT_CLEAR      = @intToPtr(*u32, PL310_BASE + 0x220);
pub const CACHE_SYNC     = @intToPtr(*u32, PL310_BASE + 0x730);
pub const INV_PA         = @intToPtr(*u32, PL310_BASE + 0x770);
pub const INV_WAY        = @intToPtr(*u32, PL310_BASE + 0x77c);
pub const CLEAN_PA       = @intToPtr(*u32, PL310_BASE + 0x7b0);
pub const CLEAN_IDX      = @intToPtr(*u32, PL310_BASE + 0x7b8);
pub const CLEAN_WAY      = @intToPtr(*u32, PL310_BASE + 0x7bc);
pub const CLEAN_INV_PA   = @intToPtr(*u32, PL310_BASE + 0x7f0);
pub const CLEAN_INV_IDX  = @intToPtr(*u32, PL310_BASE + 0x7f8);
pub const CLEAN_INV_WAY  = @intToPtr(*u32, PL310_BASE + 0x7Fc);
pub const D_LOCKDOWN0    = @intToPtr(*u32, PL310_BASE + 0x900);
pub const I_LOCKDOWN0    = @intToPtr(*u32, PL310_BASE + 0x904);
pub const DEBUG_CTRL     = @intToPtr(*u32, PL310_BASE + 0xf40);
pub const PREFETCH_CTRL  = @intToPtr(*u32, PL310_BASE + 0xf60);
pub const POWER_CTRL     = @intToPtr(*u32, PL310_BASE + 0xf80);

///
///  キャッシュ補助制御レジスタ（AUX_CTRL）の設定値
///
pub const AUX_CTRL_ASSOCIATIVITY  = 0x00010000;
pub const AUX_CTRL_WAY_SIZE_SHIFT = 17;
pub const AUX_CTRL_WAY_SIZE_MASK  = 0x000e0000;
pub const AUX_CTRL_IGNORE_SHARE   = 0x00400000;
pub const AUX_CTRL_NS_LOCKDOWN    = 0x04000000;
pub const AUX_CTRL_NS_INT_CTRL    = 0x08000000;
pub const AUX_CTRL_DATA_PREFETCH  = 0x10000000;
pub const AUX_CTRL_INST_PREFETCH  = 0x20000000;
pub const AUX_CTRL_EARLY_BRESP    = 0x40000000;

///
///  プリフェッチ制御レジスタ（PREFETCH_CTRL）の設定値
///
pub const PREFETCH_CTRL_INCR_DLINEFILL = 0x00800000;
pub const PREFETCH_CTRL_DATA_PREFETCH  = 0x10000000;
pub const PREFETCH_CTRL_INST_PREFETCH  = 0x20000000;
pub const PREFETCH_CTRL_DLINEFILL      = 0x40000000;

///
///  PL310の操作ライブラリ
///
fn get_way_mask() u32 {
    const aux = sil.rew_mem(AUX_CTRL);
    if ((aux & AUX_CTRL_ASSOCIATIVITY) != 0) {
        // 16ウェイ
        return 0x0000ffff;
    }
    else {
        // 8ウェイ
        return 0x000000ff;
    }
}

fn cache_sync() void {
    sil.wrw_mem(CACHE_SYNC, 0);
}

fn inv_all() void {
    // すべてのウェイを無効化する
    const way_mask = get_way_mask();
    sil.wrw_mem(INV_WAY, 0xffff);
    while ((sil.rew_mem(INV_WAY) & way_mask) != 0) {
    }
    cache_sync();
}

fn debug_set(val: u32) void {
    sil.wrw_mem(DEBUG_CTRL, val);
}

///
///  PL310の初期化
///
pub fn initialize(aux_val: u32, aux_mask: u32) void {
    // L2キャッシュがディスエーブルの場合のみ初期化を行う
    if ((sil.rew_mem(CTRL) & 0x01) == 0) {
        var aux_set = aux_val;
        var prefetch_set: u32 = 0;

        // 共有属性を無視する
        aux_set |= AUX_CTRL_IGNORE_SHARE;

        // 命令プリフェッチをイネーブル
        aux_set |= AUX_CTRL_INST_PREFETCH;
        prefetch_set |= AUX_CTRL_INST_PREFETCH;

        // データプリフェッチをイネーブル
        aux_set |= AUX_CTRL_DATA_PREFETCH;
        prefetch_set |= AUX_CTRL_DATA_PREFETCH;

        // ダブルラインフィルをイネーブル
        prefetch_set |= PREFETCH_CTRL_DLINEFILL;
        prefetch_set |= PREFETCH_CTRL_INCR_DLINEFILL;
                
        // 補助制御レジスタを設定
        var aux = sil.rew_mem(AUX_CTRL);
        sil.wrw_mem(AUX_CTRL, (aux & aux_mask) | aux_set);

        // プリフェッチ制御レジスタを設定
        var prefetch = sil.rew_mem(PREFETCH_CTRL);
        sil.wrw_mem(PREFETCH_CTRL, (prefetch | prefetch_set));

        // L2キャッシュの全体の無効化
        inv_all();
        
        // クロックゲーティングとスタンバイモードをイネーブル
        sil.wrw_mem(POWER_CTRL, 0x03);
        
        // L2キャッシュのイネーブル
        sil.wrw_mem(CTRL, 0x01);
    }    
}

///
///  L2キャッシュのディスエーブル
///
pub fn disable() void {
    clean_and_invalidate_all();
    sil.wrw_mem(CTRL, 0x00);
}

///
///  L2キャッシュ全体の無効化（書き戻さない）
///
pub fn invalidate_all() void {
    debug_set(0x03);
    inv_all();
    debug_set(0x00);
}

///
///  L2キャッシュ全体のクリーンと無効化
///
pub fn clean_and_invalidate_all() void {
    const way_mask = get_way_mask();
    debug_set(0x03);
    sil.wrw_mem(CLEAN_INV_WAY, way_mask);
    while ((sil.rew_mem(CLEAN_INV_WAY) & way_mask) != 0) {
    }
    cache_sync();
    debug_set(0x00);
}
