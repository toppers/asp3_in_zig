/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 * 
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2006-2018 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 * 
 *  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
 *  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
 *      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
 *      スコード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
 *      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
 *      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
 *      の無保証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
 *      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
 *      と．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
 *        作権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
 *        報告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
 *      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 *      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
 *      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
 *      免責すること．
 * 
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 * 
 *  $Id: arm_insn.h 1388 2020-04-01 13:52:54Z ertl-hiro $
 */

/*
 *		ARMコアの特殊命令のインライン関数定義
 *
 *  このヘッダファイルは，arm.hからインクルードされる．arm.hから分離し
 *  ているのは，コンパイラによるインラインアセンブラの記述方法の違いを
 *  吸収するために，このファイルのみを置き換えればよいようにするためで
 *  ある．
 */

#ifndef TOPPERS_ARM_INSN_H
#define TOPPERS_ARM_INSN_H

#include <t_stddef.h>

/*
 *  CLZ（Count Leading Zero）命令
 */
#if __TARGET_ARCH_ARM >= 6

Inline uint32_t
count_leading_zero(uint32_t val)
{
	uint32_t	count;

	Asm("clz %0, %1" : "=r"(count) : "r"(val));
	return(count);
}

#endif /* __TARGET_ARCH_ARM >= 6 */

/*
 *  メモリが変更されることをコンパイラに伝えるためのマクロ
 */
#define ARM_MEMORY_CHANGED	Asm("":::"memory")

/*
 *  ステータスレジスタの操作関数
 */
#ifndef __thumb__

/*
 *  ステータスレジスタ（CPSR）の現在値の読出し
 */
Inline uint32_t
current_cpsr(void)
{
	uint32_t	cpsr;

	Asm("mrs %0, cpsr" : "=r"(cpsr));
	return(cpsr);
}

/*
 *  ステータスレジスタ（CPSR）の現在値の変更
 */
Inline void
set_cpsr(uint32_t cpsr)
{
	Asm("msr cpsr_cxsf, %0" : : "r"(cpsr) : "memory","cc");
}

#else /* __thumb__ */
/*
 *  Thumbモードではmrs/msr命令が使用できないため，関数として実現して，
 *  ARMモードに移行して実行する．
 *
 *  current_cpsrとset_cpsrは，__thumb__が定義されない場合にはヘッダファ
 *  イル中で定義されるインライン関数になるため，core_rename.defに登録
 *  せず，先頭の_kernel_を手書きしている．
 */

/*
 *  ステータスレジスタ（CPSR）の現在値の読出し
 */
extern uint32_t _kernel_current_cpsr(void);
#define current_cpsr()	_kernel_current_cpsr()

/*
 *  ステータスレジスタ（CPSR）の現在値の変更
 */
extern void _kernel_set_cpsr(uint32_t cpsr);
#define set_cpsr(cpsr)	_kernel_set_cpsr(cpsr)

#endif /* __thumb__ */

/*
 *  割込み禁止／許可関数
 *
 *  ARMv6から追加されたシステム状態を変更する命令を使った割込み禁止／許
 *  可のための関数．
 */
#if __TARGET_ARCH_ARM >= 6

/*
 *  IRQの禁止
 */
Inline void
disable_irq(void)
{
	Asm("cpsid i");
}

/*
 *  IRQの許可
 */
Inline void
enable_irq(void)
{
	Asm("cpsie i");
}

/*
 *  FIQの禁止
 */
Inline void
disable_fiq(void)
{
	Asm("cpsid f");
}

/*
 *  FIQの許可
 */
Inline void
enable_fiq(void)
{
	Asm("cpsie f");
}

/*
 *  FIQとIRQの禁止
 */
Inline void
disable_fiq_irq(void)
{
	Asm("cpsid fi");
}

/*
 *  FIQとIRQの許可
 */
Inline void
enable_fiq_irq(void)
{
	Asm("cpsie fi");
}

#endif /* __TARGET_ARCH_ARM >= 6 */

/*
 *  CP15のIDレジスタ操作マクロ
 */

/* メインIDレジスタ */
#define CP15_READ_MIDR(reg)		Asm("mrc p15, 0, %0, c0, c0, 0":"=r"(reg))

