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
 *  $Id: rza1.h 1075 2018-11-25 13:51:40Z ertl-hiro $
 */

/*
 *		RZ/A1のハードウェア資源の定義
 */

#ifndef TOPPERS_RZA1_H
#define TOPPERS_RZA1_H

#include <kernel.h>
#include <sil.h>
#include "arm.h"

/*
 *  型キャストを行うマクロの定義
 */
#ifndef CAST
#define CAST(type, val)		((type)(val))
#endif /* CAST */

/*
 *  メモリマップの定義（MMUに設定するために必要）
 */
#define SPI_ADDR		0x18000000		/* シリアルフラッシュメモリ */
#define SPI_SIZE		0x08000000		/* 128MB */

#define SRAM_ADDR		0x20000000		/* 内蔵RAM */
#ifdef TOPPERS_RZA1H
#define SRAM_SIZE		0x00a00000		/* 10MB */
#else /* TOPPERS_RZA1H */
#define SRAM_SIZE		0x00300000		/* 3MB */
#endif /* TOPPERS_RZA1H */

#define IO1_ADDR		0x3fe00000		/* I/O領域（予約領域を含む）*/
#define IO1_SIZE		0x00200000		/* 2MB */
#define IO2_ADDR		0xe8000000		/* I/O領域（予約領域を含む）*/
#define IO2_SIZE		0x18000000		/* 384MB */

/*
 *  各クロック周波数の定義
 */
#define OSTM_CLK		RZA1_CLK_P0
#define SCIF_CLK		RZA1_CLK_P1

/*
 *  MPCore Private Memory Regionの先頭番地
 */
#define MPCORE_PMR_BASE		0xf0000000

/*
 *  CP15の補助制御レジスタ（ACTLR）の設定値
 */
#define CP15_ACTLR_SMP		UINT_C(0x00000040)

/*
 *  GIC依存部を使用するための定義
 */
#ifndef GIC_TNUM_INTNO
#ifdef TOPPERS_RZA1H
#define GIC_TNUM_INTNO		UINT_C(587)
#else /* TOPPERS_RZA1H */
#define GIC_TNUM_INTNO		UINT_C(538)
#endif /* TOPPERS_RZA1H */
#endif /* GIC_TNUM_INTNO */

/*
 *  割込みコントローラのベースアドレスとレジスタ（RZ/A1固有のもの）
 */
#define GICC_BASE			0xe8202000
#define GICD_BASE			0xe8201000

#define RZA1_ICR0			CAST(uint16_t *, 0xfcfef800)
#define RZA1_ICR1			CAST(uint16_t *, 0xfcfef802)
#define RZA1_IRQRR			CAST(uint16_t *, 0xfcfef804)

/*
 *  OSタイマのベースアドレス
 */
#define OSTM0_BASE			0xfcfec000
#define OSTM1_BASE			0xfcfec400

/*
 *  L2キャッシュコントローラ（PL310）のベースアドレス
 */
#define PL310_BASE			0x3ffff000

/*
 *  クロックパルスジェネレータのベースアドレスとレジスタ
 */
#define RZA1_CPG_BASE		0xfcfe0000
#define RZA1_FRQCR			CAST(uint16_t *, RZA1_CPG_BASE + 0x010)
#define RZA1_FRQCR2			CAST(uint16_t *, RZA1_CPG_BASE + 0x014)

/*
 *  バスステートコントローラのベースアドレスとレジスタ
 */
#define RZA1_BSC_BASE		0x3FFFC000
#define RZA1_CMNCR			CAST(uint32_t *, RZA1_BSC_BASE)
#define RZA1_CS0BCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x0004)
#define RZA1_CS1BCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x0008)
#define RZA1_CS2BCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x000C)
#define RZA1_CS3BCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x0010)
#define RZA1_CS4BCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x0014)
#define RZA1_CS5BCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x0018)
#define RZA1_CS0WCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x0028)
#define RZA1_CS1WCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x002C)
#define RZA1_CS2WCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x0030)
#define RZA1_CS3WCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x0034)
#define RZA1_CS4WCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x0038)
#define RZA1_CS5WCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x003C)
#define RZA1_SDCR			CAST(uint32_t *, RZA1_BSC_BASE + 0x004C)
#define RZA1_RTCSR			CAST(uint32_t *, RZA1_BSC_BASE + 0x0050)
#define RZA1_RTCNT			CAST(uint32_t *, RZA1_BSC_BASE + 0x0054)
#define RZA1_RTCOR			CAST(uint32_t *, RZA1_BSC_BASE + 0x0058)

