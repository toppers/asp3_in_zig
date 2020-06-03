/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 * 
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
 *  $Id: tUartPL011.c 1095 2018-11-28 00:57:28Z ertl-hiro $
 */

/*
 *		ARM PrimCell UART（PL011）用 簡易SIOドライバ
 */

#include <sil.h>
#include "tUartPL011_tecsgen.h"
#include "uart_pl011.h"

/*
 *  プリミティブな送信／受信関数
 */

/*
 *  受信バッファに文字があるか？
 */
Inline bool_t
uart_pl011_getready(CELLCB *p_cellcb)
{
	return((sil_rew_mem(UART_FR(ATTR_baseAddress)) & UART_FR_RXFE) == 0U);
}

/*
 *  送信バッファに空きがあるか？
 */
Inline bool_t
uart_pl011_putready(CELLCB *p_cellcb)
{
	return((sil_rew_mem(UART_FR(ATTR_baseAddress)) & UART_FR_TXFF) == 0U);
}

/*
 *  受信した文字の取出し
 */
Inline char
uart_pl011_getchar(CELLCB *p_cellcb)
{
	return((char) sil_rew_mem(UART_DR(ATTR_baseAddress)));
}

/*
 *  送信する文字の書込み
 */
Inline void
uart_pl011_putchar(CELLCB *p_cellcb, char c)
{
	sil_wrw_mem(UART_DR(ATTR_baseAddress), (uint32_t) c);
}

/*
 *  シリアルI/Oポートのオープン
 */
void
eSIOPort_open(CELLIDX idx)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	if (!VAR_opened) {
		/*
		 *  既にオープンしている場合は、二重にオープンしない．
		 */

		/*
		 *  UARTをディスエーブル
		 */
		sil_wrw_mem(UART_CR(ATTR_baseAddress), 0U);

		/*
		 *  エラーフラグをクリア
		 */
		sil_wrw_mem(UART_ECR(ATTR_baseAddress), 0U);

		/*
		 *  FIFOを空にする
		 */
		while (uart_pl011_getready(p_cellcb)) {
			(void) uart_pl011_getchar(p_cellcb);
		}

		/*
		 *  ボーレートと通信規格を設定
		 */
		sil_wrw_mem(UART_IBRD(ATTR_baseAddress), ATTR_ibrd);
		sil_wrw_mem(UART_FBRD(ATTR_baseAddress), ATTR_fbrd);
		sil_wrw_mem(UART_LCR_H(ATTR_baseAddress), ATTR_lcr_h);
		
		/*
		 *  UARTをイネーブル
		 */
		sil_wrw_mem(UART_CR(ATTR_baseAddress),
						UART_CR_UARTEN|UART_CR_TXE|UART_CR_RXE);

		VAR_opened = true;
	}
}

/*
 *  シリアルI/Oポートのクローズ
 */
void
eSIOPort_close(CELLIDX idx)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	if (VAR_opened) {
		/*
		 *  UARTをディスエーブル
		 */
		sil_wrw_mem(UART_CR(ATTR_baseAddress), 0U);

		VAR_opened = false;
	}
}

/*
 *  シリアルI/Oポートへの文字送信
 */
bool_t
eSIOPort_putChar(CELLIDX idx, char c)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	if (uart_pl011_putready(p_cellcb)){
		uart_pl011_putchar(p_cellcb, c);
		return(true);
	}
	return(false);
}

/*
 *  シリアルI/Oポートからの文字受信
 */
int_t
eSIOPort_getChar(CELLIDX idx)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	if (uart_pl011_getready(p_cellcb)) {
		return((int_t)(uint8_t) uart_pl011_getchar(p_cellcb));
	}
	return(-1);
}

/*
 *  シリアルI/Oポートからのコールバックの許可
 */
void
eSIOPort_enableCBR(CELLIDX idx, uint_t cbrtn)
{
	CELLCB		*p_cellcb = GET_CELLCB(idx);
	uint32_t	reg;

	reg = sil_rew_mem(UART_IMSC(ATTR_baseAddress));
	switch (cbrtn) {
	case SIOSendReady:
		reg |= UART_IMSC_TXIM;
		break;
	case SIOReceiveReady:
		reg |= UART_IMSC_RXIM;
		break;
	}
	sil_wrw_mem(UART_IMSC(ATTR_baseAddress), reg);
}

/*
 *  シリアルI/Oポートからのコールバックの禁止
 */
void
eSIOPort_disableCBR(CELLIDX idx, uint_t cbrtn)
{
	CELLCB		*p_cellcb = GET_CELLCB(idx);
	uint32_t	reg;

	reg = sil_rew_mem(UART_IMSC(ATTR_baseAddress));
	switch (cbrtn) {
	case SIOSendReady:
		reg &= ~UART_IMSC_TXIM;
		break;
	case SIOReceiveReady:
		reg &= ~UART_IMSC_RXIM;
		break;
	}
	sil_wrw_mem(UART_IMSC(ATTR_baseAddress), reg);
}

/*
 *  シリアルI/Oポートに対する割込み処理
 */
void
eiISR_main(CELLIDX idx)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	if (uart_pl011_getready(p_cellcb)) {
		/*
		 *  受信通知コールバックルーチンを呼び出す．
		 */
		ciSIOCBR_readyReceive();
	}
	if (uart_pl011_putready(p_cellcb)) {
		/*
		 *  送信可能コールバックルーチンを呼び出す．
		 */
		ciSIOCBR_readySend();
	}
}

/*
 *  SIOドライバの終了処理
 */
void
eTerminate_main(CELLIDX idx)
{
	eSIOPort_close(idx);
}
