/*
 *		kernel.hのターゲット依存部（ZYBO用）
 *
 *  このヘッダファイルは，kernel.hからインクルードされる．他のファイル
 *  から直接インクルードすることはない．このファイルをインクルードする
 *  前に，t_stddef.hがインクルードされるので，それに依存してもよい．
 * 
 *  $Id: target_kernel.h 1235 2019-07-09 21:03:43Z ertl-hiro $
 */

#ifndef TOPPERS_TARGET_KERNEL_H
#define TOPPERS_TARGET_KERNEL_H

/*
 *  高分解能タイマのタイマ周期
 */
#ifndef USE_64BIT_HRTCNT
/* TCYC_HRTCNTは定義しない．*/
#endif /* USE_64BIT_HRTCNT */

/*
 *  高分解能タイマのカウント値の進み幅
 */
#define TSTEP_HRTCNT	1U

/*
 *  オーバランハンドラの残りプロセッサ時間に指定できる最大値
 */
#define TMAX_OVRTIM		858993459U			/* floor(2^32/5) */

/*
 *  チップで共通な定義
 */
#include "chip_kernel.h"

#endif /* TOPPERS_TARGET_KERNEL_H */