/* マルチプロセッサアフィニティレジスタ（ARMv6以降）*/
#if __TARGET_ARCH_ARM >= 6
#define CP15_READ_MPIDR(reg)	Asm("mrc p15, 0, %0, c0, c0, 5":"=r"(reg))
#endif /* __TARGET_ARCH_ARM >= 6 */

/* キャッシュタイプレジスタ */
#define CP15_READ_CTR(reg)		Asm("mrc p15, 0, %0, c0, c0, 1":"=r"(reg))

#if __TARGET_ARCH_ARM == 7
/* キャッシュレベルIDレジスタ（ARMv7） */
#define CP15_READ_CLIDR(reg)	Asm("mrc p15, 1, %0, c0, c0, 1":"=r"(reg))

/* キャッシュサイズ選択レジスタ（ARMv7）*/
#define CP15_WRITE_CSSELR(reg)	Asm("mcr p15, 2, %0, c0, c0, 0"::"r"(reg))

/* キャッシュサイズIDレジスタ（ARMv7）*/
#define CP15_READ_CCSIDR(reg)	Asm("mrc p15, 1, %0, c0, c0, 0":"=r"(reg))
#endif /* __TARGET_ARCH_ARM == 7 */

/*
 *  CP15のシステム制御レジスタ操作マクロ
 */

/* システム制御レジスタ */
#define CP15_READ_SCTLR(reg)	Asm("mrc p15, 0, %0, c1, c0, 0":"=r"(reg))
#define CP15_WRITE_SCTLR(reg)	Asm("mcr p15, 0, %0, c1, c0, 0"::"r"(reg))

/* 補助制御レジスタ（機能はチップ依存）*/
#define CP15_READ_ACTLR(reg)	Asm("mrc p15, 0, %0, c1, c0, 1":"=r"(reg))
#define CP15_WRITE_ACTLR(reg)	Asm("mcr p15, 0, %0, c1, c0, 1"::"r"(reg))

/* コプロセッサアクセス制御レジスタ */
#define CP15_READ_CPACR(reg)	Asm("mrc p15, 0, %0, c1, c0, 2":"=r"(reg))
#define CP15_WRITE_CPACR(reg)	Asm("mcr p15, 0, %0, c1, c0, 2"::"r"(reg))

/*
 *  CP15によるキャッシュ操作マクロ
 */

/* 命令キャッシュ全体の無効化 */
#define CP15_INVALIDATE_ICACHE() \
								Asm("mcr p15, 0, %0, c7, c5, 0"::"r"(0))

/* 分岐予測全体の無効化 */
#define CP15_INVALIDATE_BP()	Asm("mcr p15, 0, %0, c7, c5, 6"::"r"(0))

/* データキャッシュ全体の無効化（ARMv6以前）*/
#if __TARGET_ARCH_ARM <= 6
#define CP15_INVALIDATE_DCACHE() Asm("mcr p15, 0, %0, c7, c6, 0"::"r"(0))
#endif /* __TARGET_ARCH_ARM <= 6 */

/* 統合キャッシュ全体の無効化（ARMv6以前）*/
#if __TARGET_ARCH_ARM <= 6
#define CP15_INVALIDATE_UCACHE() Asm("mcr p15, 0, %0, c7, c7, 0"::"r"(0))
#endif /* __TARGET_ARCH_ARM <= 6 */

/* データキャッシュ全体のクリーンと無効化（ARMv5のみ）*/
#if __TARGET_ARCH_ARM <= 5
#define ARMV5_CLEAN_AND_INVALIDATE_DCACHE() \
						Asm("1: mrc p15, 0, apsr_nzcv, c7, c14, 3; bne 1b")
#endif /* __TARGET_ARCH_ARM <= 5 */

/* データキャッシュ全体のクリーンと無効化（ARMv6のみ）*/
#if __TARGET_ARCH_ARM == 6
#define CP15_CLEAN_AND_INVALIDATE_DCACHE() \
								Asm("mcr p15, 0, %0, c7, c14, 0"::"r"(0))
#endif /* __TARGET_ARCH_ARM == 6 */

/* 統合キャッシュ全体のクリーンと無効化（ARMv6のみ）*/
#if __TARGET_ARCH_ARM == 6
#define CP15_CLEAN_AND_INVALIDATE_UCACHE() \
								Asm("mcr p15, 0, %0, c7, c15, 0"::"r"(0))
