///
///  TOPPERS/ASP Kernel
///      Toyohashi Open Platform for Embedded Real-Time Systems/
///      Advanced Standard Profile Kernel
/// 
///  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
///                                 Toyohashi Univ. of Technology, JAPAN
///  Copyright (C) 2005-2020 by Embedded and Real-Time Systems Laboratory
///                 Graduate School of Informatics, Nagoya Univ., JAPAN
///
///  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
///  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
///  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
///  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
///      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
///      スコード中に含まれていること．
///  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
///      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
///      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
///      の無保証規定を掲載すること．
///  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
///      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
///      と．
///    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
///        作権表示，この利用条件および下記の無保証規定を掲載すること．
///    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
///        報告すること．
///  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
///      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
///      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
///      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
///      免責すること．
///
///  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
///  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
///  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
///  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
///  の責任を負わない．
///
///  $Id$
///

/// 
///  タイマドライバ（MPCore内蔵タイマ用）
///
///  MPCoreは，プロセッサ毎にプライベートタイマとウォッチドッグを持つ．
///  ウォッチドッグは，タイマとして使用することができる．また，各プロ
///  セッサからアクセスできるグローバルタイマを持つ．このモジュールは，
///  以下の機能を提供する．
///
///  TMRWDG_HRT：
///		プライベートタイマとウォッチドッグを用いて，高分解能タイマを実
///		現する．具体的には，ウォッチドッグをタイマモードに設定して現在
///		時刻の管理のために用い，プライベートタイマを相対時間割込みの発
///		生のために用いる．
///
///  GTC_HRT：
///		グローバルタイマを用いて，高分解能タイマを実現する．グローバル
///		タイマは，Cortex-A9 MPCoreのr2p0以降の新しい仕様のものを想定し
///		ている．
///
///  WDG_OVRTIMER：
///		ウォッチドッグを用いて，オーバランタイマを実現する．
///
usingnamespace @import("../../../kernel/kernel_impl.zig");

///
///  コンフィギュレーションオプションの取り込み
///
const TOPPERS_USE_QEMU = option.target.TOPPERS_USE_QEMU;

///
///  ターゲット依存の定義の取り込み
///
const ARM_CA9_GTC_ERRATA = isTrue(target_impl, "ARM_CA9_GTC_ERRATA");

///
///  MPCoreのハードウェア資源の定義
///
const mpcore = @import("mpcore.zig");

///
///  プライベートタイマとウォッチドッグを用いて高分解能タイマを実現
///
const TMRWDG_HRT_PARAM = struct {
    ///
    ///  タイマの設定値とデフォルト定義
    ///
    // ウォッチドッグのリロード値
    WDG_LR_VALUE: u32 = 0xffffffff,

    // プライベートタイマのプリスケーラの設定値
    TMR_PS_VALUE: u32,

    // プライベートタイマの駆動周波数
    TMR_FREQ: u32 = 1,

    // ウォッチドッグのプリスケーラの設定値
    WDG_PS_VALUE: u32,

    // ウォッチドッグの駆動周波数
    WDG_FREQ: u32 = 1,
};

