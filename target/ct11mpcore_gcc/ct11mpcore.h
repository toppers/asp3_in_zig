/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 * 
 *  Copyright (C) 2006-2017 by Embedded and Real-Time Systems Laboratory
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
 *  $Id: ct11mpcore.h 795 2017-07-03 17:08:39Z ertl-hiro $
 */

/*
 *		CT11MPcore with RealView Emulation Baseboard サポートモジュール
 */

#ifndef TOPPERS_CT11MPCORE_H
#define TOPPERS_CT11MPCORE_H

/*
 *  割込みの数
 */
#define DIC_TNUM_INTNO		UINT_C(48)

/*
 *  割込み番号
 */
#define EB_IRQNO_TIMER01	33U
#define EB_IRQNO_TIMER23	34U
#define EB_IRQNO_UART0   	36U
#define EB_IRQNO_UART1   	37U
#define EB_IRQNO_UART2   	44U		/* 要検討 */
#define EB_IRQNO_UART3   	45U		/* 要検討 */

/*
 *  MPCore Private Memory Regionの先頭番地
 *
 *  ARM11 MPCoreの制御レジスタには，MPCore Private Memory Regionと呼ば
 *  れるメモリ領域によりアクセスする．この領域の先頭番地は，コア外部か
 *  ら設定可能となっている．CT11MPCoreでは，ボードで設定できるようになっ
 *  ており，デフォルトでは，0x1f000000になっている．
 *
 *  QEMUでは，この領域の先頭番地は，0x10100000に設定されている
 *  （qemu-2.1.0/hw/arm/realview.c）．
 */
#ifdef TOPPERS_USE_QEMU
#define MPCORE_PMR_BASE		0x10100000
#endif /* TOPPERS_USE_QEMU */

#ifndef MPCORE_PMR_BASE
#define MPCORE_PMR_BASE		0x1f000000
#endif /* MPCORE_PMR_BASE */

/*
 *  MPCore内蔵のタイマとウォッチドッグを1MHzで動作させるためのプリスケー
 *  ラの設定値（コアのクロックが200MHzの場合）
 */
#define MPCORE_TMR_PS_VALUE		99
#define MPCORE_WDG_PS_VALUE		99

/*
 *  Emulation Board上のリソース
 */
#define EB_SYS_BASE			0x10000000
#define EB_SYS_LOCK			((uint32_t *)(EB_SYS_BASE + 0x0020U))
#define EB_SYS_PLD_CTRL1	((uint32_t *)(EB_SYS_BASE + 0x0074U))
#define EB_SYS_PLD_CTRL2	((uint32_t *)(EB_SYS_BASE + 0x0078U))

/*
 *  ロックレジスタ（EB_SYS_LOCK）の設定値
 */
#define EB_SYS_LOCK_LOCK	UINT_C(0x0000)
#define EB_SYS_LOCK_UNLOCK	UINT_C(0xa05f)

/*
 *  システム制御レジスタ1（EB_SYS_PLD_CTRL1）の設定値
 */
#define EB_SYS_PLD_CTRL1_INTMODE_LEGACY		UINT_C(0x00000000)
#define EB_SYS_PLD_CTRL1_INTMODE_NEW_DCC	UINT_C(0x00400000)
#define EB_SYS_PLD_CTRL1_INTMODE_NEW_NODCC	UINT_C(0x00800000)
#define EB_SYS_PLD_CTRL1_INTMODE_EN_FIQ		UINT_C(0x01000000)
#define EB_SYS_PLD_CTRL1_INTMODE_MASK		UINT_C(0x01c00000)

/*
 *  UART関連の定義
 */

/* 
 *  UARTレジスタのベースアドレス
 */
#define EB_UART0_BASE		(EB_SYS_BASE + 0x9000U)
#define EB_UART1_BASE		(EB_SYS_BASE + 0xa000U)
#define EB_UART2_BASE		(EB_SYS_BASE + 0xb000U)
#define EB_UART3_BASE		(EB_SYS_BASE + 0xc000U)

/*
 *  ボーレート設定（38400bps）
 */ 
#define EB_UART_IBRD_38400	0x27U
#define EB_UART_FBRD_38400	0x04U

/*
 *  タイマ関連の定義
 */

/* 
 *  タイマレジスタのベースアドレス
 */
#define EB_TIMER0_BASE		(EB_SYS_BASE + 0x11000U)
#define EB_TIMER1_BASE		(EB_SYS_BASE + 0x11020U)
#define EB_TIMER2_BASE		(EB_SYS_BASE + 0x12000U)
#define EB_TIMER3_BASE		(EB_SYS_BASE + 0x12020U)

#endif /* TOPPERS_CT11MPCORE_H */
