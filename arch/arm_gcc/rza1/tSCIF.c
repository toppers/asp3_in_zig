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
 *  $Id: tSCIF.c 1336 2019-12-05 16:47:22Z ertl-hiro $
 */

/*
 *		FIFO内蔵シリアルコミュニケーションインタフェース用 簡易SIOドライバ
 */

#include <sil.h>
#include "tSCIF_tecsgen.h"
#include "scif.h"

/*
 *  プリミティブな送信／受信関数
 */

/*
 *  受信バッファに文字があるか？
 */
Inline bool_t
scif_getready(CELLCB *p_cellcb)
{
	uint16_t	fsr;
	uint16_t	lsr;

	fsr = sil_reh_mem(SCIF_SCFSR(ATTR_baseAddress));
	lsr = sil_reh_mem(SCIF_SCLSR(ATTR_baseAddress));
	if ((fsr & (SCIF_SCFSR_ER|SCIF_SCFSR_BRK)) != 0U) {
		fsr &= ~(SCIF_SCFSR_ER|SCIF_SCFSR_BRK);
		sil_wrh_mem(SCIF_SCFSR(ATTR_baseAddress), fsr);
	}
	if ((lsr & SCIF_SCLSR_ORER) != 0U) {
		lsr &= ~(SCIF_SCLSR_ORER);
		sil_wrh_mem(SCIF_SCLSR(ATTR_baseAddress), lsr);
	}
	return((fsr & SCIF_SCFSR_RDF) != 0U);
}

/*
 *  送信バッファに空きがあるか？
 */
Inline bool_t
scif_putready(CELLCB *p_cellcb)
{
	uint16_t	fsr;

	fsr = sil_reh_mem(SCIF_SCFSR(ATTR_baseAddress));
	return((fsr & SCIF_SCFSR_TDFE) != 0U);
}

/*
 *  受信した文字の取出し
 */
Inline bool_t
scif_getchar(CELLCB *p_cellcb, char *p_c)
{
	uint16_t	fsr;
	uint16_t	lsr;

	fsr = sil_reh_mem(SCIF_SCFSR(ATTR_baseAddress));
	lsr = sil_reh_mem(SCIF_SCLSR(ATTR_baseAddress));
	if ((fsr & (SCIF_SCFSR_ER|SCIF_SCFSR_BRK)) != 0U) {
		fsr &= ~(SCIF_SCFSR_ER|SCIF_SCFSR_BRK);
		sil_wrh_mem(SCIF_SCFSR(ATTR_baseAddress), fsr);
	}
	if ((lsr & SCIF_SCLSR_ORER) != 0U) {
		lsr &= ~(SCIF_SCLSR_ORER);
		sil_wrh_mem(SCIF_SCLSR(ATTR_baseAddress), lsr);
	}
	if ((fsr & SCIF_SCFSR_RDF) != 0U) {
		*p_c = (char) sil_reb_mem(SCIF_SCFRDR(ATTR_baseAddress));
		fsr &= ~(SCIF_SCFSR_RDF);
		sil_wrh_mem(SCIF_SCFSR(ATTR_baseAddress), fsr);
		return(true);
	}
	return(false);
}

/*
 *  送信する文字の書込み
 */
Inline void
scif_putchar(CELLCB *p_cellcb, char c)
{
	sil_wrb_mem(SCIF_SCFTDR(ATTR_baseAddress), c);
	sil_wrh_mem(SCIF_SCFSR(ATTR_baseAddress),
				(uint16_t) ~(SCIF_SCFSR_TEND|SCIF_SCFSR_TDFE));
}

/*
 *  シリアルI/Oポートのオープン
 */
