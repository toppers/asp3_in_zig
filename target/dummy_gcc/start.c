/*
 *		ダミーターゲットのスタートアップモジュール
 *
 *  $Id: start.c 929 2018-03-27 13:16:12Z ertl-hiro $
 */

extern void _kernel_sta_ker(void);

int
main(void)
{
	_kernel_sta_ker();
	return(0);
}