/*
 *  シリアルコミュニケーションインタフェースのベースアドレス
 */
#define SCIF0_BASE			0xe8007000
#define SCIF1_BASE			0xe8007800
#define SCIF2_BASE			0xe8008000
#define SCIF3_BASE			0xe8008800
#define SCIF4_BASE			0xe8009000
#ifdef TOPPERS_RZA1H
#define SCIF5_BASE			0xe8009800
#define SCIF6_BASE			0xe800a000
#define SCIF7_BASE			0xe800a800
#endif /* TOPPERS_RZA1H */

/*
 *  低消費電力モード関連のベースアドレスとレジスタ
 */
#define RZA1_LOWPWR_BASE	0xfcfe0000
#define RZA1_STBCR1			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x020)
#define RZA1_STBCR2			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x024)
#define RZA1_STBCR3			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x420)
#define RZA1_STBCR4			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x424)
#define RZA1_STBCR5			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x428)
#define RZA1_STBCR6			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x42C)
#define RZA1_STBCR7			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x430)
#define RZA1_STBCR8			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x434)
#define RZA1_STBCR9			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x438)
#define RZA1_STBCR10		CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x43C)
#define RZA1_STBCR11		CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x440)
#define RZA1_STBCR12		CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x444)
#define RZA1_STBCR13		CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x470)
#define RZA1_SYSCR1			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x400)
#define RZA1_SYSCR2			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x404)
#define RZA1_SYSCR3			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x408)
#define RZA1_CPUSTS			CAST(uint8_t *, RZA1_LOWPWR_BASE + 0x018)

/*
 *  汎用入出力ポートのベースアドレスとレジスタ
 */
#define RZA1_PORT_BASE		0xfcfe3000
#define RZA1_PORT_P(n)		CAST(uint16_t *, (RZA1_PORT_BASE + 0x0000 + (n)*4))
#define RZA1_PORT_PSR(n)	CAST(uint32_t *, (RZA1_PORT_BASE + 0x0100 + (n)*4))
#define RZA1_PORT_PPR(n)	CAST(uint16_t *, (RZA1_PORT_BASE + 0x0200 + (n)*4))
#define RZA1_PORT_PM(n)		CAST(uint16_t *, (RZA1_PORT_BASE + 0x0300 + (n)*4))
#define RZA1_PORT_PMC(n)	CAST(uint16_t *, (RZA1_PORT_BASE + 0x0400 + (n)*4))
#define RZA1_PORT_PFC(n)	CAST(uint16_t *, (RZA1_PORT_BASE + 0x0500 + (n)*4))
#define RZA1_PORT_PFCE(n)	CAST(uint16_t *, (RZA1_PORT_BASE + 0x0600 + (n)*4))
#define RZA1_PORT_PFCAE(n)	CAST(uint16_t *, (RZA1_PORT_BASE + 0x0a00 + (n)*4))
#define RZA1_PORT_PIBC(n)	CAST(uint16_t *, (RZA1_PORT_BASE + 0x4000 + (n)*4))
#define RZA1_PORT_PBDC(n)	CAST(uint16_t *, (RZA1_PORT_BASE + 0x4100 + (n)*4))
#define RZA1_PORT_PIPC(n)	CAST(uint16_t *, (RZA1_PORT_BASE + 0x4200 + (n)*4))

/*
 *	割込み番号
 */
