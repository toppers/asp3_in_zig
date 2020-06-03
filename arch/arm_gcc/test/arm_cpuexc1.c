/*
 *  TOPPERS Software
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 * 
 *  Copyright (C) 2007-2019 by Embedded and Real-Time Systems Laboratory
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
 *  $Id: arm_cpuexc1.c 1308 2019-10-30 07:45:26Z ertl-hiro $
 */

/* 
 *		ARM向けCPU例外処理のテスト(1)
 *
 * 【テストの目的】
 *
 *  ARMコア依存部のCPU例外処理をテストする．未定義命令，SVC，プリフェッ
 *  チアボート，データアボートに対して，CPU例外処理のテスト(6)とCPU例
 *  外処理のテスト(5)の状況を連続してテストする．また，フェイタルデー
 *  タアボートに対して，CPU例外処理のテスト(6)の状況でテストする．
 *
 * 【テスト項目】
 *
 *  未定義命令，SVC，プリフェッチアボート，データアボートに対して，以
 *  下の(1)と(2)をテストする．
 *
 *  (1) タスクコンテキスト，割込ロック解除状態，CPUロック解除状態，割
 *      込み優先度マスク全解除状態，ディスパッチ許可状態で発生したCPU
 *      例外において，以下を確認する．
 *
 *	(1-A) CPU例外ハンドラ実行開始時にCPUロックフラグが変化しないこと
 *	(1-B) CPU例外ハンドラ実行開始時に割込み優先度マスクが変化しないこと
 *		！CPU例外ハンドラ中で割込み優先度マスクを読めないため，テストで
 *		　きない．
 *	(1-C) CPU例外ハンドラ実行開始時にディスパッチ禁止フラグが変化しないこと
 *	(1-D) CPU例外ハンドラリターン時にCPUロックフラグが元に戻ること
 *	(1-E) CPU例外ハンドラリターン時に割込み優先度マスクが元に戻ること
 *	(1-F) CPU例外ハンドラリターン時にディスパッチ禁止フラグが変化しないこと
 *	(1-G) xsns_dpnがfalseを返すこと
 *	(1-H) タスク切換えによるリカバリができること
 *
 *  (2) タスクコンテキスト，割込ロック解除状態，CPUロック状態，割込み
 *      優先度マスク全解除状態，ディスパッチ禁止状態で発生したCPU例外
 *      において，以下を確認する（フェイタルデータアボートの場合を除
 *      く）．
 *
 *	(2-A) CPU例外ハンドラ実行開始時にCPUロックフラグが変化しないこと
 *	(2-B) CPU例外ハンドラ実行開始時に割込み優先度マスクが変化しないこと
 *		！CPU例外ハンドラ中で割込み優先度マスクを読めないため，テストで
 *		　きない．
 *	(2-C) CPU例外ハンドラ実行開始時にディスパッチ禁止フラグが変化しないこと
 *	(2-D) CPU例外ハンドラリターン時にCPUロックフラグが元に戻ること
 *	(2-E) CPU例外ハンドラリターン時に割込み優先度マスクが元に戻ること
 *	(2-F) CPU例外ハンドラリターン時にディスパッチ禁止フラグが変化しないこと
 *	(2-G) xsns_dpnがtrueを返すこと
 *
 *  フェイタルデータアボートに対して，以下の(3)をテストする．
 *
 *  (3) タスクコンテキスト，割込ロック解除状態，CPUロック解除状態，割
 *      込み優先度マスク全解除状態，ディスパッチ許可状態で発生したフェ
 *      イタルデータアボート例外において，以下を確認する．
 *
 *  (3-A) CPU例外ハンドラにおいて，CPUロック状態になっていること
 *  (3-B) CPU例外ハンドラにおいて，xsns_dpnがtrueを返すこと
 *
 * 【使用リソース】
 *
 *	TASK1: 中優先度タスク，TA_ACT属性
 *	TASK2: 高優先度タスク
 *	CPUEXC1: 未定義命令 CPU例外ハンドラ
 *	CPUEXC2: SVC CPU例外ハンドラ
 *	CPUEXC3: プリフェッチアボート CPU例外ハンドラ
 *	CPUEXC4: データアボート CPU例外ハンドラ
 *	CPUEXC5: フェイタルデータアボート CPU例外ハンドラ
 *
 * 【テストシーケンス】
 *
 *	// 未定義命令
 *	== TASK1-1（1回目）==
 *	1:	state(false, false, false, false, false)
 *		ipm(TIPM_ENAALL)
 *		DO(RAISE_CPU_EXCEPTION_UNDEF)
 *	== CPUEXC1-1（1回目）==
 *	2:	state(true, false, false, true, false)				... (1-A)(1-C)
 *		assert(xsns_dpn(p_excinf) == false)					... (1-G)
 *  3:	act_tsk(TASK2)
 *		loc_cpu()	... あえてCPUロック状態にしてみる
 *  	RETURN
 *	== TASK2-1（1回目）==
 *	4:	state(false, false, false, false, false)			... (1-D)(1-E)(1-F)
 *		ipm(TIPM_ENAALL)
 *	5:	ter_tsk(TASK1)										... (1-H)
 *	6:	act_tsk(TASK1)										... (1-H)
 *	7:	ext_tsk()
 *	== TASK1-2（2回目）==
 *	8:	state(false, false, false, false, false)			... (1-H)
 *		ipm(TIPM_ENAALL)
 *		dis_dsp()
 *		loc_cpu()
 *	9:	state(false, true, true, true, false)
 *		DO(RAISE_CPU_EXCEPTION_UNDEF)
 *	== CPUEXC1-2（2回目）==
 *	10:	state(true, true, true, true, false)				... (2-A)(2-C)
 *		assert(xsns_dpn(p_excinf) == true)					... (2-G)
 *	11:	DO(PREPARE_RETURN_CPUEXC_UNDEF)
 *		RETURN
 *	== TASK1-2（続き）==
 *	12:	state(false, true, true, true, false)				... (2-D)(2-E)(2-F)
 *		unl_cpu()
 *		ena_dsp()
 *
 *	// SVC
 *	13:	state(false, false, false, false, false)
 *		ipm(TIPM_ENAALL)
 *		DO(RAISE_CPU_EXCEPTION_SVC)
 *	== CPUEXC2-1（1回目）==
 *	14:	state(true, false, false, true, false)				... (1-A)(1-C)
 *		assert(xsns_dpn(p_excinf) == false)					... (1-G)
 *  15:	act_tsk(TASK2)
 *		loc_cpu()	... あえてCPUロック状態にしてみる
 *  	RETURN
 *	== TASK2-2（2回目）==
 *	16:	state(false, false, false, false, false)			... (1-D)(1-E)(1-F)
 *		ipm(TIPM_ENAALL)
 *	17:	ter_tsk(TASK1)										... (1-H)
 *	18:	act_tsk(TASK1)										... (1-H)
 *	19:	ext_tsk()
 *	== TASK1-3（3回目）==
 *	20:	state(false, false, false, false, false)			... (1-H)
 *		ipm(TIPM_ENAALL)
 *		dis_dsp()
 *		loc_cpu()
 *	21:	state(false, true, true, true, false)
 *		DO(RAISE_CPU_EXCEPTION_SVC)
 *	== CPUEXC2-2（2回目）==
 *	22:	state(true, true, true, true, false)				... (2-A)(2-C)
 *		assert(xsns_dpn(p_excinf) == true)					... (2-G)
 *	23:	DO(PREPARE_RETURN_CPUEXC_SVC)
 *		RETURN
 *	== TASK1-3（続き）==
 *	24:	state(false, true, true, true, false)				... (2-D)(2-E)(2-F)
 *		unl_cpu()
 *		ena_dsp()
 *
 *	// プリフェッチアボート
 *	25:	state(false, false, false, false, false)
 *		ipm(TIPM_ENAALL)
 *		DO(RAISE_CPU_EXCEPTION_PABORT)
 *	== CPUEXC3-1（1回目）==
 *	26:	state(true, false, false, true, false)				... (1-A)(1-C)
 *		assert(xsns_dpn(p_excinf) == false)					... (1-G)
 *  27:	act_tsk(TASK2)
 *		loc_cpu()	... あえてCPUロック状態にしてみる
 *  	RETURN
 *	== TASK2-3（3回目）==
 *	28:	state(false, false, false, false, false)			... (1-D)(1-E)(1-F)
 *		ipm(TIPM_ENAALL)
 *	29:	ter_tsk(TASK1)										... (1-H)
 *	30:	act_tsk(TASK1)										... (1-H)
 *	31:	ext_tsk()
 *	== TASK1-4（4回目）==
 *	32:	state(false, false, false, false, false)			... (1-H)
 *		ipm(TIPM_ENAALL)
 *		dis_dsp()
 *		loc_cpu()
 *	33:	state(false, true, true, true, false)
 *		DO(RAISE_CPU_EXCEPTION_PABORT)
 *	== CPUEXC3-2（2回目）==
 *	34:	state(true, true, true, true, false)				... (2-A)(2-C)
 *		assert(xsns_dpn(p_excinf) == true)					... (2-G)
 *	35:	DO(PREPARE_RETURN_CPUEXC_PABORT)
 *		RETURN
 *	== TASK1-4（続き）==
 *	36:	state(false, true, true, true, false)				... (2-D)(2-E)(2-F)
 *		unl_cpu()
 *		ena_dsp()
 *
 *	// データアボート
 *	37:	state(false, false, false, false, false)
 *		ipm(TIPM_ENAALL)
 *		DO(RAISE_CPU_EXCEPTION_DABORT)
 *	== CPUEXC4-1（1回目）==
 *	38:	state(true, false, false, true, false)				... (1-A)(1-C)
 *		assert(xsns_dpn(p_excinf) == false)					... (1-G)
 *  39:	act_tsk(TASK2)
 *		loc_cpu()	... あえてCPUロック状態にしてみる
 *  	RETURN
 *	== TASK2-4（4回目）==
 *	40:	state(false, false, false, false, false)			... (1-D)(1-E)(1-F)
 *		ipm(TIPM_ENAALL)
 *	41:	ter_tsk(TASK1)										... (1-H)
 *	42:	act_tsk(TASK1)										... (1-H)
 *	43:	ext_tsk()
 *	== TASK1-5（5回目）==
 *	44:	state(false, false, false, false, false)			... (1-H)
 *		ipm(TIPM_ENAALL)
 *		dis_dsp()
 *		loc_cpu()
 *	45:	state(false, true, true, true, false)
 *		DO(RAISE_CPU_EXCEPTION_DABORT)
 *	== CPUEXC4-2（2回目）==
 *	46:	state(true, true, true, true, false)				... (2-A)(2-C)
 *		assert(xsns_dpn(p_excinf) == true)					... (2-G)
 *	47:	DO(PREPARE_RETURN_CPUEXC_DABORT)
 *		RETURN
 *	== TASK1-5（続き）==
 *	48:	state(false, true, true, true, false)				... (2-D)(2-E)(2-F)
 *		unl_cpu()
 *		ena_dsp()
 *
 *	// フェイタルデータアボート
 *	49:	state(false, false, false, false, false)
 *		ipm(TIPM_ENAALL)
 *		DO(RAISE_CPU_EXCEPTION_FATAL)
 *	== CPUEXC5 ==
 *	50:	state(true, true, false, true, false)				... (3-A)
 *		assert(xsns_dpn(p_excinf) == true)					... (3-B)
 *	51:	END
 */

