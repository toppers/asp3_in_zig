/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 * 
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2004-2018 by Embedded and Real-Time Systems Laboratory
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
 *  $Id: core_sil.h 1075 2018-11-25 13:51:40Z ertl-hiro $
 */

/*
 *		sil.hのコア依存部（ARM用）
 *
 *  このヘッダファイルは，target_sil.h（または，そこからインクルードさ
 *  れるファイル）のみからインクルードされる．他のファイルから直接イン
 *  クルードしてはならない．
 */

#ifndef TOPPERS_CORE_SIL_H
#define TOPPERS_CORE_SIL_H

#include <t_stddef.h>

#ifndef TOPPERS_MACRO_ONLY
#ifndef __thumb__

/*
 *  ステータスレジスタ（CPSR）の現在値の読出し
 */
Inline uint32_t
TOPPERS_current_cpsr(void)
{
	uint32_t	cpsr;

	Asm("mrs %0, cpsr" : "=r"(cpsr));
	return(cpsr);
}

/*
 *  ステータスレジスタ（CPSR）の現在値の変更
 */
Inline void
TOPPERS_set_cpsr(uint32_t cpsr)
{
	Asm("msr cpsr_cxsf, %0" : : "r"(cpsr) : "memory","cc");
}

#else /* __thumb__ */
/*
 *  Thumbモードではmrs/msr命令が使用できないため，関数として実現して，
 *  ARMモードに移行して実行する．
 */

/*
 *  ステータスレジスタ（CPSR）の現在値の読出し
 */
extern uint32_t _kernel_current_cpsr(void);
#define TOPPERS_current_cpsr()	_kernel_current_cpsr()

/*
 *  ステータスレジスタ（CPSR）の現在値の変更
 */
extern void _kernel_set_cpsr(uint32_t cpsr);
#define TOPPERS_set_cpsr(cpsr)	_kernel_set_cpsr(cpsr)

#endif /* __thumb__ */

/*
 *  すべての割込み（FIQとIRQ）の禁止
 */
Inline uint32_t
TOPPERS_disint(void)
{
	uint32_t	cpsr;
	uint32_t	fiq_irq_mask;

	cpsr = TOPPERS_current_cpsr();
	fiq_irq_mask = cpsr & (0x40U|0x80U);
#if __TARGET_ARCH_ARM == 6 || __TARGET_ARCH_ARM == 7
	Asm("cpsid fi" ::: "memory");
#else /* __TARGET_ARCH_ARM == 6 || __TARGET_ARCH_ARM == 7 */
	cpsr |= (0x40U|0x80U);
	TOPPERS_set_cpsr(cpsr);
#endif /* __TARGET_ARCH_ARM == 6 || __TARGET_ARCH_ARM == 7 */
	return(fiq_irq_mask);
}

/*
 *  FIQとIRQの禁止ビットの復帰
 */
Inline void
TOPPERS_set_fiq_irq(uint32_t fiq_irq_mask)
{
	uint32_t	cpsr;

	cpsr = TOPPERS_current_cpsr();
	cpsr &= ~(0x40U|0x80U);
	cpsr |= fiq_irq_mask;
	TOPPERS_set_cpsr(cpsr);
}

/*
 *  全割込みロック状態の制御
 */
#define SIL_PRE_LOC		uint32_t TOPPERS_fiq_irq_mask
#define SIL_LOC_INT()	((void)(TOPPERS_fiq_irq_mask = TOPPERS_disint()))
#define SIL_UNL_INT()	(TOPPERS_set_fiq_irq(TOPPERS_fiq_irq_mask))

/*
 *  メモリ同期バリア
 */
#ifdef DATA_SYNC_BARRIER
#define TOPPERS_SIL_WRITE_SYNC()	DATA_SYNC_BARRIER()
#elif __TARGET_ARCH_ARM <= 6
#define TOPPERS_SIL_WRITE_SYNC() \
						Asm("mcr p15, 0, %0, c7, c10, 4"::"r"(0):"memory")
#else /* __TARGET_ARCH_ARM <= 6 */
#define TOPPERS_SIL_WRITE_SYNC()	Asm("dsb":::"memory")
#endif

#endif /* TOPPERS_MACRO_ONLY */
#endif /* TOPPERS_CORE_SIL_H */