void
eSIOPort_open(CELLIDX idx)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);
	uint_t	brr;

	if (!VAR_opened) {
		/*
		 *  既にオープンしている場合は、二重にオープンしない．
		 */
		brr = SCIF_CLK / (32 * ATTR_baudRate) - 1;
		assert(brr <= 255);

		sil_wrh_mem(SCIF_SCSCR(ATTR_baseAddress), 0U);
		sil_wrh_mem(SCIF_SCFCR(ATTR_baseAddress),
							SCIF_SCFCR_TFRST|SCIF_SCFCR_RFRST);
		(void) sil_reh_mem(SCIF_SCFSR(ATTR_baseAddress));
		(void) sil_reh_mem(SCIF_SCLSR(ATTR_baseAddress));
		sil_wrh_mem(SCIF_SCFSR(ATTR_baseAddress), 0U);
		sil_wrh_mem(SCIF_SCLSR(ATTR_baseAddress), 0U);
		sil_wrh_mem(SCIF_SCSCR(ATTR_baseAddress), SCIF_SCSCR_INTCLK);
		sil_wrh_mem(SCIF_SCSMR(ATTR_baseAddress),
							SCIF_SCSMR_ASYNC|ATTR_mode|SCIF_SCSMR_CKS1);
		sil_wrh_mem(SCIF_SCEMR(ATTR_baseAddress), 0U);
		sil_wrb_mem(SCIF_SCBRR(ATTR_baseAddress), (uint8_t) brr);
		sil_wrh_mem(SCIF_SCFCR(ATTR_baseAddress),
					SCIF_SCFCR_RSTRG_15|SCIF_SCFCR_RTRG_1|SCIF_SCFCR_TTRG_8);
		sil_wrh_mem(SCIF_SCSCR(ATTR_baseAddress),
					SCIF_SCSCR_TE|SCIF_SCSCR_RE|SCIF_SCSCR_INTCLK);

		while ((sil_reh_mem(SCIF_SCFSR(ATTR_baseAddress)) & SCIF_SCFSR_RDF)
																	!= 0U) {
			(void) sil_reb_mem(SCIF_SCFRDR(ATTR_baseAddress));
			sil_wrh_mem(SCIF_SCFSR(ATTR_baseAddress),
							(uint16_t) ~(SCIF_SCFSR_RDF));
		}
		sil_wrh_mem(SCIF_SCFSR(ATTR_baseAddress), 0U);

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
		sil_wrh_mem(SCIF_SCSCR(ATTR_baseAddress), 0U);

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

	if (scif_putready(p_cellcb)){
		scif_putchar(p_cellcb, c);
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
	char	c;

	if (scif_getready(p_cellcb)) {
		if (scif_getchar(p_cellcb, &c)) {
			return((int_t) c);
		}
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
	uint16_t	scr;

	scr = sil_reh_mem(SCIF_SCSCR(ATTR_baseAddress));
	switch (cbrtn) {
	case SIOSendReady:
		scr |= SCIF_SCSCR_TIE;
		break;
	case SIOReceiveReady:
		scr |= SCIF_SCSCR_RIE;
		break;
	}
	sil_wrh_mem(SCIF_SCSCR(ATTR_baseAddress), scr);
}

/*
 *  シリアルI/Oポートからのコールバックの禁止
 */
void
eSIOPort_disableCBR(CELLIDX idx, uint_t cbrtn)
{
	CELLCB		*p_cellcb = GET_CELLCB(idx);
	uint16_t	scr;

	scr = sil_reh_mem(SCIF_SCSCR(ATTR_baseAddress));
	switch (cbrtn) {
	case SIOSendReady:
		scr &= ~(SCIF_SCSCR_TIE);
		break;
	case SIOReceiveReady:
		scr &= ~(SCIF_SCSCR_RIE);
		break;
	}
	sil_wrh_mem(SCIF_SCSCR(ATTR_baseAddress), scr);
}

/*
 *  シリアルI/Oポートに対する受信割込み処理
 */
void
eiRxISR_main(CELLIDX idx)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	if (scif_getready(p_cellcb)) {
		/*
		 *  受信通知コールバックルーチンを呼び出す．
		 */
		ciSIOCBR_readyReceive();
	}
}

/*
 *  シリアルI/Oポートに対する送信割込み処理
 */
void
eiTxISR_main(CELLIDX idx)
{
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	if (scif_putready(p_cellcb)) {
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
	CELLCB	*p_cellcb = GET_CELLCB(idx);

	if (VAR_opened) {
		/*
		 *  送信FIFOが空になるまで待つ
		 */
		while ((sil_reh_mem(SCIF_SCFSR(ATTR_baseAddress))
											& SCIF_SCFSR_TEND) == 0U) {
			sil_dly_nse(100);
		}

		/*
		 *  ポートのクローズ
		 */
		eSIOPort_close(idx);
	}
}