pub fn TMRWDG_HRT(param: TMRWDG_HRT_PARAM) type {
    return struct {
        ///
        ///  高分解能タイマ割込みハンドラ登録のための定数
        ///
        pub const INHNO_HRT = mpcore.IRQNO_TMR;     // 割込みハンドラ番号
        pub const INTNO_HRT = mpcore.IRQNO_TMR;     // 割込み番号
        pub const INTPRI_HRT = TMAX_INTPRI - 1;     // 割込み優先度
        pub const INTATR_HRT = TA_NULL;             // 割込み属性

        // HRTCNTとTCYC_HRTCNTの定義のチェック
        comptime {
            if (HRTCNT != u32) {
                @compileError("64bit HRTCNT is not supported.");
            }
            if (TCYC_HRTCNT != null) {
                @compileError("TCYC_HRTCNT must not be defined.");
            }
        }

        ///
        ///  タイマの起動処理
        ///
        pub fn initialize() void {
            // タイマとウォッチドッグを停止する．
            sil.wrw_mem(mpcore.TMR_CTRL, mpcore.TMR_CTRL_DISABLE);
            sil.wrw_mem(mpcore.WDG_CTRL, mpcore.WDG_CTRL_DISABLE);

            // ウォッチドッグをタイマモードに設定する．
            sil.wrw_mem(mpcore.WDG_DIS, 0x12345678);
            sil.wrw_mem(mpcore.WDG_DIS, 0x87654321);
            sil.wrw_mem(mpcore.WDG_CTRL, mpcore.WDG_CTRL_DISABLE);

            // ウォッチドッグのリロード値を設定し，動作を開始する．
            sil.wrw_mem(mpcore.WDG_LR, param.WDG_LR_VALUE);
            sil.wrw_mem(mpcore.WDG_CTRL,
                        mpcore.WDG_CTRL_ENABLE | mpcore.WDG_CTRL_AUTORELOAD
                            | (param.WDG_PS_VALUE << mpcore.WDG_CTRL_PS_SHIFT));

            // タイマのカウント値を0（カウントダウンして停止した状態）に設
            // 定し，動作を開始する．
            sil.wrw_mem(mpcore.TMR_CNT, 0);
            sil.wrw_mem(mpcore.TMR_CTRL,
                        mpcore.TMR_CTRL_ENABLE | mpcore.TMR_CTRL_ENAINT
                            | (param.TMR_PS_VALUE << mpcore.TMR_CTRL_PS_SHIFT));

            // タイマ割込み要求をクリアする．
            sil.wrw_mem(mpcore.TMR_ISR, mpcore.TMR_ISR_EVENTFLAG);
            if (TOPPERS_USE_QEMU) {
                target_impl.clearInt(mpcore.IRQNO_TMR);
            }
        }

        ///
        ///  タイマの停止処理
        ///
        pub fn terminate() void {
            // タイマとウォッチドッグを停止する．
            sil.wrw_mem(mpcore.TMR_CTRL, mpcore.TMR_CTRL_DISABLE);
            sil.wrw_mem(mpcore.WDG_CTRL, mpcore.WDG_CTRL_DISABLE);

            // タイマ割込み要求をクリアする．
            sil.wrw_mem(mpcore.TMR_ISR, mpcore.TMR_ISR_EVENTFLAG);
            if (TOPPERS_USE_QEMU) {
                target_impl.clearInt(mpcore.IRQNO_TMR);
            }
        }

        ///
        ///  高分解能タイマの現在のカウント値の読出し
        ///
        pub fn get_current() HRTCNT {
            // ウォッチドッグのカウント値を読み出し，ダウンカウンタである
            // ため，WDG_LR_VALUEから引き，WDG_FREQで除した値を返す．
            return @intCast(HRTCNT,
                            (param.WDG_LR_VALUE - sil.rew_mem(mpcore.WDG_CNT))
                                / param.WDG_FREQ);
        }

        ///
        ///  高分解能タイマへの割込みタイミングの設定
        ///
        pub fn set_event(hrtcnt: HRTCNT) void {
            // タイマのカウント値を(hrtcnt * TMR_FREQ)に設定する．
            sil.wrw_mem(mpcore.TMR_CNT, hrtcnt * param.TMR_FREQ);
        }

        ///
        ///  高分解能タイマ割込みの要求
        ///
        pub fn raise_event() void {
            target_impl.raiseInt(mpcore.IRQNO_TMR);
        }

        ///
        ///  タイマ割込みハンドラ
        ///
        pub fn handler() void {
            // タイマ割込み要求をクリアする．
            sil.wrw_mem(mpcore.TMR_ISR, mpcore.TMR_ISR_EVENTFLAG);
            if (TOPPERS_USE_QEMU) {
                target_impl.clearInt(mpcore.IRQNO_TMR);
            }

            // 高分解能タイマ割込みを処理する．
            time_event.signal_time();
        }

        ///
        ///  割込みタイミングに指定する最大値
        ///
        pub const HRTCNT_BOUND = 4_000_000_002;
    };
}

///
///  グローバルタイマを用いて高分解能タイマを実現
///
const GTC_HRT_PARAM = struct {
    ///
    ///  タイマの設定値とデフォルト定義
    ///
    // グローバルタイマのプリスケーラの設定値
    GTC_PS_VALUE: u32,

    // グローバルタイマの駆動周波数
    GTC_FREQ: u32 = 1,
};

