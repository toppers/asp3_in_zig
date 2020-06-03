/*
 *		sil.hのターゲット依存部（CT11MPCore用）
 *
 *  このヘッダファイルは，sil.hからインクルードされる．他のファイルから
 *  直接インクルードすることはない．このファイルをインクルードする前に，
 *  t_stddef.hがインクルードされるので，それに依存してもよい．
 * 
 *  $Id: target_sil.h 1058 2018-11-19 16:19:31Z ertl-hiro $
 */

#ifndef TOPPERS_TARGET_SIL_H
#define TOPPERS_TARGET_SIL_H

/*
 *  プロセッサのエンディアン
 */
#define SIL_ENDIAN_LITTLE

/*
 *  コアで共通な定義（チップ依存部は飛ばす）
 */
#include "core_sil.h"

#endif /* TOPPERS_TARGET_SIL_H */
