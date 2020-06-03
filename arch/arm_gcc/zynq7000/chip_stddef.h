/*
 *		t_stddef.hのチップ依存部（Zynq7000用）
 *
 *  このヘッダファイルは，target_stddef.h（または，そこからインクルード
 *  されるファイル）のみからインクルードされる．他のファイルから直接イ
 *  ンクルードしてはならない．
 * 
 *  $Id: chip_stddef.h 1074 2018-11-25 01:32:04Z ertl-hiro $
 */

#ifndef TOPPERS_CHIP_STDDEF_H
#define TOPPERS_CHIP_STDDEF_H

/*
 *  ターゲットを識別するためのマクロの定義
 */
#define TOPPERS_ZYNQ7000				/* チップ略称 */

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
