/*
 *		kernel.hのターゲット依存部（GR-PEACH用）
 *
 *  このヘッダファイルは，kernel.hからインクルードされる．他のファイル
 *  から直接インクルードすることはない．このファイルをインクルードする
 *  前に，t_stddef.hがインクルードされるので，それに依存してもよい．
 * 
 *  $Id: target_kernel.h 1057 2018-11-19 15:32:58Z ertl-hiro $
 */

#ifndef TOPPERS_TARGET_KERNEL_H
#define TOPPERS_TARGET_KERNEL_H

/*
 *  高分解能タイマのタイマ周期
 *
 *  2^32 / 33.33…を丸めた値とする．
 */
#define TCYC_HRTCNT		128849019U

/*
 *  高分解能タイマのカウント値の進み幅
 */
#define TSTEP_HRTCNT	1U

/*
 *  オーバランハンドラの残りプロセッサ時間に指定できる最大値
 *
 *  この値をOSタイマへの設定値に変換してタイマに設定した後，タイマの現
 *  在値を読み出してμ秒単位に変換できる値としている．タイマの現在値を
 *  μ秒単位に変換する時に34を加えるため，以下の条件を満たす最大の値と
 *  する．
 *		(TMAX_OVRTIM * 33 + TMAX_OVRTIM / 3 + 1) + 34 < 2^32
 */
#define TMAX_OVRTIM		128849017U

/*
 *  チップで共通な定義
 */
#include "chip_kernel.h"

#endif /* TOPPERS_TARGET_KERNEL_H */
