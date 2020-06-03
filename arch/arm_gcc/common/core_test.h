/*
 *  TOPPERS/ASP Kernel
 *      Toyohashi Open Platform for Embedded Real-Time Systems/
 *      Advanced Standard Profile Kernel
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
 *  $Id: core_test.h 1308 2019-10-30 07:45:26Z ertl-hiro $
 */

/*
 *		テストプログラムのコア依存部（ARM用）
 *
 *  このヘッダファイルは，target_test.h（または，そこからインクルードさ
 *  れるファイル）のみからインクルードされる．他のファイルから直接イン
 *  クルードしてはならない．
 */

#ifndef TOPPERS_CORE_TEST_H
#define TOPPERS_CORE_TEST_H

#include <t_stddef.h>
#include "arm.h"

/*
 *  不正アドレスの定義（メモリのない番地に設定する）
 */
#ifndef ILLEGAL_IADDR
#define ILLEGAL_IADDR			0xd0000000U		/* 不正命令アドレス */
#endif /* ILLEGAL_IADDR */

#ifndef ILLEGAL_DADDR
#define ILLEGAL_DADDR			0xd0000000U		/* 不正データアドレス */
#endif /* ILLEGAL_DADDR */

/*
 *  サンプルプログラムで用いるCPU例外の発生
 */
#if defined(USE_CPUEXC_SVC)

#define CPUEXC1					EXCNO_SVC		/* スーパバイザコール */
#define RAISE_CPU_EXCEPTION		RAISE_CPU_EXCEPTION_SVC
#define PREPARE_RETURN_CPUEXC	PREPARE_RETURN_CPUEXC_SVC

#elif defined(USE_CPUEXC_PABORT)

#define CPUEXC1					EXCNO_PABORT	/* プリフェッチアボート */
#define RAISE_CPU_EXCEPTION		RAISE_CPU_EXCEPTION_PABORT
#define PREPARE_RETURN_CPUEXC	PREPARE_RETURN_CPUEXC_PABORT

#elif defined(USE_CPUEXC_DABORT)

#define CPUEXC1					EXCNO_DABORT	/* データアボート */
#define RAISE_CPU_EXCEPTION		RAISE_CPU_EXCEPTION_DABORT
#define PREPARE_RETURN_CPUEXC	PREPARE_RETURN_CPUEXC_DABORT

#elif defined(USE_CPUEXC_FATAL)

#define CPUEXC1					EXCNO_FATAL		/* フェイタルデータアボート */
#define RAISE_CPU_EXCEPTION		RAISE_CPU_EXCEPTION_FATAL
/* フェイタルデータアボート例外ハンドラからリターンしてはならない */

#else

#define CPUEXC1					EXCNO_UNDEF		/* 未定義命令 */
#define RAISE_CPU_EXCEPTION		RAISE_CPU_EXCEPTION_UNDEF
#define PREPARE_RETURN_CPUEXC	PREPARE_RETURN_CPUEXC_UNDEF

#endif

/*
 *  スーパバイザコールによるCPU例外の発生
 *
 *  svc命令によりCPU例外を発生させる．スーパバイザモードでCPU例外を発
 *  生させる場合には，svc命令によりlrレジスタが上書きされるため，lrレ
 *  ジスタは破壊されるものと指定している．CPU例外ハンドラからそのまま
 *  リターンすることで，svc命令の次の命令から実行が継続する．
 */
#define RAISE_CPU_EXCEPTION_SVC			Asm("svc #0":::"lr")
#define PREPARE_RETURN_CPUEXC_SVC

/*
 *  プリフェッチアボートによるCPU例外の発生（スーパバイザモードでCPU例
 *  外を発生させる場合）
 *
 *  不正な番地を関数の先頭番地として呼び出すことで，プリフェッチアボー
 *  トによるCPU例外を発生させる．不正な番地に分岐した命令をスキップし
 *  てCPU例外ハンドラからリターンするために，戻り番地には，lrレジスタ
 *  の値（CPU例外がスーパバイザモードで発生した場合には，不正な番地へ
 *  の分岐命令からのリターン番地が入っている）を設定する．なお，ユーザ
 *  モードでCPU例外を発生させる場合には，戻り番地には，lr_usrレジスタ
 *  の値を設定する必要がある．
 */
#define RAISE_CPU_EXCEPTION_PABORT		(((void (*)(void)) ILLEGAL_IADDR)())
#define PREPARE_RETURN_CPUEXC_PABORT	(((T_EXCINF *) p_excinf)->pc \
											= ((T_EXCINF *) p_excinf)->lr)

/*
 *  データアボートによるCPU例外の発生
 *
 *  不正な番地をリードすることで，データアボートによるCPU例外を発生さ
 *  せる．データアボートを起こした命令をスキップしてCPU例外ハンドラか
 *  らリターンするために，戻り番地から4を減算する（ARMモードで使うこと
 *  を想定している）．
 */
#define RAISE_CPU_EXCEPTION_DABORT		(void)(*((volatile uint32_t *) \
															ILLEGAL_DADDR))
#define PREPARE_RETURN_CPUEXC_DABORT	(((T_EXCINF *) p_excinf)->pc -= 4U)

/*
 *  フェイタルデータアボートによるCPU例外の発生（スーパバイザモードで
 *  CPU例外を発生させる場合）
 *
 *  スタックポインタを不正にして，未定義命令を実行することで，フェイタ
 *  ルデータアボートによるCPU例外を発生させる．CPU例外ハンドラからリター
 *  ンしてはならない．
 */
#define RAISE_CPU_EXCEPTION_FATAL		Asm("mov sp, %0\n" \
										  "\t.word 0xf0500090" \
										  ::"I"(ILLEGAL_DADDR))

/*
 *  未定義命令によるCPU例外の発生
 *
 *  未定義命令によりCPU例外を発生させる．使用している未定義命令は，
 *  "Multiply and multiply accumulate"命令群のエンコーディング内におけ
 *  る未定義命令である．CPU例外ハンドラからそのままリターンすることで，
 *  未定義命令の次の命令から実行が継続する（ARMモードで使うことを想定
 *  している）．
 */
#define RAISE_CPU_EXCEPTION_UNDEF		Asm(".word 0xf0500090")
#define PREPARE_RETURN_CPUEXC_UNDEF

#endif /* TOPPERS_CORE_TEST_H */