#define INTNO_IRQ0			32		/* IRQ0 */
#define INTNO_IRQ1			33		/* IRQ1 */
#define INTNO_IRQ2			34		/* IRQ2 */
#define INTNO_IRQ3			35		/* IRQ3 */
#define INTNO_IRQ4			36		/* IRQ4 */
#define INTNO_IRQ5			37		/* IRQ5 */
#define INTNO_IRQ6			38		/* IRQ6 */
#define INTNO_IRQ7			39		/* IRQ7 */
#define INTNO_OSTM0			134		/* OSタイマ0 */
#define INTNO_OSTM1			135		/* OSタイマ1 */
#define INTNO_SCIF0_BRI		221		/* SCIF0 ブレーク割込み */
#define INTNO_SCIF0_ERI		222		/* SCIF0 エラー割込み */
#define INTNO_SCIF0_RXI		223		/* SCIF0 受信割込み */
#define INTNO_SCIF0_TXI		224		/* SCIF0 送信割込み */
#define INTNO_SCIF1_BRI		225		/* SCIF1 ブレーク割込み */
#define INTNO_SCIF1_ERI		226		/* SCIF1 エラー割込み */
#define INTNO_SCIF1_RXI		227		/* SCIF1 受信割込み */
#define INTNO_SCIF1_TXI		228		/* SCIF1 送信割込み */
#define INTNO_SCIF2_BRI		229		/* SCIF2 ブレーク割込み */
#define INTNO_SCIF2_ERI		230		/* SCIF2 エラー割込み */
#define INTNO_SCIF2_RXI		231		/* SCIF2 受信割込み */
#define INTNO_SCIF2_TXI		232		/* SCIF2 送信割込み */
#define INTNO_SCIF3_BRI		233		/* SCIF3 ブレーク割込み */
#define INTNO_SCIF3_ERI		234		/* SCIF3 エラー割込み */
#define INTNO_SCIF3_RXI		235		/* SCIF3 受信割込み */
#define INTNO_SCIF3_TXI		236		/* SCIF3 送信割込み */
#define INTNO_SCIF4_BRI		237		/* SCIF4 ブレーク割込み */
#define INTNO_SCIF4_ERI		238		/* SCIF4 エラー割込み */
#define INTNO_SCIF4_RXI		239		/* SCIF4 受信割込み */
#define INTNO_SCIF4_TXI		240		/* SCIF4 送信割込み */
#ifdef TOPPERS_RZA1H
#define INTNO_SCIF5_BRI		241		/* SCIF5 ブレーク割込み */
#define INTNO_SCIF5_ERI		242		/* SCIF5 エラー割込み */
#define INTNO_SCIF5_RXI		243		/* SCIF5 受信割込み */
#define INTNO_SCIF5_TXI		244		/* SCIF5 送信割込み */
#define INTNO_SCIF6_BRI		245		/* SCIF6 ブレーク割込み */
#define INTNO_SCIF6_ERI		246		/* SCIF6 エラー割込み */
#define INTNO_SCIF6_RXI		247		/* SCIF6 受信割込み */
#define INTNO_SCIF6_TXI		248		/* SCIF6 送信割込み */
#define INTNO_SCIF7_BRI		249		/* SCIF7 ブレーク割込み */
#define INTNO_SCIF7_ERI		250		/* SCIF7 エラー割込み */
#define INTNO_SCIF7_RXI		251		/* SCIF7 受信割込み */
#define INTNO_SCIF7_TXI		252		/* SCIF7 送信割込み */
#endif /* TOPPERS_RZA1H */

#ifndef TOPPERS_MACRO_ONLY

/*
 *  IRQ割込み要求のクリア
 */
Inline void
rza1_clear_irq(INTNO intno)
{
	uint16_t	reg;

	reg = sil_reh_mem(RZA1_IRQRR);
	reg &= ~(0x01U << (intno - INTNO_IRQ0));
	sil_swrh_mem(RZA1_IRQRR, reg);
}

/*
 *  汎用入出力ポートの設定
 *
 *  汎用入出力ポートの制御レジスタの特定のビットを，セット（setが0でな
 *  い時）またはクリア（setが0の時）する．
 */
Inline void
rza1_config_port(uint16_t *reg, uint_t bit, uint_t set)
{
	uint16_t	val;
	uint16_t	mask;

	mask = 0x01U << bit;
	val = sil_reh_mem(reg);
	if (set == 0) {
		val &= ~mask;
	}
	else {
		val |= mask;
	}
	sil_wrh_mem(reg, val);
}

#endif /* TOPPERS_MACRO_ONLY */
#endif /* TOPPERS_RZA1_H */
