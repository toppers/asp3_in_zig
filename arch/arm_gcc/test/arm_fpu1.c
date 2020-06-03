/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 * 
 *  Copyright (C) 2019 by Embedded and Real-Time Systems Laboratory
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
 *  $Id: arm_fpu1.c 1275 2019-10-03 16:01:48Z ertl-hiro $
 */

/* 
 *		ARM向けFPUのテスト(1)
 *
 * 【テストの目的】
 *
 *  ARMコア依存部のFPU対応をテストする．
 *
 * 【テスト項目】
 *
 *  (A) TA_FPU属性のタスクで，浮動小数点演算を行えること
 *  (B) TA_FPU属性のタスクに対して，浮動小数点レジスタが保存されること
 *  (C) TA_FPU属性でないタスクで浮動小数点演算を行うと，未定義命令 CPU
 *      例外が発生すること
 *
 * 【使用リソース】
 *
 *	TASK1: 低優先度タスク，TA_FPU属性，TA_ACT属性
 *	TASK2: 中優先度タスク，TA_FPU属性
 *	TASK3: 中優先度タスク
 *	TASK4: 高優先度タスク
 *	ALM1: アラーム通知，TASK2を起動
 *	CPUEXC1: 未定義命令 CPU例外ハンドラ
 *
 * 【テストシーケンス】
 *
 *	== TASK1（優先度：低）==
 *		VAR(double64_t d1)
 *	1:	DO(d_sin30 = sin(d_30))
 *		DO(d_sin45 = sin(d_45))
 *		DO(d_sin60 = sin(d_60))
 *		sta_alm(ALM1, TEST_TIME_CP * 2)
 *	2:	DO(d1 = sin(d_30))
 *		WAIT(task1_flag)	
 *	== TASK2（優先度：中）==
 *		VAR(double64_t d2)
 *	3:	DO(d2 = sin(d_45))
 *		assert(d2 == d_sin45)
 *	4:	SET(task1_flag)
 *		ext_tsk()
 *	== TASK1（続き）==
 *	// 次の行にチェックポイントを置くとレジスタが保存されてしまう
 *		assert(d1 == d_sin30)
 *	5:	act_tsk(TASK3)
 *	== TASK3（優先度：中）==
 *		VAR(double64_t d3)
 *	// 関数内のどこかでCPU例外が発生
 *	6:	DO(d3 = sin(d_60))
 *		assert(d3 == d_sin60)
 *	== CPUEXC1 ==
 *	7:	assert(xsns_dpn(p_excinf) == false)
 *		get_tid(&tskid)
 *		assert(tskid == TASK3)
 *  	act_tsk(TASK4)
 *  	RETURN
 *	== TASK4（優先度：高）==
 *	8:	END
 */

#include <kernel.h>
#include <t_syslog.h>
#include <math.h>
#include "syssvc/test_svc.h"
#include "kernel_cfg.h"
#include "test_common.h"

double64_t	d_30 = M_PI / 12;
double64_t	d_45 = M_PI / 8;
double64_t	d_60 = M_PI / 6;
double64_t	d_sin30;
double64_t	d_sin45;
double64_t	d_sin60;

volatile bool_t	task1_flag;

/* DO NOT DELETE THIS LINE -- gentest depends on it. */

void
cpuexc1_handler(void *p_excinf)
{
	ER_UINT	ercd;
	ID		tskid;

	check_point(7);
	check_assert(xsns_dpn(p_excinf) == false);

	ercd = get_tid(&tskid);
	check_ercd(ercd, E_OK);

	check_assert(tskid == TASK3);

	ercd = act_tsk(TASK4);
	check_ercd(ercd, E_OK);

	return;

	check_assert(false);
}

void
task1(EXINF exinf)
{
	double64_t	d1;
	ER_UINT	ercd;

	test_start(__FILE__);

	check_point(1);
	d_sin30 = sin(d_30);

	d_sin45 = sin(d_45);

	d_sin60 = sin(d_60);

	ercd = sta_alm(ALM1, TEST_TIME_CP * 2);
	check_ercd(ercd, E_OK);

	check_point(2);
	d1 = sin(d_30);

	WAIT(task1_flag);

	check_assert(d1 == d_sin30);

	check_point(5);
	ercd = act_tsk(TASK3);
	check_ercd(ercd, E_OK);

	check_assert(false);
}

void
task2(EXINF exinf)
{
	double64_t	d2;
	ER_UINT	ercd;

	check_point(3);
	d2 = sin(d_45);

	check_assert(d2 == d_sin45);

	check_point(4);
	SET(task1_flag);

	ercd = ext_tsk();
	check_ercd(ercd, E_OK);

	check_assert(false);
}

void
task3(EXINF exinf)
{
	double64_t	d3;

	check_point(6);
	d3 = sin(d_60);

	check_assert(d3 == d_sin60);

	check_assert(false);
}

void
task4(EXINF exinf)
{

	check_finish(8);
	check_assert(false);
}
