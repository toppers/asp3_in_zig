/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 * 
 *  Copyright (C) 2011-2016 by Embedded and Real-Time Systems Laboratory
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
 *  $Id: core_asm.inc 714 2016-03-31 05:52:19Z ertl-hiro $
 */

/*
 *		アセンブリ言語用マクロ定義（ARM GNU開発環境用）
 */

#ifndef TOPPERS_CORE_ASM_INC
#define TOPPERS_CORE_ASM_INC

/*
 *  ディレクティブのマクロ定義
 */
#define ASECTION(name)	.section name, "a"
#define ATEXT			.text
#define AGLOBAL(name)	.global name
#define AALIGN(size)	.align size
#define ALONG			.long
#define ALABEL(label)	label:
#define AOR				|
#define AWEAK(name)		.weak name

/*
 *  セクション情報
 */
#define DATA_START		__start_data
#define DATA_END		__end_data
#define IDATA_START		__start_idata
#define BSS_START		__start_bss
#define BSS_END			__end_bss

/*
 *  データメモリバリア
 */
	.macro	asm_data_memory_barrier reg1
#ifdef ASM_DATA_MEMORY_BARRIER
	ASM_DATA_MEMORY_BARRIER(reg1)
#elif __TARGET_ARCH_ARM <= 6
	mov		\reg1, #0
	mcr		p15, 0, \reg1, c7, c10, 5
#else /* __TARGET_ARCH_ARM <= 6 */
	dmb
#endif
	.endm

/*
 *  データ同期バリア
 */
	.macro	asm_data_sync_barrier reg1
#ifdef ASM_DATA_SYNC_BARRIER
	ASM_DATA_SYNC_BARRIER(reg1)
#elif __TARGET_ARCH_ARM <= 6
	mov		\reg1, #0
	mcr		p15, 0, \reg1, c7, c10, 4
#else /* __TARGET_ARCH_ARM <= 6 */
	dsb
#endif
	.endm

/*
 *  命令同期バリア
 */
	.macro	asm_inst_sync_barrier reg1
#ifdef ASM_INST_SYNC_BARRIER
	ASM_INST_SYNC_BARRIER(reg1)
#elif __TARGET_ARCH_ARM <= 6
	mov		\reg1, #0
	mcr		p15, 0, \reg1, c7, c5, 4
#else /* __TARGET_ARCH_ARM <= 6 */
	isb
#endif
	.endm

#endif /* TOPPERS_CORE_ASM_INC */