pub fn GTC_HRT(param: GTC_HRT_PARAM) type {
    return struct {
        ///
        ///  高分解能タイマ割込みハンドラ登録のための定数
        ///
        pub const INHNO_HRT = mpcore.IRQNO_GTC;     // 割込みハンドラ番号
        pub const INTNO_HRT = mpcore.IRQNO_GTC;     // 割込み番号
        pub const INTPRI_HRT = TMAX_INTPRI - 1;     // 割込み優先度
        pub const INTATR_HRT = TA_NULL;             // 割込み属性

        // TCYC_HRTCNTの定義のチェック
        comptime {
            if (TCYC_HRTCNT != null) {
                @compileError("TCYC_HRTCNT must not be defined.");
            }
        }

        ///
        ///  グローバルタイマの現在のカウント値（64bit）の読出し
        ///
        fn get_count() u64 {
            var count_l: u32 = undefined;
            var count_u: u32 = undefined;
            var prev_count_u: u32 = undefined;

            count_u = sil.rew_mem(mpcore.GTC_COUNT_U);
            while (true) {
                prev_count_u = count_u;
                count_l = sil.rew_mem(mpcore.GTC_COUNT_L);
                count_u = sil.rew_mem(mpcore.GTC_COUNT_U);
                if (count_u == prev_count_u) break;
            }
            return (@intCast(u64, count_u) << 32) | @intCast(u64, count_l);
        }

        ///
        ///  グローバルタイマのコンパレータ値（64bit）の設定
        ///
        fn gtc_set_cvr(cvr: u64) void {
            var cvr_l: u32 = undefined;
            var cvr_u: u32 = undefined;
            var reg: u32 = undefined;

            cvr_l = @truncate(u32, cvr);
            cvr_u = @intCast(u32, cvr >> 32);

            // コンパレータをディスエーブル
            reg = sil.rew_mem(mpcore.GTC_CTRL);
            sil.wrw_mem(mpcore.GTC_CTRL,
                        reg & ~@as(u32, mpcore.GTC_CTRL_ENACOMP));

            // コンパレータ値を設定
            sil.wrw_mem(mpcore.GTC_CVR_L, cvr_l);
            sil.wrw_mem(mpcore.GTC_CVR_U, cvr_u);

            if (ARM_CA9_GTC_ERRATA) {
                // ARM Cortex-A9 Errata 740657への対策
                sil.wrw_mem(mpcore.GTC_ISR, mpcore.GTC_ISR_EVENTFLAG);
                target_impl.clearInt(mpcore.IRQNO_GTC);
            }

            // コンパレータと割込みをイネーブル
            sil.wrw_mem(mpcore.GTC_CTRL,
                        reg | (mpcore.GTC_CTRL_ENACOMP|mpcore.GTC_CTRL_ENAINT));
        }

        ///
        ///  タイマの起動処理
        ///
        pub fn initialize() void {
            // タイマをディスエーブルする．
            sil.wrw_mem(mpcore.GTC_CTRL, mpcore.GTC_CTRL_DISABLE);

            // カウンタを0に初期化する（セキュアモードでないと効果がない）．
            sil.wrw_mem(mpcore.GTC_COUNT_L, 0);
            sil.wrw_mem(mpcore.GTC_COUNT_U, 0);

            // タイマの動作を開始する（コンパレータと割込みはディスエーブル）．
            sil.wrw_mem(mpcore.GTC_CTRL,
                        mpcore.GTC_CTRL_ENABLE
                            | (param.GTC_PS_VALUE << mpcore.GTC_CTRL_PS_SHIFT));

            // タイマ割込み要求をクリアする．
            sil.wrw_mem(mpcore.GTC_ISR, mpcore.GTC_ISR_EVENTFLAG);
        }

        ///
        ///  タイマの停止処理
        ///
        pub fn terminate() void {
            // タイマを停止する．
            sil.wrw_mem(mpcore.GTC_CTRL, mpcore.GTC_CTRL_DISABLE);

            // タイマ割込み要求をクリアする．
            sil.wrw_mem(mpcore.GTC_ISR, mpcore.GTC_ISR_EVENTFLAG);
        }

        ///
        ///  高分解能タイマの現在のカウント値の読出し
        ///
        pub fn get_current() HRTCNT {
            // グローバルタイマのカウント値（64ビット）を読み出し，
            // mpcore.GTC_FREQで除し，HRTCNTのビット数に切り詰めた値を返す．
            return(@truncate(HRTCNT, get_count() / param.GTC_FREQ));
        }

        ///
        ///  高分解能タイマへの割込みタイミングの設定
        ///
        ///  高分解能タイマを，hrtcntで指定した値カウントアップしたら割込
        ///  みを発生させるように設定する．
        ///
        pub fn set_event(hrtcnt: HRTCNT) void {
            // コンパレータ値を，(現在のカウント値＋hrtcnt×mpcore.GTC_FREQ)
            // に設定し，コンパレータと割込みをイネーブルする．
            return gtc_set_cvr(get_count()
                                   + @intCast(u64, hrtcnt) * param.GTC_FREQ);
        }
        
        ///
        ///  高分解能タイマへの割込みタイミングのクリア
        ///
        pub fn clear_event() void {
            sil.wrw_mem(mpcore.GTC_CTRL, sil.rew_mem(mpcore.GTC_CTRL)
                            & ~@as(u32, mpcore.GTC_CTRL_ENACOMP));
            if (ARM_CA9_GTC_ERRATA) {
                // ARM Cortex-A9 Errata 740657への対策
                sil.wrw_mem(mpcore.GTC_ISR, mpcore.GTC_ISR_EVENTFLAG);
                target_impl.clearInt(mpcore.IRQNO_GTC);
            }
        }

        ///
        ///  高分解能タイマ割込みの要求
        ///
        pub fn raise_event() void {
            target_impl.raiseInt(mpcore.IRQNO_GTC);
        }

        ///
        ///  タイマ割込みハンドラ
        ///
        pub fn handler() void {
            // タイマ割込み要求をクリアする．
            sil.wrw_mem(mpcore.GTC_ISR, mpcore.GTC_ISR_EVENTFLAG);

            // 高分解能タイマ割込みを処理する．
            time_event.signal_time();
        }

        ///
        ///  割込みタイミングに指定する最大値
        ///
        pub const HRTCNT_BOUND: ?comptime_int =
            if (HRTCNT == u64) null else 4_000_000_002;
    };
}