#include <kernel.h>
#include <t_syslog.h>
#include "syssvc/test_svc.h"
#include "kernel_cfg.h"
#include "test_common.h"

/* DO NOT DELETE THIS LINE -- gentest depends on it. */

static uint_t	cpuexc1_count = 0;

void
cpuexc1_handler(void *p_excinf)
{
	ER_UINT	ercd;

	switch (++cpuexc1_count) {
	case 1:
		check_point(2);
		check_state(true, false, false, true, false);

		check_assert(xsns_dpn(p_excinf) == false);

		check_point(3);
		ercd = act_tsk(TASK2);
		check_ercd(ercd, E_OK);

		ercd = loc_cpu();
		check_ercd(ercd, E_OK);

		return;

		check_assert(false);

	case 2:
		check_point(10);
		check_state(true, true, true, true, false);

		check_assert(xsns_dpn(p_excinf) == true);

		check_point(11);
		PREPARE_RETURN_CPUEXC_UNDEF;

		return;

		check_assert(false);

	default:
		check_assert(false);
	}
	check_assert(false);
}

static uint_t	cpuexc2_count = 0;

void
cpuexc2_handler(void *p_excinf)
{
	ER_UINT	ercd;

	switch (++cpuexc2_count) {
	case 1:
		check_point(14);
		check_state(true, false, false, true, false);

		check_assert(xsns_dpn(p_excinf) == false);

		check_point(15);
		ercd = act_tsk(TASK2);
		check_ercd(ercd, E_OK);

		ercd = loc_cpu();
		check_ercd(ercd, E_OK);

		return;

		check_assert(false);

	case 2:
		check_point(22);
		check_state(true, true, true, true, false);

		check_assert(xsns_dpn(p_excinf) == true);

		check_point(23);
		PREPARE_RETURN_CPUEXC_SVC;

		return;

		check_assert(false);

	default:
		check_assert(false);
	}
	check_assert(false);
}