#endif /* __TARGET_ARCH_ARM == 6 */

/* データキャッシュのセット／ウェイ単位の無効化 */
#define CP15_WRITE_DCISW(reg)	Asm("mcr p15, 0, %0, c7, c6, 2"::"r"(reg))

/* データキャッシュのセット／ウェイ単位のクリーンと無効化 */
#define CP15_WRITE_DCCISW(reg)	Asm("mcr p15, 0, %0, c7, c14, 2"::"r"(reg))

/*
 *  CP15のフォールト状態／アドレスの操作マクロ
 */
#if __TARGET_ARCH_ARM >= 6
#define CP15_READ_DFSR(reg)		Asm("mrc p15, 0, %0, c5, c0, 0":"=r"(reg))
#define CP15_READ_DFAR(reg)		Asm("mrc p15, 0, %0, c6, c0, 0":"=r"(reg))
#define CP15_READ_IFSR(reg)		Asm("mrc p15, 0, %0, c5, c0, 1":"=r"(reg))
#define CP15_READ_IFAR(reg)		Asm("mrc p15, 0, %0, c6, c0, 2":"=r"(reg))
#else /* __TARGET_ARCH_ARM >= 6 */
#define CP15_READ_FSR(reg)		Asm("mrc p15, 0, %0, c5, c0, 0":"=r"(reg))
#define CP15_READ_FAR(reg)		Asm("mrc p15, 0, %0, c6, c0, 0":"=r"(reg))
#endif /* __TARGET_ARCH_ARM >= 6 */

/*
 *  CP15によるMMUの操作マクロ（VMSA）
 */

/* 変換テーブルベース制御レジスタ（ARMv6以降）*/
#if __TARGET_ARCH_ARM >= 6
#define CP15_WRITE_TTBCR(reg)	Asm("mcr p15, 0, %0, c2, c0, 2"::"r"(reg))
#endif /* __TARGET_ARCH_ARM >= 6 */

/* 変換テーブルベースレジスタ0 */
#define CP15_READ_TTBR0(reg)	Asm("mrc p15, 0, %0, c2, c0, 0":"=r"(reg))
#define CP15_WRITE_TTBR0(reg)	Asm("mcr p15, 0, %0, c2, c0, 0"::"r"(reg))

/* ドメインアクセス制御レジスタ */
#define CP15_WRITE_DACR(reg)	Asm("mcr p15, 0, %0, c3, c0, 0"::"r"(reg))

/* コンテキストIDレジスタ（ARMv6以降）*/
#if __TARGET_ARCH_ARM >= 6
#define CP15_WRITE_CONTEXTIDR(reg) Asm("mcr p15, 0, %0, c13, c0, 1"::"r"(reg))
#endif /* __TARGET_ARCH_ARM >= 6 */

/*
 *  CP15によるTLB操作マクロ（VMSA）
 */

/* TLB全体の無効化 */
#define CP15_INVALIDATE_TLB()	Asm("mcr p15, 0, %0, c8, c7, 0"::"r"(0))

/*
 *  CP15のパフォーマンスモニタ操作マクロ（ARMv7のみ）
 */
#if __TARGET_ARCH_ARM == 7

/* パフォーマンスモニタ制御レジスタ */
#define CP15_READ_PMCR(reg)		Asm("mrc p15, 0, %0, c9, c12, 0":"=r"(reg))
#define CP15_WRITE_PMCR(reg)	Asm("mcr p15, 0, %0, c9, c12, 0"::"r"(reg))

/* パフォーマンスモニタカウントイネーブルセットレジスタ */
#define CP15_READ_PMCNTENSET(reg)  Asm("mrc p15, 0, %0, c9, c12, 1":"=r"(reg))
#define CP15_WRITE_PMCNTENSET(reg) Asm("mcr p15, 0, %0, c9, c12, 1"::"r"(reg))

/* パフォーマンスモニタサイクルカウントレジスタ */
#define CP15_READ_PMCCNTR(reg)	Asm("mrc p15, 0, %0, c9, c13, 0":"=r"(reg))
#define CP15_WRITE_PMCCNTR(reg)	Asm("mcr p15, 0, %0, c9, c13, 0"::"r"(reg))

#endif /* __TARGET_ARCH_ARM == 7 */

