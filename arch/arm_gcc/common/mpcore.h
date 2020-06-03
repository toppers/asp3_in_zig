/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 * 
 *  Copyright (C) 2006-2019 by Embedded and Real-Time Systems Laboratory
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
 *  $Id: mpcore.h 1292 2019-10-08 09:08:47Z ertl-hiro $
 */

/*
 *		MPCoreサポートモジュール
 */

#ifndef TOPPERS_MPCORE_H
#define TOPPERS_MPCORE_H

#include <sil.h>
#include "arm.h"

/*
 *  CP15の補助制御レジスタ（ACTLR）の設定値
 */
#if __TARGET_ARCH_ARM == 6
#define CP15_ACTLR_SMP			UINT_C(0x00000020)
#else /* __TARGET_ARCH_ARM == 6 */
#define CP15_ACTLR_SMP			UINT_C(0x00000040)
#define CP15_ACTLR_FW			UINT_C(0x00000001)
#endif /* __TARGET_ARCH_ARM == 6 */

/*
 *  SCU（スヌープ制御ユニット）関連の定義
 */

/*
 *  SCUレジスタの番地の定義
 */
#define MPCORE_SCU_BASE		(MPCORE_PMR_BASE + 0x0000U)
#define MPCORE_SCU_CTRL		((uint32_t *)(MPCORE_SCU_BASE + 0x00U))
#define MPCORE_SCU_CONFIG	((uint32_t *)(MPCORE_SCU_BASE + 0x04U))
#define MPCORE_SCU_CPUSTAT	((uint32_t *)(MPCORE_SCU_BASE + 0x08U))
#define MPCORE_SCU_INVALL	((uint32_t *)(MPCORE_SCU_BASE + 0x0cU))

/*
 *  SCU制御レジスタ（MPCORE_SCU_CTRL）の設定値
 */
#define MPCORE_SCU_CTRL_ENABLE		UINT_C(0x00000001)

/*
 *  SCUパワーステータスレジスタ（MPCORE_SCU_CPUSTAT）の設定値
 */
#define MPCORE_SCU_CPUSTAT_ALLNORMAL	UINT_C(0x00000000)

/*
 *  SCUインバリデートオールレジスタ（MPCORE_SCU_INVALL）の設定値
 */
#define MPCORE_SCU_INVALL_ALLWAYS	UINT_C(0x0000ffff)

/*
 *  GIC関連の定義
 */

/*
 *  GICレジスタのベースアドレスの定義
 */
#ifndef GICC_BASE
#define GICC_BASE			(MPCORE_PMR_BASE + UINT_C(0x0100))
#endif /* GICC_BASE */

#ifndef GICD_BASE
#define GICD_BASE			(MPCORE_PMR_BASE + UINT_C(0x1000))
#endif /* GICD_BASE */

/*
 *  割込み番号の定義
 */
#define MPCORE_IRQNO_GTC	27U			/* グローバルタイマの割込み番号 */
#define MPCORE_IRQNO_TMR	29U			/* プライベートタイマの割込み番号 */
#define MPCORE_IRQNO_WDG	30U			/* ウォッチドッグの割込み番号 */

/*
 *  プライベートタイマとウォッチドッグ関連の定義
 */

/*
 *  プライベートタイマとウォッチドッグレジスタの番地の定義
 */
#define MPCORE_TMR_BASE		(MPCORE_PMR_BASE + 0x0600U)
#define MPCORE_TMR_LR		((uint32_t *)(MPCORE_TMR_BASE + 0x00U))
#define MPCORE_TMR_CNT		((uint32_t *)(MPCORE_TMR_BASE + 0x04U))
#define MPCORE_TMR_CTRL		((uint32_t *)(MPCORE_TMR_BASE + 0x08U))
#define MPCORE_TMR_ISR		((uint32_t *)(MPCORE_TMR_BASE + 0x0cU))
#define MPCORE_WDG_LR		((uint32_t *)(MPCORE_TMR_BASE + 0x20U))
#define MPCORE_WDG_CNT		((uint32_t *)(MPCORE_TMR_BASE + 0x24U))
#define MPCORE_WDG_CTRL		((uint32_t *)(MPCORE_TMR_BASE + 0x28U))
#define MPCORE_WDG_ISR		((uint32_t *)(MPCORE_TMR_BASE + 0x2cU))
#define MPCORE_WDG_RST		((uint32_t *)(MPCORE_TMR_BASE + 0x30U))
#define MPCORE_WDG_DIS		((uint32_t *)(MPCORE_TMR_BASE + 0x34U))