static uint_t	cpuexc3_count = 0;

void
cpuexc3_handler(void *p_excinf)
{
	ER_UINT	ercd;

	switch (++cpuexc3_count) {
	case 1:
		check_point(26);
		check_state(true, false, false, true, false);

		check_assert(xsns_dpn(p_excinf) == false);

		check_point(27);
		ercd = act_tsk(TASK2);
		check_ercd(ercd, E_OK);

		ercd = loc_cpu();
		check_ercd(ercd, E_OK);

		return;

		check_assert(false);

	case 2:
		check_point(34);
		check_state(true, true, true, true, false);

		check_assert(xsns_dpn(p_excinf) == true);

		check_point(35);
		PREPARE_RETURN_CPUEXC_PABORT;

		return;

		check_assert(false);

	default:
		check_assert(false);
	}
	check_assert(false);
}

static uint_t	cpuexc4_count = 0;

void
cpuexc4_handler(void *p_excinf)
{
	ER_UINT	ercd;

	switch (++cpuexc4_count) {
	case 1:
		check_point(38);
		check_state(true, false, false, true, false);

		check_assert(xsns_dpn(p_excinf) == false);

		check_point(39);
		ercd = act_tsk(TASK2);
		check_ercd(ercd, E_OK);

		ercd = loc_cpu();
		check_ercd(ercd, E_OK);

		return;

		check_assert(false);

	case 2:
		check_point(46);
		check_state(true, true, true, true, false);

		check_assert(xsns_dpn(p_excinf) == true);

		check_point(47);
		PREPARE_RETURN_CPUEXC_DABORT;

		return;

		check_assert(false);

	default:
		check_assert(false);
	}
	check_assert(false);
}

