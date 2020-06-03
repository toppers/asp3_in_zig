/*
 *		t_stddef.hのターゲット依存部（GR-PEACH用）
 *
 *  このヘッダファイルは，t_stddef.hの先頭でインクルードされる．他のファ
 *  イルからは直接インクルードすることはない．他のヘッダファイルに先立っ
 *  て処理されるため，他のヘッダファイルに依存してはならない．
 * 
 *  $Id: target_stddef.h 1057 2018-11-19 15:32:58Z ertl-hiro $
 */

#ifndef TOPPERS_TARGET_STDDEF_H
#define TOPPERS_TARGET_STDDEF_H

/*
 *  ターゲットを識別するためのマクロの定義
 */
#define TOPPERS_GR_PEACH				/* システム略称 */
#define TOPPERS_RZA1H					/* RZ/A1H */

/*
 *  チッブで共通な定義
 */
#include "chip_stddef.h"

/*
 *  アサーションの失敗時の実行中断処理
 */
#ifndef TOPPERS_MACRO_ONLY

Inline void
TOPPERS_assert_abort(void)
{
	/*
	 *  bkpt命令によりデバッガに制御を移す（パラメータが何が良いか未検討）
	 */
	Asm("bkpt #0");
}

#endif /* TOPPERS_MACRO_ONLY */
#endif /* TOPPERS_TARGET_STDDEF_H */
