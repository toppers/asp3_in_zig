///
///  kernel.zigのコア依存部（ARM用）
///

///
///  用いるライブラリ
///
const arm = @import("arm.zig");

///
///  スタックの型
///
///  ARMでは，スタックを8バイト境界に配置する必要がある．ここでalign指
///  定を行うことはできず，スタックを確保する側で行う必要がある．
///
pub const STK_T = u64;

///
///  アプリケーションに直接見せる定義
///
pub const core_publish = struct {
    ///
    ///  ターゲット定義のタスク属性
    ///
    pub const TA_FPU = 0x08;        // FPUレジスタをコンテキストに含める

    ///
    ///  CPU例外ハンドラ番号の数
    ///  
    pub const TNUM_EXCNO = 7;

    ///
    ///  CPU例外ハンドラ番号の定義
    ///
    pub const EXCNO_UNDEF  = 0;     // 未定義命令
    pub const EXCNO_SVC    = 1;     // スーパバイザコール
    pub const EXCNO_PABORT = 2;     // プリフェッチアボート
    pub const EXCNO_DABORT = 3;     // データアボート
    pub const EXCNO_IRQ    = 4;     // IRQ割込み
    pub const EXCNO_FIQ    = 5;     // FIQ割込み
    pub const EXCNO_FATAL  = 6;     // フェイタルデータアボート

    ///
    ///  CPU例外の情報を記憶しているメモリ領域の構造
    ///
    pub const T_EXCINF = if (comptime !arm.isEnabled(arm.Feature.has_v6))
        struct {
            nest_count: u32,        // 例外ネストカウント
            intpri: u32,            // 割込み優先度マスク
            cpsr: u32,              // CPU例外発生時のCPSR
            r0: u32,
            r1: u32,
            r2: u32,
            r3: u32,
            r4: u32,
            r5: u32,
            r12: u32,
            lr: u32,
            pc: u32,                // 戻り番地
        }
    else
        struct {
            nest_count: u32,        // 例外ネストカウント
            intpri: u32,            // 割込み優先度マスク
            r0: u32,
            r1: u32,
            r2: u32,
            r3: u32,
            r4: u32,
            r5: u32,
            r12: u32,
            lr: u32,
            pc: u32,                // 戻り番地
            cpsr: u32,              // CPU例外発生時のCPSR
        };
};
