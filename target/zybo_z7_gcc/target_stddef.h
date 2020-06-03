/*
 *		t_stddef.hのターゲット依存部（ZYBO用）
 *
 *  このヘッダファイルは，t_stddef.hの先頭でインクルードされる．他のファ
 *  イルからは直接インクルードすることはない．他のヘッダファイルに先立っ
 *  て処理されるため，他のヘッダファイルに依存してはならない．
 * 
 *  $Id: target_stddef.h 1156 2019-01-17 14:31:48Z ertl-hiro $
 */

#ifndef TOPPERS_TARGET_STDDEF_H
#define TOPPERS_TARGET_STDDEF_H

/*
 *  ターゲットを識別するためのマクロの定義
 */
#define TOPPERS_ZYBO					/* システム略称 */

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
#if defined(TOPPERS_USE_QEMU) && !defined(TOPPERS_OMIT_QEMU_SEMIHOSTING)
	/*
	 *  デバッグコンソールへ文字列を出力．
	 */
	Asm("mov r0, #4\n\t"
		"mov r1, %0\n\t"
		"svc 0x00123456" : : "r"("Abort!\n"));

	/*
	 *  QEMUを終了させる．
	 */
	Asm("mov r0, #24\n\t"
		"svc 0x00123456");
#endif
	while (1) ;					/* trueの定義前なので，1と記述する */
}

#endif /* TOPPERS_MACRO_ONLY */
#endif /* TOPPERS_TARGET_STDDEF_H */