void
cpuexc5_handler(void *p_excinf)
{

	check_point(50);
	check_state(true, true, false, true, false);

	check_assert(xsns_dpn(p_excinf) == true);

	check_finish(51);
	check_assert(false);
}

static uint_t	task1_count = 0;

void
task1(EXINF exinf)
{
	ER_UINT	ercd;

	switch (++task1_count) {
	case 1:
		test_start(__FILE__);

		check_point(1);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		RAISE_CPU_EXCEPTION_UNDEF;

		check_assert(false);

	case 2:
		check_point(8);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		ercd = dis_dsp();
		check_ercd(ercd, E_OK);

		ercd = loc_cpu();
		check_ercd(ercd, E_OK);

		check_point(9);
		check_state(false, true, true, true, false);

		RAISE_CPU_EXCEPTION_UNDEF;

		check_point(12);
		check_state(false, true, true, true, false);

		ercd = unl_cpu();
		check_ercd(ercd, E_OK);

		ercd = ena_dsp();
		check_ercd(ercd, E_OK);

		check_point(13);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		RAISE_CPU_EXCEPTION_SVC;

		check_assert(false);

	case 3:
		check_point(20);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		ercd = dis_dsp();
		check_ercd(ercd, E_OK);

		ercd = loc_cpu();
		check_ercd(ercd, E_OK);

		check_point(21);
		check_state(false, true, true, true, false);

		RAISE_CPU_EXCEPTION_SVC;

		check_point(24);
		check_state(false, true, true, true, false);

		ercd = unl_cpu();
		check_ercd(ercd, E_OK);

		ercd = ena_dsp();
		check_ercd(ercd, E_OK);

		check_point(25);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		RAISE_CPU_EXCEPTION_PABORT;

		check_assert(false);

	case 4:
		check_point(32);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		ercd = dis_dsp();
		check_ercd(ercd, E_OK);

		ercd = loc_cpu();
		check_ercd(ercd, E_OK);

		check_point(33);
		check_state(false, true, true, true, false);

		RAISE_CPU_EXCEPTION_PABORT;

		check_point(36);
		check_state(false, true, true, true, false);

		ercd = unl_cpu();
		check_ercd(ercd, E_OK);

		ercd = ena_dsp();
		check_ercd(ercd, E_OK);

		check_point(37);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		RAISE_CPU_EXCEPTION_DABORT;

		check_assert(false);

	case 5:
		check_point(44);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		ercd = dis_dsp();
		check_ercd(ercd, E_OK);

		ercd = loc_cpu();
		check_ercd(ercd, E_OK);

		check_point(45);
		check_state(false, true, true, true, false);

		RAISE_CPU_EXCEPTION_DABORT;

		check_point(48);
		check_state(false, true, true, true, false);

		ercd = unl_cpu();
		check_ercd(ercd, E_OK);

		ercd = ena_dsp();
		check_ercd(ercd, E_OK);

		check_point(49);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		RAISE_CPU_EXCEPTION_FATAL;

		check_assert(false);

	default:
		check_assert(false);
	}
	check_assert(false);
}

