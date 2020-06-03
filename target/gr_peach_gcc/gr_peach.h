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
 *  $Id: gr_peach.h 914 2018-03-07 10:16:16Z ertl-hiro $
 */

/*
 *		GR-PEACHのハードウェア資源の定義
 */

#ifndef TOPPERS_GR_PEACH_H
#define TOPPERS_GR_PEACH_H

#include <t_stddef.h>

/*
 *  各クロック周波数の定義
 */
#define RZA1_CLK_I			400000000UL		/* 400MHz */
#define RZA1_CLK_I_MHZ		400				/* 400MHz */
#define RZA1_CLK_G			266666667UL		/* 266.66…MHz */
#define RZA1_CLK_B			133333333UL		/* 133.33…MHz */
#define RZA1_CLK_P1			66666667UL		/* 66.66…MHz */
#define RZA1_CLK_P0			33333333UL		/* 33.33…MHz */

/*
 *  LEDの点灯／消灯
 */
#define GR_PEACH_LED_RED	13
#define GR_PEACH_LED_GREEN	14
#define GR_PEACH_LED_BLUE	15
#define GR_PEACH_LED_USER	12

#ifndef TOPPERS_MACRO_ONLY
extern void gr_peach_set_led(uint_t led, uint_t set);
#endif /* TOPPERS_MACRO_ONLY */

#endif /* TOPPERS_GR_PEACH_H */
