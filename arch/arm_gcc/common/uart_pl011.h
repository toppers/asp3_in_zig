/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 * 
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2006-2016 by Embedded and Real-Time Systems Laboratory
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
 *  $Id: uart_pl011.h 906 2018-03-04 13:16:53Z ertl-hiro $
 */

/*
 *		ARM PrimCell UART（PL011）に関する定義
 */

#ifndef TOPPERS_UART_PL011_H
#define TOPPERS_UART_PL011_H

/*
 *  UARTレジスタの番地の定義
 */
#define UART_DR(base)		((uint32_t *)((base) + 0x00U))
#define UART_RSR(base)		((uint32_t *)((base) + 0x04U))
#define UART_ECR(base)		((uint32_t *)((base) + 0x04U))
#define UART_FR(base)		((uint32_t *)((base) + 0x18U))
#define UART_IBRD(base)		((uint32_t *)((base) + 0x24U))
#define UART_FBRD(base)		((uint32_t *)((base) + 0x28U))
#define UART_LCR_H(base)	((uint32_t *)((base) + 0x2cU))
#define UART_CR(base)		((uint32_t *)((base) + 0x30U))
#define UART_IFLS(base)		((uint32_t *)((base) + 0x34U))
#define UART_IMSC(base)		((uint32_t *)((base) + 0x38U))
#define UART_RIS(base)		((uint32_t *)((base) + 0x3cU))
#define UART_MIS(base)		((uint32_t *)((base) + 0x40U))
#define UART_ICR(base)		((uint32_t *)((base) + 0x44U))

/*
 *  フラグレジスタ（UART_FR）の参照値
 */
#define UART_FR_RXFE		UINT_C(0x10)	/* 受信バッファが空 */
#define UART_FR_TXFF		UINT_C(0x20)	/* 送信バッファがフル */

/*
 *  ライン制御レジスタ（UART_LCR_H）の設定値
 */
#define UART_LCR_H_PEN		UINT_C(0x02)	/* パリティを用いる */
#define UART_LCR_H_EPS		UINT_C(0x04)	/* 偶数パリティに */
#define UART_LCR_H_STP2		UINT_C(0x08)	/* ストップビットを2ビットに */
#define UART_LCR_H_FEN		UINT_C(0x10)	/* FIFOを有効に */
#define UART_LCR_H_WLEN8	UINT_C(0x60)	/* データ長を8ビットに */

/*
 *  制御レジスタ（UART_CR）の設定値
 */
#define UART_CR_UARTEN	UINT_C(0x0001)		/* UARTをイネーブルに */
#define UART_CR_TXE		UINT_C(0x0100)		/* 送信をイネーブルに */
#define UART_CR_RXE		UINT_C(0x0200)		/* 受信をイネーブルに */

/*
 *  割込みマスクセット／クリアレジスタ（UART_IMSC）の設定値
 */
#define UART_IMSC_RXIM	UINT_C(0x0010)		/* 受信割込みマスク */
#define UART_IMSC_TXIM	UINT_C(0x0020)		/* 送信割込みマスク */

#endif /* TOPPERS_UART_PL011_H */