static uint_t	task2_count = 0;

void
task2(EXINF exinf)
{
	ER_UINT	ercd;

	switch (++task2_count) {
	case 1:
		check_point(4);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		check_point(5);
		ercd = ter_tsk(TASK1);
		check_ercd(ercd, E_OK);

		check_point(6);
		ercd = act_tsk(TASK1);
		check_ercd(ercd, E_OK);

		check_point(7);
		ercd = ext_tsk();
		check_ercd(ercd, E_OK);

		check_assert(false);

	case 2:
		check_point(16);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		check_point(17);
		ercd = ter_tsk(TASK1);
		check_ercd(ercd, E_OK);

		check_point(18);
		ercd = act_tsk(TASK1);
		check_ercd(ercd, E_OK);

		check_point(19);
		ercd = ext_tsk();
		check_ercd(ercd, E_OK);

		check_assert(false);

	case 3:
		check_point(28);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		check_point(29);
		ercd = ter_tsk(TASK1);
		check_ercd(ercd, E_OK);

		check_point(30);
		ercd = act_tsk(TASK1);
		check_ercd(ercd, E_OK);

		check_point(31);
		ercd = ext_tsk();
		check_ercd(ercd, E_OK);

		check_assert(false);

	case 4:
		check_point(40);
		check_state(false, false, false, false, false);

		check_ipm(TIPM_ENAALL);

		check_point(41);
		ercd = ter_tsk(TASK1);
		check_ercd(ercd, E_OK);

		check_point(42);
		ercd = act_tsk(TASK1);
		check_ercd(ercd, E_OK);

		check_point(43);
		ercd = ext_tsk();
		check_ercd(ercd, E_OK);

		check_assert(false);

	default:
		check_assert(false);
	}
	check_assert(false);
}
