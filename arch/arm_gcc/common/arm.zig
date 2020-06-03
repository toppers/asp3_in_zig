///
///  TOPPERS Software
///      Toyohashi Open Platform for Embedded Real-Time Systems
/// 
///  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
///                                 Toyohashi Univ. of Technology, JAPAN
///  Copyright (C) 2006-2020 by Embedded and Real-Time Systems Laboratory
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
///  ARMコアサポートモジュール
///
const std = @import("std");

///
///  ARMコアが持つ機能を判定するための定義
///
pub const Feature = std.Target.arm.Feature;
pub fn isEnabled(feature: Feature) bool {
    return std.builtin.cpu.features.isEnabled(@enumToInt(feature));
}

///
///  メモリが変更されることをコンパイラに伝えるための関数
///
pub fn memory_changed() void {
    asm volatile("":::"memory");
}

///
///  例外関連の定数
///

// ARM例外ベクタ
pub const RESET_VECTOR  = 0x00;
pub const UNDEF_VECTOR  = 0x04;
pub const SVC_VECTOR    = 0x08;
pub const PABORT_VECTOR = 0x0c;
pub const DABORT_VECTOR = 0x10;
pub const IRQ_VECTOR    = 0x18;
pub const FIQ_VECTOR    = 0x1c;

// ARM例外ベクタ番号
pub const RESET_NUMBER  = 0;
pub const UNDEF_NUMBER  = 1;
pub const SVC_NUMBER    = 2;
pub const PABORT_NUMBER = 3;
pub const DABORT_NUMBER = 4;
pub const IRQ_NUMBER    = 6;
pub const FIQ_NUMBER    = 7;

///
///  ステータスレジスタ（CPSR）関連の関数と定数
///

// CPSRの現在値の読出し
//
// clobberに"memory"を指定しないと，最適化で順序が入れ替わってしまう．
//
pub fn current_cpsr() u32 {
    return asm("mrs %[cpsr], cpsr" : [cpsr]"=r"(-> u32) :: "memory");
}

// CPSRの現在値の変更
//
// clobberに"memory"を指定しないと，最適化で順序が入れ替わってしまう．
//
pub fn set_cpsr(cpsr : u32) void {
    asm volatile("msr cpsr_cxsf, %[cpsr]" :: [cpsr]"r"(cpsr) : "memory","cc");
}

// CPSRの割込み禁止ビット
pub const CPSR_IRQ_BIT     = 0x80;
pub const CPSR_FIQ_BIT     = 0x40;
pub const CPSR_FIQ_IRQ_BIT = CPSR_FIQ_BIT | CPSR_IRQ_BIT;
pub const CPSR_INT_MASK    = CPSR_FIQ_IRQ_BIT;

// CPSRのThumbビット
pub const CPSR_THUMB_BIT = 0x20;

// CPSRのモードビット
pub const CPSR_MODE_MASK = 0x1f;
pub const CPSR_USR_MODE  = 0x10;
pub const CPSR_FIQ_MODE  = 0x11;
pub const CPSR_IRQ_MODE  = 0x12;
pub const CPSR_SVC_MODE  = 0x13;
pub const CPSR_ABT_MODE  = 0x17;
pub const CPSR_UND_MODE  = 0x1b;
pub const CPSR_SYS_MODE  = 0x1f;

///
///  割込み禁止／許可関数
///
///  ARMv6から追加されたシステム状態を変更する命令を使った割込み禁止／
///  許可のための関数．
///

// IRQの禁止
pub fn disable_irq() void {
    if (comptime isEnabled(Feature.has_v6)) {
        asm volatile("cpsid i" ::: "memory");
    }
    else @compileError("not supported.");
}

// IRQの許可
pub fn enable_irq() void {
    if (comptime isEnabled(Feature.has_v6)) {
        asm volatile("cpsie i" ::: "memory");
    }
    else @compileError("not supported.");
}

// FIQの禁止
pub fn disable_fiq() void {
    if (comptime isEnabled(Feature.has_v6)) {
        asm volatile("cpsid f" ::: "memory");
    }
    else @compileError("not supported.");
}

// FIQの許可
pub fn enable_fiq() void {
    if (comptime isEnabled(Feature.has_v6)) {
        asm volatile("cpsie f" ::: "memory");
    }
    else @compileError("not supported.");
}

// FIQとIRQの禁止
pub fn disable_fiq_irq() void {
    if (comptime isEnabled(Feature.has_v6)) {
        asm volatile("cpsid fi" ::: "memory");
    }
    else @compileError("not supported.");
}

// FIQとIRQの許可
pub fn enable_fiq_irq() void {
    if (comptime isEnabled(Feature.has_v6)) {
        asm volatile("cpsie fi" ::: "memory");
    }
    else @compileError("not supported.");
}