/*
 *  プライベートタイマ制御レジスタ（MPCORE_TMR_CTRL）の設定値
 */
#define MPCORE_TMR_CTRL_DISABLE			0x00U
#define MPCORE_TMR_CTRL_ENABLE			0x01U
#define MPCORE_TMR_CTRL_AUTORELOAD		0x02U
#define MPCORE_TMR_CTRL_ENAINT			0x04U
#define MPCORE_TMR_CTRL_PS_SHIFT		8

/*
 *  プライベートタイマ割込みステータスレジスタ（MPCORE_TMR_ISR）の設定値
 */
#define MPCORE_TMR_ISR_EVENTFLAG		0x01U

/*
 *  ウォッチドッグ制御レジスタ（MPCORE_WDG_CTRL）の参照値
 */
#define MPCORE_WDG_CTRL_DISABLE			0x00U
#define MPCORE_WDG_CTRL_ENABLE			0x01U
#define MPCORE_WDG_CTRL_AUTORELOAD		0x02U
#define MPCORE_WDG_CTRL_ENAINT			0x04U
#define MPCORE_WDG_CTRL_WDGMODE			0x08U
#define MPCORE_WDG_CTRL_PS_SHIFT		8

/*
 *  ウォッチドッグ割込みステータスレジスタ（MPCORE_WDG_ISR）の参照値
 */
#define MPCORE_WDG_ISR_EVENTFLAG		0x01U

/*
 *  グローバルタイマ関連の定義
 */
#if __TARGET_ARCH_ARM == 7 /* 正確にはr1から */

/*
 *  グローバルタイマレジスタの番地の定義
 */
#define MPCORE_GTC_BASE		(MPCORE_PMR_BASE + 0x0200U)
#define MPCORE_GTC_COUNT_L	((uint32_t *)(MPCORE_GTC_BASE + 0x00U))
#define MPCORE_GTC_COUNT_U	((uint32_t *)(MPCORE_GTC_BASE + 0x04U))
#define MPCORE_GTC_CTRL		((uint32_t *)(MPCORE_GTC_BASE + 0x08U))
#define MPCORE_GTC_ISR		((uint32_t *)(MPCORE_GTC_BASE + 0x0cU))
#define MPCORE_GTC_CVR_L	((uint32_t *)(MPCORE_GTC_BASE + 0x10U))
#define MPCORE_GTC_CVR_U	((uint32_t *)(MPCORE_GTC_BASE + 0x14U))
#define MPCORE_GTC_AUTOINCR	((uint32_t *)(MPCORE_GTC_BASE + 0x18U))

/*
 *  グローバルタイマ制御レジスタ（MPCORE_GTC_CTRL）の設定値
 */
#define MPCORE_GTC_CTRL_DISABLE			0x00U
#define MPCORE_GTC_CTRL_ENABLE			0x01U
#define MPCORE_GTC_CTRL_ENACOMP			0x02U
#define MPCORE_GTC_CTRL_ENAINT			0x04U
#define MPCORE_GTC_CTRL_AUTOINCR		0x08U
#define MPCORE_GTC_CTRL_PS_SHIFT		8

/*
 *  グローバルタイマ割込みステータスレジスタ（MPCORE_GTC_ISR）の設定値
 */
#define MPCORE_GTC_ISR_EVENTFLAG		0x01U

#endif /* __TARGET_ARCH_ARM == 7 */

#endif /* TOPPERS_MPCORE_H */
