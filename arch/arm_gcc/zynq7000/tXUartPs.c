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
 *  $Id: tXUartPs.c 1336 2019-12-05 16:47:22Z ertl-hiro $
 */

/*
 *		XUartPs用 簡易SIOドライバ
 */

#include <sil.h>
#include "tXUartPs_tecsgen.h"
#include "xuartps.h"

/*
 *  プリミティブな送信／受信関数
 */

/*
 *  受信バッファに文字があるか？
 */
Inline bool_t
xuartps_getready(CELLCB *p_cellcb)
{
	return((sil_rew_mem(XUARTPS_SR(ATTR_baseAddress))
										& XUARTPS_SR_RXEMPTY) == 0U);
}

/*
 *  送信バッファに空きがあるか？
 */
Inline bool_t
xuartps_putready(CELLCB *p_cellcb)
{
	return((sil_rew_mem(XUARTPS_SR(ATTR_baseAddress))
										& XUARTPS_SR_TXFULL) == 0U);
}

/*
 *  受信した文字の取出し
 */
Inline char
xuartps_getchar(CELLCB *p_cellcb)
{
	return((char) sil_rew_mem(XUARTPS_FIFO(ATTR_baseAddress)));
}

/*
 *  送信する文字の書込み
 */
Inline void
xuartps_putchar(CELLCB *p_cellcb, char c)
{
	sil_wrw_mem(XUARTPS_FIFO(ATTR_baseAddress), (uint32_t) c);
}

/*
 *  送信割込みイネーブル
 */
Inline void
xuartps_enable_send(CELLCB *p_cellcb)
{
	sil_wrw_mem(XUARTPS_IER(ATTR_baseAddress), XUARTPS_IXR_TXEMPTY);
}

/*
 *  送信割込みディスエーブル
 */
Inline void
xuartps_disable_send(CELLCB *p_cellcb)
{
	sil_wrw_mem(XUARTPS_IDR(ATTR_baseAddress), XUARTPS_IXR_TXEMPTY);
}

/*
 *  受信割込みイネーブル
 */
Inline void
xuartps_enable_receive(CELLCB *p_cellcb)
{
	sil_wrw_mem(XUARTPS_IER(ATTR_baseAddress), XUARTPS_IXR_RXTRIG);
}

/*
 *  受信割込みディスエーブル
 */
Inline void
xuartps_disable_receive(CELLCB *p_cellcb)
{
	sil_wrw_mem(XUARTPS_IDR(ATTR_baseAddress), XUARTPS_IXR_RXTRIG);
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
		 *  全割込みをディスエーブル
		 */
		sil_wrw_mem(XUARTPS_IDR(ATTR_baseAddress), XUARTPS_IXR_ALL);
		
		/*
		 *  ペンディングしている割込みをクリア
		 */
		sil_wrw_mem(XUARTPS_ISR(ATTR_baseAddress), 
							sil_rew_mem(XUARTPS_ISR(ATTR_baseAddress)));

		/*
		 *  送受信のリセットとディスエーブル
		 */
		sil_wrw_mem(XUARTPS_CR(ATTR_baseAddress),
							XUARTPS_CR_TXRST | XUARTPS_CR_RXRST
								| XUARTPS_CR_TX_DIS | XUARTPS_CR_RX_DIS);

		/*
		 *  ボーレートの設定
		 */
		sil_wrw_mem(XUARTPS_BAUDGEN(ATTR_baseAddress), ATTR_baudgen);
		sil_wrw_mem(XUARTPS_BAUDDIV(ATTR_baseAddress), ATTR_bauddiv);

		/*
		 *  データ長，ストップビット，パリティの設定
		 */
		sil_wrw_mem(XUARTPS_MR(ATTR_baseAddress), ATTR_mode);

		/*
		 *  受信トリガを1バイトに設定
		 */
		sil_wrw_mem(XUARTPS_RXWM(ATTR_baseAddress), 1U);

		/*
		 *  タイムアウトを設定
		 */
		sil_wrw_mem(XUARTPS_RXTOUT(ATTR_baseAddress), 10U);

		/*
		 *  送受信のイネーブル
		 */
		sil_wrw_mem(XUARTPS_CR(ATTR_baseAddress),
					XUARTPS_CR_TX_EN | XUARTPS_CR_RX_EN | XUARTPS_CR_STOPBRK);

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
		 *  送受信のディスエーブル
		 */
		sil_wrw_mem(XUARTPS_CR(ATTR_baseAddress),
				XUARTPS_CR_TX_DIS | XUARTPS_CR_RX_DIS | XUARTPS_CR_STOPBRK);

		/*
		 *  全割込みをディスエーブル
		 */
		sil_wrw_mem(XUARTPS_IDR(ATTR_baseAddress), XUARTPS_IXR_ALL);

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

	if (xuartps_putready(p_cellcb)){
		xuartps_putchar(p_cellcb, c);
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

	if (xuartps_getready(p_cellcb)) {
		return((int_t)(uint8_t) xuartps_getchar(p_cellcb));
	}
	return(-1);
}

/*
 *  シリアルI/Oポートからのコールバックの許可
 */
void
eSIOPort_enableCBR(CELLIDX idx, uint_t cbrtn)
{
	switch (cbrtn) {
	case SIOSendReady:
		xuartps_enable_send(idx);
		break;
	case SIOReceiveReady:
		xuartps_enable_receive(idx);
		break;
	}
}

/*
 *  シリアルI/Oポートからのコールバックの禁止
 */
void
eSIOPort_disableCBR(CELLIDX idx, uint_t cbrtn)
{
	switch (cbrtn) {
	case SIOSendReady:
		xuartps_disable_send(idx);
		break;
	case SIOReceiveReady:
		xuartps_disable_receive(idx);
		break;
	}
}

/*
 *  シリアルI/Oポートに対する割込み処理
 */
void
eiISR_main(CELLIDX idx)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	if (xuartps_getready(idx)) {
		/*
		 *  受信通知コールバックルーチンを呼び出す．
		 */
		ciSIOCBR_readyReceive();
	}
	if (xuartps_putready(idx)) {
		/*
		 *  送信可能コールバックルーチンを呼び出す．
		 */
		ciSIOCBR_readySend();
	}

	/*
	 *  ペンディングしている割込みをクリア
	 */
	sil_wrw_mem(XUARTPS_ISR(ATTR_baseAddress), 
						sil_rew_mem(XUARTPS_ISR(ATTR_baseAddress)));
}

/*
 *  SIOドライバの終了処理
 */
void
eTerminate_main(CELLIDX idx)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	if (VAR_opened) {
		/*
		 *  送信FIFOが空になるまで待つ
		 */
		while ((sil_rew_mem(XUARTPS_SR(ATTR_baseAddress))
										& XUARTPS_SR_TXEMPTY) == 0U) {
			sil_dly_nse(100);
		}

		/*
		 *  ポートのクローズ
		 */
		eSIOPort_close(idx);
	}
}