///
///  浮動小数点例外制御レジスタ関連の関数と定数
///

// 浮動小数点例外制御レジスタの現在値の読出し
pub fn current_fpexc() u32 {
    return asm("vmrs %[fpexc], fpexc" : [fpexc]"=r"(-> u32));
}

// 浮動小数点例外制御レジスタの現在値の変更
pub fn set_fpexc(fpexc: u32) void {
    asm volatile("vmsr fpexc, %[fpexc]" :: [fpexc]"r"(fpexc));
}

// 浮動小数点例外制御レジスタの設定値
pub const FPEXC_ENABLE = 0x40000000;

///
///  CP15のIDレジスタ関連の関数
///

// メインIDレジスタの操作
pub fn CP15_READ_MIDR() u32 {
    return asm("mrc p15, 0, %[reg], c0, c0, 0" : [reg]"=r"(-> u32));
}

// マルチプロセッサアフィニティレジスタの操作（ARMv6以降）
pub fn CP15_READ_MPIDR() u32 {
    if (comptime isEnabled(Feature.has_v6)) {
        return asm("mrc p15, 0, %[reg], c0, c0, 5" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}

// キャッシュタイプレジスタの操作
pub fn CP15_READ_CTR() u32 {
    return asm("mrc p15, 0, %[reg], c0, c0, 1" : [reg]"=r"(-> u32));
}

// キャッシュレベルIDレジスタの操作（ARMv7）
pub fn CP15_READ_CLIDR() u32 {
    if (comptime isEnabled(Feature.has_v7)) {
        return asm("mrc p15, 1, %[reg], c0, c0, 1" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}

// キャッシュサイズ選択レジスタの操作（ARMv7）
pub fn CP15_WRITE_CSSELR(reg: u32) void {
    if (comptime isEnabled(Feature.has_v7)) {
        asm volatile("mcr p15, 2, %[reg], c0, c0, 0" :: [reg]"r"(reg));
    }
    else @compileError("not supported.");
}

// キャッシュサイズIDレジスタの操作（ARMv7）
pub fn CP15_READ_CCSIDR() u32 {
    if (comptime isEnabled(Feature.has_v7)) {
        return asm("mrc p15, 1, %[reg], c0, c0, 0" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}

///
///  CP15のシステム制御レジスタ関連の関数と定数
///

// システム制御レジスタの操作
pub fn CP15_READ_SCTLR() u32 {
    return asm("mrc p15, 0, %[reg], c1, c0, 0" : [reg]"=r"(-> u32));
}
pub fn CP15_WRITE_SCTLR(reg: u32) void {
    asm volatile("mcr p15, 0, %[reg], c1, c0, 0" :: [reg]"r"(reg));
}

//  CP15のシステム制御レジスタの設定値
//
//  ARMv7では，CP15_SCTLR_EXTPAGEは常に1になっている．
//
pub const CP15_SCTLR_EXTPAGE = 0x00800000;
pub const CP15_SCTLR_VECTOR  = 0x00002000;
pub const CP15_SCTLR_ICACHE  = 0x00001000;
pub const CP15_SCTLR_BP      = 0x00000800;
pub const CP15_SCTLR_DCACHE  = 0x00000004;
pub const CP15_SCTLR_MMU     = 0x00000001;

// 補助制御レジスタ（機能はチップ依存）の操作
pub fn CP15_READ_ACTLR() u32 {
    return asm("mrc p15, 0, %[reg], c1, c0, 1" : [reg]"=r"(-> u32));
}
pub fn CP15_WRITE_ACTLR(reg: u32) void {
    asm volatile("mcr p15, 0, %[reg], c1, c0, 1" :: [reg]"r"(reg));
}

// コプロセッサアクセス制御レジスタの操作
pub fn CP15_READ_CPACR() u32 {
    return asm("mrc p15, 0, %[reg], c1, c0, 2" : [reg]"=r"(-> u32));
}
pub fn CP15_WRITE_CPACR(reg: u32) void {
    asm volatile("mcr p15, 0, %[reg], c1, c0, 2" :: [reg]"r"(reg));
}

// CP15のコプロセッサアクセス制御レジスタ（CPACR）の設定値
pub const CP15_CPACR_ASEDIS          = 0x80000000;
pub const CP15_CPACR_D32DIS          = 0x40000000;
pub const CP15_CPACR_CP11_FULLACCESS = 0x00c00000;
pub const CP15_CPACR_CP10_FULLACCESS = 0x00300000;

///
///  CP15によるキャッシュ操作関数
///

// 命令キャッシュ全体の無効化
pub fn CP15_INVALIDATE_ICACHE() void {
    asm volatile("mcr p15, 0, %[reg], c7, c5, 0" :: [reg]"r"(@as(u32, 0)));
}

// 分岐予測全体の無効化
pub fn CP15_INVALIDATE_BP() void {
    asm volatile("mcr p15, 0, %[reg], c7, c5, 6" :: [reg]"r"(@as(u32, 0)));
}

// データキャッシュ全体の無効化（ARMv6以前）
pub fn CP15_INVALIDATE_DCACHE() void {
    if (comptime !isEnabled(Feature.has_v7)) {
        asm volatile("mcr p15, 0, %[reg], c7, c6, 0" :: [reg]"r"(@as(u32, 0)));
    }
    else @compileError("not supported.");
}

// 統合キャッシュ全体の無効化（ARMv6以前）
pub fn CP15_INVALIDATE_UCACHE() void {
    if (comptime !isEnabled(Feature.has_v7)) {
        asm volatile("mcr p15, 0, %[reg], c7, c7, 0" :: [reg]"r"(@as(u32, 0)));
    }
    else @compileError("not supported.");
}

// データキャッシュ全体のクリーンと無効化（ARMv5のみ）
pub fn ARMV5_CLEAN_AND_INVALIDATE_DCACHE() void {
    if (comptime !isEnabled(Feature.has_v6)) {
        asm volatile("1: mrc p15, 0, apsr_nzcv, c7, c14, 3; bne 1b");
    }
    else @compileError("not supported.");
}

// データキャッシュ全体のクリーンと無効化（ARMv6のみ）
pub fn CP15_CLEAN_AND_INVALIDATE_DCACHE() void {
    if (comptime isEnabled(Feature.has_v6)
            and !isEnabled(Feature.has_v7)) {
        asm volatile("mcr p15, 0, %[reg], c7, c14, 0" :: [reg]"r"(@as(u32, 0)));
    }
    else @compileError("not supported.");
}

// 統合キャッシュ全体のクリーンと無効化（ARMv6のみ）
pub fn CP15_CLEAN_AND_INVALIDATE_UCACHE() void {
    if (comptime isEnabled(Feature.has_v6)
            and !isEnabled(Feature.has_v7)) {
        asm volatile("mcr p15, 0, %[reg], c7, c15, 0" :: [reg]"r"(@as(u32, 0)));
    }
    else @compileError("not supported.");
}

// データキャッシュのセット／ウェイ単位の無効化
pub fn CP15_WRITE_DCISW(reg: u32) void {
    asm volatile("mcr p15, 0, %[reg], c7, c6, 2" :: [reg]"r"(reg));
}

// データキャッシュのセット／ウェイ単位のクリーンと無効化
pub fn CP15_WRITE_DCCISW(reg: u32) void {
    asm volatile("mcr p15, 0, %[reg], c7, c14, 2" :: [reg]"r"(reg));
}

///
///  CP15のフォールト状態／アドレス関連の関数と定数
///

// データフォールト状態レジスタの操作（ARMv6以降）
pub fn CP15_READ_DFSR() u32 {
    if (comptime isEnabled(Feature.has_v6)) {
        return asm("mrc p15, 0, %[reg], c5, c0, 0" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}

// フォールト状態レジスタの参照値
pub const CP15_FSR_FS_MASK         = 0x0000040f;
pub const CP15_FSR_FS_ALIGNMENT    = 0x00000001;
pub const CP15_FSR_FS_TRANSLATION1 = 0x00000005;
pub const CP15_FSR_FS_TRANSLATION2 = 0x00000007;
pub const CP15_FSR_FS_PERMISSION1  = 0x0000000d;
pub const CP15_FSR_FS_PERMISSION2  = 0x0000000f;

// データフォールトアドレスレジスタの操作（ARMv6以降）
pub fn CP15_READ_DFAR() u32 {
    if (comptime isEnabled(Feature.has_v6)) {
        return asm("mrc p15, 0, %[reg], c6, c0, 0" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}

// 命令フォールト状態レジスタの操作（ARMv6以降）
pub fn CP15_READ_IFSR() u32 {
    if (comptime isEnabled(Feature.has_v6)) {
        return asm("mrc p15, 0, %[reg], c5, c0, 1" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}

// 命令フォールトアドレスレジスタの操作（ARMv6以降）
pub fn CP15_READ_IFAR() u32 {
    if (comptime isEnabled(Feature.has_v6)) {
        return asm("mrc p15, 0, %[reg], c6, c0, 2" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}

// フォールト状態レジスタの操作（ARMv5のみ）
pub fn CP15_READ_FSR() u32 {
    if (comptime !isEnabled(Feature.has_v6)) {
        return asm("mrc p15, 0, %[reg], c5, c0, 0" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}

// フォールトアドレスレジスタの操作（ARMv5のみ）
pub fn CP15_READ_FAR() u32 {
    if (comptime !isEnabled(Feature.has_v6)) {
        return asm("mrc p15, 0, %[reg], c6, c0, 0" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}

///
///  CP15によるMMUの操作関数（VMSA）
///

// 変換テーブルベース制御レジスタの操作（ARMv6以降）
pub fn CP15_WRITE_TTBCR(reg: u32) void {
    if (comptime isEnabled(Feature.has_v6)) {
        asm volatile("mcr p15, 0, %[reg], c2, c0, 2" :: [reg]"r"(reg));
    }
    else @compileError("not supported.");
}

// 変換テーブルベースレジスタ0の操作
pub fn CP15_READ_TTBR0() u32 {
    return asm("mrc p15, 0, %[reg], c2, c0, 0" : [reg]"=r"(-> u32));
}
pub fn CP15_WRITE_TTBR0(reg: u32) void {
    asm volatile("mcr p15, 0, %[reg], c2, c0, 0" :: [reg]"r"(reg));
}

// 変換テーブルベースレジスタの設定値
pub const CP15_TTBR_RGN_SHAREABLE = 0x00000002;
pub const CP15_TTBR_RGN_WBWA      = 0x00000008;     // ARMv7
pub const CP15_TTBR_RGN_WTHROUGH  = 0x00000010;
pub const CP15_TTBR_RGN_WBACK     = 0x00000018;
pub const CP15_TTBR_RGN_CACHEABLE = 0x00000001;     // ARMv6以前
pub const CP15_TTBR_IRGN_WBWA     = 0x00000040;     // ARMv7
pub const CP15_TTBR_IRGN_WTHROUGH = 0x00000001;     // ARMv7
pub const CP15_TTBR_IRGN_WBACK    = 0x00000041;     // ARMv7

// ドメインアクセス制御レジスタの操作
pub fn CP15_WRITE_DACR(reg: u32) void {
    asm volatile("mcr p15, 0, %[reg], c3, c0, 0" :: [reg]"r"(reg));
}

// コンテキストIDレジスタの操作（ARMv6以降）
pub fn CP15_WRITE_CONTEXTIDR(reg: u32) void {
    if (comptime isEnabled(Feature.has_v6)) {
        asm volatile("mcr p15, 0, %[reg], c13, c0, 1" :: [reg]"r"(reg));
    }
    else @compileError("not supported.");
}

///
///  CP15によるTLBの操作関数（VMSA）
///

// TLB全体の無効化
pub fn CP15_INVALIDATE_TLB() void {
    asm volatile("mcr p15, 0, %[reg], c8, c7, 0" :: [reg]"r"(@as(u32, 0)));
}

///
///  CP15のパフォーマンスモニタ関連の関数と定数（ARMv7のみ）
///

// パフォーマンスモニタ制御レジスタの操作
pub fn CP15_READ_PMCR() u32 {
    if (comptime isEnabled(Feature.has_v7)) {
        return asm("mrc p15, 0, %[reg], c9, c12, 0" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}
pub fn CP15_WRITE_PMCR(reg: u32) void {
    if (comptime isEnabled(Feature.has_v7)) {
        asm volatile("mcr p15, 0, %[reg], c9, c12, 0" :: [reg]"r"(reg));
    }
    else @compileError("not supported.");
}

// パフォーマンスモニタ制御レジスタの設定値
pub const CP15_PMCR_ALLCNTR_ENABLE  = 0x01;
pub const CP15_PMCR_PMCCNTR_DIVIDER = 0x08;

// パフォーマンスモニタカウントイネーブルセットレジスタの操作
pub fn CP15_READ_PMCNTENSET() u32 {
    if (comptime isEnabled(Feature.has_v7)) {
        return asm("mrc p15, 0, %[reg], c9, c12, 1" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}
pub fn CP15_WRITE_PMCNTENSET(reg: u32) void {
    if (comptime isEnabled(Feature.has_v7)) {
        asm volatile("mcr p15, 0, %[reg], c9, c12, 1" :: [reg]"r"(reg));
    }
    else @compileError("not supported.");
}

// パフォーマンスモニタカウントイネーブルセットレジスタの設定値
pub const CP15_PMCNTENSET_CCNTR_ENABLE = 0x80000000;
    
// パフォーマンスモニタサイクルカウントレジスタの操作
pub fn CP15_READ_PMCCNTR() u32 {
    if (comptime isEnabled(Feature.has_v7)) {
        return asm("mrc p15, 0, %[reg], c9, c13, 0" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}
pub fn CP15_WRITE_PMCCNTR(reg: u32) void {
    if (comptime isEnabled(Feature.has_v7)) {
        asm volatile("mcr p15, 0, %[reg], c9, c13, 0" :: [reg]"r"(reg));
    }
    else @compileError("not supported.");
}

///
///  MMU関連の定数（VMSA，ARMv6）
///

// セクションとページのサイズ
pub const SSECTION_SIZE = 0x1000000;
pub const SECTION_SIZE  = 0x0100000;
pub const LPAGE_SIZE    = 0x0010000;
pub const PAGE_SIZE     = 0x0001000;

// セクションテーブルとページテーブルのサイズ
pub const SECTION_TABLE_SIZE  = 0x4000;
pub const SECTION_TABLE_ALIGN = 0x4000;
pub const SECTION_TABLE_ENTRY = SECTION_TABLE_SIZE / @sizeOf(u32);

pub const PAGE_TABLE_SIZE  = 0x0400;
pub const PAGE_TABLE_ALIGN = 0x0400;
pub const PAGE_TABLE_ENTRY = PAGE_TABLE_SIZE / @sizeOf(u32);

// 第1レベルディスクリプタの設定値
pub const MMU_DSCR1_FAULT     = 0x00000;        // フォールト
pub const MMU_DSCR1_PAGETABLE = 0x00001;        // コアースページテーブル
pub const MMU_DSCR1_SECTION   = 0x00002;        // セクション
pub const MMU_DSCR1_SSECTION  = 0x40002;        // スーパーセクション

pub const MMU_DSCR1_SHARED = 0x10000;           // プロセッサ間で共有
pub const MMU_DSCR1_TEX000 = 0x00000;           // TEXビットが000
pub const MMU_DSCR1_TEX001 = 0x01000;           // TEXビットが001
pub const MMU_DSCR1_TEX010 = 0x02000;           // TEXビットが010
pub const MMU_DSCR1_TEX100 = 0x04000;           // TEXビットが100
pub const MMU_DSCR1_CB00   = 0x00000;           // Cビットが0，Bビットが0
pub const MMU_DSCR1_CB01   = 0x00004;           // Cビットが0，Bビットが1
pub const MMU_DSCR1_CB10   = 0x00008;           // Cビットが1，Bビットが0
pub const MMU_DSCR1_CB11   = 0x0000c;           // Cビットが1，Bビットが1

pub const V5_MMU_DSCR1_AP01 = 0x00400;          // APビットが01
pub const V5_MMU_DSCR1_AP10 = 0x00800;          // APビットが10
pub const V5_MMU_DSCR1_AP11 = 0x00c00;          // APビットが11

pub const V6_MMU_DSCR1_NONGLOBAL = 0x20000;     // グローバルでない
pub const V6_MMU_DSCR1_AP001     = 0x00400;     // APビットが001
pub const V6_MMU_DSCR1_AP010     = 0x00800;     // APビットが010
pub const V6_MMU_DSCR1_AP011     = 0x00c00;     // APビットが011
pub const V6_MMU_DSCR1_AP101     = 0x08400;     // APビットが101
pub const V6_MMU_DSCR1_AP110     = 0x08800;     // APビットが110
pub const V6_MMU_DSCR1_AP111     = 0x08c00;     // APビットが111
pub const V6_MMU_DSCR1_ECC       = 0x00200;     // ECCが有効（MPCore）
pub const V6_MMU_DSCR1_NOEXEC    = 0x00010;     // 実行不可

// 第2レベルディスクリプタの設定値
pub const MMU_DSCR2_FAULT = 0x0000;             // フォールト
pub const MMU_DSCR2_LARGE = 0x0001;             // ラージページ
pub const MMU_DSCR2_SMALL = 0x0002;             // スモールページ

pub const MMU_DSCR2_CB00 = 0x0000;              // Cビットが0，Bビットが0
pub const MMU_DSCR2_CB01 = 0x0004;              // Cビットが0，Bビットが1
pub const MMU_DSCR2_CB10 = 0x0008;              // Cビットが1，Bビットが0
pub const MMU_DSCR2_CB11 = 0x000c;              // Cビットが1，Bビットが1

pub const V5_MMU_DSCR2_AP01 = 0x0550;           // AP[0-3]ビットが01
pub const V5_MMU_DSCR2_AP10 = 0x0aa0;           // AP[0-3]ビットが10
pub const V5_MMU_DSCR2_AP11 = 0x0ff0;           // AP[0-3]ビットが11

pub const V6_MMU_DSCR2_NONGLOBAL = 0x0800;      // グローバルでない
pub const V6_MMU_DSCR2_SHARED    = 0x0400;      // プロセッサ間で共有
pub const V6_MMU_DSCR2_AP001     = 0x0010;      // APビットが001
pub const V6_MMU_DSCR2_AP010     = 0x0020;      // APビットが010
pub const V6_MMU_DSCR2_AP011     = 0x0030;      // APビットが011
pub const V6_MMU_DSCR2_AP101     = 0x0210;      // APビットが101
pub const V6_MMU_DSCR2_AP110     = 0x0220;      // APビットが110
pub const V6_MMU_DSCR2_AP111     = 0x0230;      // APビットが111

// ラージページのディスクリプタ用
pub const V6_MMU_DSCR2L_TEX000 = 0x0000;        // TEXビットが000
pub const V6_MMU_DSCR2L_TEX001 = 0x1000;        // TEXビットが001
pub const V6_MMU_DSCR2L_TEX010 = 0x2000;        // TEXビットが010
pub const V6_MMU_DSCR2L_TEX100 = 0x4000;        // TEXビットが100
pub const V6_MMU_DSCR2L_NOEXEC = 0x8000;        // 実行不可

// スモールページのディスクリプタ用
pub const V6_MMU_DSCR2S_TEX000 = 0x0000;        // TEXビットが000
pub const V6_MMU_DSCR2S_TEX001 = 0x0040;        // TEXビットが001
pub const V6_MMU_DSCR2S_TEX010 = 0x0080;        // TEXビットが010
pub const V6_MMU_DSCR2S_TEX100 = 0x0100;        // TEXビットが100
pub const V6_MMU_DSCR2S_NOEXEC = 0x0001;        // 実行不可

///
///  CP15によるメモリバリア関連の関数
///

// 命令同期バリア
pub fn CP15_INST_SYNC_BARRIER() void {
    asm volatile("mcr p15, 0, %[reg], c7, c5, 4"
                     :: [reg]"r"(@as(u32, 0)) : "memory");
}

// データ同期バリア
pub fn CP15_DATA_SYNC_BARRIER() void {
    asm volatile("mcr p15, 0, %[reg], c7, c10, 4"
                     :: [reg]"r"(@as(u32, 0)) : "memory");
}

// データメモリバリア
pub fn CP15_DATA_MEMORY_BARRIER() void {
    asm volatile("mcr p15, 0, %[reg], c7, c10, 5"
                     :: [reg]"r"(@as(u32, 0)) : "memory");
}

///
///  CP15のセキュリティ拡張レジスタ関連の関数（ARMv7のみ）
///

// ベクタベースアドレスレジスタの操作
pub fn CP15_READ_VBAR() u32 {
    if (comptime isEnabled(Feature.has_v7)) {
        return asm("mrc p15, 0, %[reg], c12, c0, 0" : [reg]"=r"(-> u32));
    }
    else @compileError("not supported.");
}
pub fn CP15_WRITE_VBAR(reg: u32) void {
    if (comptime isEnabled(Feature.has_v7)) {
        asm volatile("mcr p15, 0, %[reg], c12, c0, 0" :: [reg]"r"(reg));
    }
    else @compileError("not supported.");
}

///
///  メモリバリア関数
///
///  メモリバリアは，ARMv7では専用命令，ARMv6ではCP15への書込みで実現
///  される．ARMv7のメモリバリア命令は，同期を取る範囲を指定できるが，
///  以下の関数では最大範囲（システム全体，リード／ライトの両方）で同
///  期を取る．
///

// データメモリバリア
//
// このバリアの前後で，メモリアクセスの順序が入れ換わらないようにする．
// マルチコア（厳密にはマルチマスタ）での使用を想定した命令．
//
pub fn data_memory_barrier() void {
    if (comptime isEnabled(Feature.has_v7)) {
        asm volatile("dmb":::"memory");
    }
    else if (comptime isEnabled(Feature.has_v6)) {
        CP15_DATA_MEMORY_BARRIER();
    }
    else @compileError("not supported.");
}

// データ同期バリア
//
// 先行するメモリアクセスが完了するのを待つ．メモリアクセスが副作用を
// 持つ時に，その副作用が起こるのを待つための使用を想定した命令．
//
pub fn data_sync_barrier() void {
    if (comptime isEnabled(Feature.has_v7)) {
        asm volatile("dsb":::"memory");
    }
    else if (comptime isEnabled(Feature.has_v6)) {
        CP15_DATA_SYNC_BARRIER();
    }
    else @compileError("not supported.");
}

pub fn asm_data_sync_barrier(comptime reg: []const u8) []const u8 {
    if (comptime isEnabled(Feature.has_v7)) {
        return " dsb";
    }
    else if (comptime isEnabled(Feature.has_v6)) {
        return " mov " ++ reg ++ ", #0\n"
            ++ " mcr p15, 0, " ++ reg ++ ", c7, c10, 4";
    }
    else @compileError("not supported.");
}

// 命令同期バリア
//
// プログラムが書き換えられた（または，システム状態の変化により実行す
// べきプログラムが変わった）時に，パイプラインをフラッシュするなど，
// 新しいプログラムを読み込むようにする．ARMv6では，プリフェッチフラッ
// シュと呼ばれている．
//
pub fn inst_sync_barrier() void {
    if (comptime isEnabled(Feature.has_v7)) {
        asm volatile("isb":::"memory");
    }
    else if (comptime isEnabled(Feature.has_v6)) {
        CP15_INST_SYNC_BARRIER();
    }
    else @compileError("not supported.");
}

pub fn asm_inst_sync_barrier(comptime reg: []const u8) []const u8 {
    if (comptime isEnabled(Feature.has_v7)) {
        return " isb";
    }
    else if (comptime isEnabled(Feature.has_v6)) {
        return " mov " ++ reg ++ ", #0\n"
            ++ " mcr p15, 0, " ++ reg ++ ", c7, c5, 4";
    }
    else @compileError("not supported.");
}

///
///  例外ベクタの設定関数
///

// High exception vectorsを使うように設定
pub fn set_high_vectors() void {
    var reg = CP15_READ_SCTLR();
    reg |= CP15_SCTLR_VECTOR;
    CP15_WRITE_SCTLR(reg);
}

// Low exception vectorsを使うように設定
pub fn set_low_vectors() void {
    var reg = CP15_READ_SCTLR();
    reg &= ~@as(u32, CP15_SCTLR_VECTOR);
    CP15_WRITE_SCTLR(reg);
}

///
///  分岐予測関連の関数
///

// 分岐予測をイネーブル
pub fn enable_bp() void {
    var reg = CP15_READ_SCTLR();
    reg |= CP15_SCTLR_BP;
    CP15_WRITE_SCTLR(reg);
}

// 分岐予測をディスエーブル
pub fn disable_bp() void {
    var reg = CP15_READ_SCTLR();
    reg &= ~CP15_SCTLR_BP;
    CP15_WRITE_SCTLR(reg);
}

///
///  自プロセッサのインデックス（0オリジン）の取得
///
///  マルチプロセッサアフィニティレジスタを読んで，その下位8ビットを返
///  す．ARMv6では，マルチプロセッサをサポートしている場合にのみ使用で
///  きる．
///
pub fn get_my_prcidx() c_uint {
    if (comptime isEnabled(Feature.has_v6)) {
        var reg = CP15_READ_MPIDR();
        return reg & 0xff;
    }
    else @compileError("not supported.");
}

///
///  キャッシュ関連の関数
///

// データキャッシュのイネーブル
pub fn enable_dcache() void {
    var reg = CP15_READ_SCTLR();
    if ((reg & CP15_SCTLR_DCACHE) == 0) {
        invalidate_dcache();
        reg |= CP15_SCTLR_DCACHE;
        CP15_WRITE_SCTLR(reg);
    }
}

// データキャッシュのディスエーブル
//
// データキャッシュがディスエーブルされている状態で
// clean_and_invalidateを実行すると暴走する場合があるため，データキャッ
// シュの状態を判断して，ディスエーブルされている場合は無効化のみを行
// う．
//
pub fn disable_dcache() void {
    var reg = CP15_READ_SCTLR();
    if ((reg & CP15_SCTLR_DCACHE) == 0) {
        invalidate_dcache();
    }
    else {
        reg &= ~@as(u32, CP15_SCTLR_DCACHE);
        CP15_WRITE_SCTLR(reg);
        clean_and_invalidate_dcache();
    }
}

// 命令キャッシュのイネーブル
pub fn enable_icache() void {
    var reg = CP15_READ_SCTLR();
    if ((reg & CP15_SCTLR_ICACHE) == 0) {
        invalidate_icache();
        reg |= CP15_SCTLR_ICACHE;
        CP15_WRITE_SCTLR(reg);
    }
}

// 命令キャッシュのディスエーブル
pub fn disable_icache() void {
    var reg = CP15_READ_SCTLR();
    reg &= ~@as(u32, CP15_SCTLR_ICACHE);
    CP15_WRITE_SCTLR(reg);
    invalidate_icache();
}

// キャッシュのイネーブル
pub fn enable_cache() void {
    enable_icache();
    enable_dcache();
}

// キャッシュのディスエーブル
pub fn disable_cache() void {
    disable_icache();
    disable_dcache();
}

// ARMv5におけるデータキャッシュの無効化／クリーン
pub fn v5_clean_and_invalidate_dcache() void {
    if (comptime !isEnabled(Feature.has_v6)) {
        V5_CLEAN_AND_INVALIDATE_DCACHE();
    }
}

// ARMv7におけるデータキャッシュの無効化
//
// バリアを2か所に入れているのは，ARMアーキテクチャリファレンスマニュ
// アルのサンプルコードを踏襲した．
//
pub fn v7_invalidate_dcache() void {
    if (comptime isEnabled(Feature.has_v7)) {
        const clidr = CP15_READ_CLIDR();
        const no_levels = (clidr >> 24) & 0x07;
        var level: u32 = 0;
        while (level < no_levels) : (level += 1) {
            if (((clidr >> @intCast(u5, level * 3)) & 0x07) >= 0x02) {
                CP15_WRITE_CSSELR(level << 1);
                inst_sync_barrier();
                const ccsidr = CP15_READ_CCSIDR();
                const no_sets = ((ccsidr >> 13) & 0x7fff) + 1;
                const shift_set = @intCast(u5, (ccsidr & 0x07) + 4);
                const no_ways = ((ccsidr >> 3) & 0x3ff) + 1;
                if (no_ways == 1) {
                    var set: u32 = 0;
                    while (set < no_sets) : (set += 1) {
                        const setlevel = (set << shift_set);
                        CP15_WRITE_DCISW(setlevel);
                    }
                }
                else {
                    const shift_way = @intCast(u5, @clz(u32, no_ways - 1));
                    var way: u32 = 0;
                    while (way < no_ways) : (way += 1) {
                        const waylevel = (way << shift_way) | (level << 1);
                        var set: u32 = 0;
                        while (set < no_sets) : (set += 1) {
                            const setwaylevel = waylevel | (set << shift_set);
                            CP15_WRITE_DCISW(setwaylevel);
                        }
                    }
                }
            }
        }
        data_sync_barrier();
    }
    else @compileError("not supported.");
}

// ARMv7におけるデータキャッシュのクリーンと無効化
//
// バリアを2か所に入れているのは，ARMアーキテクチャリファレンスマニュ
// アルのサンプルコードを踏襲した．
//
pub fn v7_clean_and_invalidate_dcache() void {
    if (comptime isEnabled(Feature.has_v7)) {
        const clidr = CP15_READ_CLIDR();
        const no_levels = (clidr >> 24) & 0x07;
        var level: u32 = 0;
        while (level < no_levels) : (level += 1) {
            if (((clidr >> @intCast(u5, level * 3)) & 0x07) >= 0x02) {
                CP15_WRITE_CSSELR(level << 1);
                inst_sync_barrier();
                const ccsidr = CP15_READ_CCSIDR();
                const no_sets = ((ccsidr >> 13) & 0x7fff) + 1;
                const shift_set = @intCast(u5, (ccsidr & 0x07) + 4);
                const no_ways = ((ccsidr >> 3) & 0x3ff) + 1;
                if (no_ways == 1) {
                    var set: u32 = 0;
                    while (set < no_sets) : (set += 1) {
                        const setlevel = (set << shift_set);
                        CP15_WRITE_DCCISW(setlevel);
                    }
                }
                else {
                    const shift_way = @intCast(u5, @clz(u32, no_ways - 1));
                    var way: u32 = 0;
                    while (way < no_ways) : (way += 1) {
                        const waylevel = (way << shift_way) | (level << 1);
                        var set: u32 = 0;
                        while (set < no_sets) : (set += 1) {
                            const setwaylevel = waylevel | (set << shift_set);
                            CP15_WRITE_DCCISW(setwaylevel);
                        }
                    }
                }
            }
        }
        data_sync_barrier();
    }
    else @compileError("not supported.");
}

// データキャッシュと統合キャッシュの無効化
pub fn invalidate_dcache() void {
    if (comptime isEnabled(Feature.has_v7)) {
        v7_invalidate_dcache();
    }
    else {
        CP15_INVALIDATE_DCACHE();
        CP15_INVALIDATE_UCACHE();
    }
}

// データキャッシュと統合キャッシュのクリーンと無効化
pub fn clean_and_invalidate_dcache() void {
    if (comptime isEnabled(Feature.has_v7)) {
        v7_clean_and_invalidate_dcache();
    }
    else if (comptime isEnabled(Feature.has_v6)) {
        CP15_CLEAN_AND_INVALIDATE_DCACHE();
        CP15_CLEAN_AND_INVALIDATE_UCACHE();
    }
    else {
        v5_clean_and_invalidate_dcache();
    }
}

// 命令キャッシュの無効化
pub fn invalidate_icache() void {
    CP15_INVALIDATE_ICACHE();
}

///
///  分岐予測関連の関数
///

// 分岐予測の無効化
pub fn invalidate_bp() void {
    CP15_INVALIDATE_BP();
    data_sync_barrier();
    inst_sync_barrier();
}

///
///  TLB関連の関数
///

// TLBの無効化
pub fn invalidate_tlb() void {
    CP15_INVALIDATE_TLB();
    data_sync_barrier();
}

///
///  実行時間分布集計サービス向けの関数
///
pub fn invalidate_all() void {
    invalidate_bp();
    invalidate_tlb();
    const reg = CP15_READ_SCTLR();
    if ((reg & CP15_SCTLR_DCACHE) == 0) {
        invalidate_dcache();
    }
    else {
        clean_and_invalidate_dcache();
    }
    invalidate_icache();
}