///
///  ウォッチドッグタイマを用いてオーバランタイマを実現
///
const WDG_OVRTIMER_PARAM = struct {
    ///
    ///  タイマの設定値とデフォルト定義
    ///
    // ウォッチドッグのプリスケーラの設定値
    WDG_PS_VALUE: u32,

    // ウォッチドッグの駆動周波数
    WDG_FREQ: u32 = 1,
};

pub fn WDG_OVRTIMER(param: WDG_OVRTIMER_PARAM) type {
    return struct {
        ///
        ///  オーバランタイマ割込みハンドラ登録のための定数
        ///
        pub const INHNO_OVRTIMER  = mpcore.IRQNO_WDG;   // 割込みハンドラ番号
        pub const INTNO_OVRTIMER  = mpcore.IRQNO_WDG;   // 割込み番号
        pub const INTPRI_OVRTIMER = TMAX_INTPRI;        // 割込み優先度
        pub const INTATR_OVRTIMER = TA_NULL;            // 割込み属性

        ///
        ///  オーバランタイマの初期化処理
        ///
        pub fn initialize() void {
            // ウォッチドッグを停止する．
            sil.wrw_mem(mpcore.WDG_CTRL, mpcore.WDG_CTRL_DISABLE);

            // ウォッチドッグをタイマモードに設定する．
            sil.wrw_mem(mpcore.WDG_DIS, 0x12345678);
            sil.wrw_mem(mpcore.WDG_DIS, 0x87654321);

            // ウォッチドッグタイマを停止した状態で設定する．
            sil.wrw_mem(mpcore.WDG_CTRL,
                        mpcore.WDG_CTRL_ENAINT
                            | (param.WDG_PS_VALUE << mpcore.WDG_CTRL_PS_SHIFT));

            // ウォッチドッグ割込み要求をクリアする．
            sil.wrw_mem(mpcore.WDG_ISR, mpcore.WDG_ISR_EVENTFLAG);
        }

        ///
        ///  オーバランタイマの終了処理
        ///
        pub fn terminate() void {
            // ウォッチドッグを停止する．
            sil.wrw_mem(mpcore.WDG_CTRL, mpcore.WDG_CTRL_DISABLE);

            // ウォッチドッグ割込み要求をクリアする．
            sil.wrw_mem(mpcore.WDG_ISR, mpcore.WDG_ISR_EVENTFLAG);
        }

        ///
        ///  オーバランタイマの動作開始
        ///
        pub fn start(ovrtim: PRCTIM) void {
            // ウォッチドッグのカウント値を(ovrtim * param.WDG_FREQ)に
            // 設定する．
            sil.wrw_mem(mpcore.WDG_CNT, ovrtim * param.WDG_FREQ);

            // ウォッチドッグの動作を開始する．
            sil.wrw_mem(mpcore.WDG_CTRL,
                        sil.rew_mem(mpcore.WDG_CTRL) | mpcore.WDG_CTRL_ENABLE);
        }

        ///
        ///  オーバランタイマの停止
        ///
        pub fn stop() PRCTIM {
            // ウォッチドッグの現在値の読出し
            const ovrtim = @intCast(PRCTIM, sil.rew_mem(mpcore.WDG_CNT)
                                            / param.WDG_FREQ);

            // ウォッチドッグを停止する．
            sil.wrw_mem(mpcore.WDG_CTRL, sil.rew_mem(mpcore.WDG_CTRL)
                            & ~@as(u32, mpcore.WDG_CTRL_ENABLE));
            return ovrtim;
        }

        ///
        ///  オーバランタイマの現在値の読出し
        ///
        pub fn get_current() PRCTIM {
            // ウォッチドッグのカウント値を読み出し，mpcore.WDG_FREQで除し
            // た値を返す．
            return @intCast(PRCTIM, sil.rew_mem(mpcore.WDG_CNT)
                                    / param.WDG_FREQ);
        }

        ///
        ///  オーバランタイマ割込みハンドラ
        ///
        pub fn handler() void {
            // ウォッチドッグ割込み要求をクリアする．
            sil.wrw_mem(mpcore.WDG_ISR, mpcore.WDG_ISR_EVENTFLAG);

            // オーバランハンドラの起動処理をする．
            overrun.call_ovrhdr();
        }
    };
}
