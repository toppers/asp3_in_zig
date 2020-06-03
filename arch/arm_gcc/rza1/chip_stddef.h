/*
 *		t_stddef.hのチップ依存部（RZ/A1用）
 *
 *  このヘッダファイルは，target_stddef.h（または，そこからインクルード
 *  されるファイル）のみからインクルードされる．他のファイルから直接イ
 *  ンクルードしてはならない．
 * 
 *  $Id: chip_stddef.h 1056 2018-11-19 15:03:10Z ertl-hiro $
 */

#ifndef TOPPERS_CHIP_STDDEF_H
#define TOPPERS_CHIP_STDDEF_H

/*
 *  ターゲットを識別するためのマクロの定義
 */
#define TOPPERS_RZA1					/* チップ略称 */

/*
 *  チップを限定するマクロが定義されているかのチェック
 */
#if !defined(TOPPERS_RZA1H) && !defined(TOPPERS_RZA1L)
#error Either TOPPERS_RZA1H or TOPPERS_RZA1L must be defined.
#endif

/*
 *  開発環境で共通な定義
 */
#ifndef TOPPERS_MACRO_ONLY
#include <stdint.h>
#endif /* TOPPERS_MACRO_ONLY */

#define TOPPERS_STDFLOAT_TYPE1
#include "tool_stddef.h"

/*
 *  コアで共通な定義
 */
#include "core_stddef.h"

#endif /* TOPPERS_CHIP_STDDEF_H */