/*
 *  CP15によるメモリバリア操作マクロ
 */
#define CP15_INST_SYNC_BARRIER() \
						Asm("mcr p15, 0, %0, c7, c5, 4"::"r"(0):"memory")
#define CP15_DATA_SYNC_BARRIER() \
						Asm("mcr p15, 0, %0, c7, c10, 4"::"r"(0):"memory")
#define CP15_DATA_MEMORY_BARRIER() \
						Asm("mcr p15, 0, %0, c7, c10, 5"::"r"(0):"memory")

/*
 *  メモリバリア
 *
 *  ARMv6とARMv7が持つ3つのメモリバリア機能を使用するための関数．メモリ
 *  バリアは，ARMv7では専用命令，ARMv6ではCP15への書込みで実現される．
 *  ARMv7のメモリバリア命令は，同期を取る範囲を指定できるが，以下の関数
 *  では最大範囲（システム全体，リード／ライトの両方）で同期を取る．
 *
 *  ARMv5以前では，メモリバリア機能は実装依存であるため，それぞれ，
 *  DATA_MEMORY_BARRIER，DATA_SYNC_BARRIER，INST_SYNC_BARRIERを定義する
 *  ことによって，関数の内容を入れ換えられるようにしている．
 */

/*
 *  データメモリバリア
 *
 *  このバリアの前後で，メモリアクセスの順序が入れ換わらないようにする．
 *  マルチコア（厳密にはマルチマスタ）での使用を想定した命令．
 */
Inline void
data_memory_barrier(void)
{
#ifdef DATA_MEMORY_BARRIER
	DATA_MEMORY_BARRIER();
#elif __TARGET_ARCH_ARM <= 6
	CP15_DATA_MEMORY_BARRIER();
#else /* __TARGET_ARCH_ARM <= 6 */
	Asm("dmb":::"memory");
#endif
}

/*
 *  データ同期バリア
 *
 *  先行するメモリアクセスが完了するのを待つ．メモリアクセスが副作用を
 *  持つ時に，その副作用が起こるのを待つための使用を想定した命令．
 */
Inline void
data_sync_barrier(void)
{
#ifdef DATA_SYNC_BARRIER
	DATA_SYNC_BARRIER();
#elif __TARGET_ARCH_ARM <= 6
	CP15_DATA_SYNC_BARRIER();
#else /* __TARGET_ARCH_ARM <= 6 */
	Asm("dsb":::"memory");
#endif
}

/*
 *  命令同期バリア
 *
 *  プログラムが書き換えられた（または，システム状態の変化により実行す
 *  べきプログラムが変わった）時に，パイプラインをフラッシュするなど，
 *  新しいプログラムを読み込むようにする．ARMv6では，プリフェッチフラッ
 *  シュと呼ばれている．
 */
Inline void
inst_sync_barrier(void)
{
#ifdef INST_SYNC_BARRIER
	INST_SYNC_BARRIER();
#elif __TARGET_ARCH_ARM <= 6
	CP15_INST_SYNC_BARRIER();
#else /* __TARGET_ARCH_ARM <= 6 */
	Asm("isb":::"memory");
#endif
}

/*
 *  CP15のセキュリティ拡張レジスタ操作マクロ（ARMv7のみ）
 */
#if __TARGET_ARCH_ARM == 7

/* ベクタベースアドレスレジスタ */
#define CP15_READ_VBAR(reg)		Asm("mrc p15, 0, %0, c12, c0, 0":"=r"(reg))
#define CP15_WRITE_VBAR(reg)	Asm("mcr p15, 0, %0, c12, c0, 0"::"r"(reg))

#endif /* __TARGET_ARCH_ARM == 7 */

/*
 *  浮動小数点例外制御レジスタ（FPEXC）の現在値の読出し
 */
Inline uint32_t
current_fpexc(void)
{
	uint32_t	fpexc;

	Asm("vmrs %0, fpexc" : "=r"(fpexc));
	return(fpexc);
}

/*
 *  浮動小数点例外制御レジスタ（FPEXC）の現在値の変更
 */
Inline void
set_fpexc(uint32_t fpexc)
{
	Asm("vmsr fpexc, %0" : : "r"(fpexc));
}

#endif /* TOPPERS_ARM_INSN_H */
