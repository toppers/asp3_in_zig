/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 *
 *  Copyright (C) 2012-2018 by Embedded and Real-Time Systems Laboratory
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
 *  $Id: zybo_z7.h 1264 2019-09-30 03:01:49Z ertl-honda $
 */

/*
 *		ZYBOのハードウェア資源の定義
 */
#ifndef TOPPERS_ZYBO_H
#define TOPPERS_ZYBO_H

/*
 *  各クロック周波数の定義
 */
#define ZYNQ_CPU_6X4X_MHZ		667U		/* 667MHz */
#define ZYNQ_CPU_3X2X_MHZ		356U		/* 356MHz */
#define ZYNQ_CPU_2X_MHZ			222U		/* 222MHz */
#define ZYNQ_CPU_1X_MHZ			111U		/* 111MHz */

/*
 *  各タイマのプリスケール値と周波数の定義
 *
 *  周辺デバイス向けクロック（ZYNQ_CPU_3X2X_MZ，325MHz）を65分周して，
 *  5MHzの周波数で使用する．
 */
#define MPCORE_TMR_PS_VALUE		64
#define MPCORE_TMR_FREQ			5

#define MPCORE_WDG_PS_VALUE		64
#define MPCORE_WDG_FREQ			5

#define MPCORE_GTC_PS_VALUE		64
#define MPCORE_GTC_FREQ			5

/*
 *  UARTの設定値の定義（115.2Kbpsで動作させる場合）
 */
#define XUARTPS_BAUDGEN_115K	0x7cU
#define XUARTPS_BAUDDIV_115K	0x06U

#endif /* TOPPERS_ZYBO_H */
