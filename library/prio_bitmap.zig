///
///  TOPPERS Software
///      Toyohashi Open Platform for Embedded Real-Time Systems
/// 
///  Copyright (C) 2020 by Embedded and Real-Time Systems Laboratory
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

//
//  優先度ビットマップライブラリ
//
const std = @import("std");
const assert = std.debug.assert;

/// 優先度の段階数が level の時の優先度のビット長
fn bitSizeOfPrio(comptime level: comptime_int) comptime_int {
   return std.math.log2_int_ceil(u16, level);
}

/// 優先度の段階数が level の時の優先度のデータ型
pub fn PrioType(comptime level: comptime_int) type {
    return std.meta.IntType(false, bitSizeOfPrio(level));
}

/// 優先度の段階数が level の時のビットマップのデータ型
fn BitmapType(comptime level: comptime_int) type {
    return std.meta.IntType(false, level);
}

/// 1段のビットマップでの実装
fn OneLevelBitmap(comptime level: comptime_int) type {
    const Prio = PrioType(level);
    const Bitmap = BitmapType(level);

    return struct {
        bitmap: Bitmap,

        /// 優先度ビットマップの初期化
        pub fn initialize(p_self: *@This()) void {
            p_self.bitmap = 0;
        }

        /// 優先度ビットマップのセット
        pub fn set(p_self: *@This(), prio: Prio) void {
            assert(prio < level);
            p_self.bitmap |= (@as(Bitmap, 1) << prio);
        }

        /// 優先度ビットマップのクリア
        pub fn clear(p_self: *@This(), prio: Prio) void {
            assert(prio < level);
            p_self.bitmap &= ~(@as(Bitmap, 1) << prio);
        }

        /// 優先度ビットマップがセットされているかのチェック
        pub fn isSet(self: @This(), prio: Prio) bool {
            assert(prio < level);
            return (self.bitmap & (@as(Bitmap, 1) << prio)) != 0;
        }

        /// 優先度ビットマップが空かのチェック
        pub fn isEmpty(self: @This()) bool {
            return self.bitmap == 0;
        }

        /// 優先度ビットマップのサーチ
        pub fn search(self: @This()) Prio {
            assert(self.bitmap != 0);
            return @intCast(Prio, @ctz(Bitmap, self.bitmap));
        }

        /// 優先度ビットマップの整合性検査
        pub fn bitCheck(self: @This()) bool {
            return (self.bitmap & ~@as(Bitmap, (1 << level) - 1)) == 0;
        }
    };
}

/// 2段のビットマップでの実装
fn TwoLevelBitmap(comptime level: comptime_int) type {
    const Prio = PrioType(level);
    const upper_level = (level + 31) / 32;
    const UpperPrio = PrioType(upper_level);
    const LowerPrio = PrioType(32);

    return struct {
        upper_bitmap: OneLevelBitmap(upper_level),
        lower_bitmap: [upper_level]OneLevelBitmap(32),

        /// 優先度ビットマップの初期化
        pub fn initialize(p_self: *@This()) void {
            p_self.upper_bitmap.initialize();
            for (p_self.lower_bitmap) |*bitmap| {
                bitmap.bitmap = 0;
            }
        }

        /// 優先度ビットマップのセット
        pub fn set(p_self: *@This(), prio: Prio) void {
            assert(prio < level);
            p_self.lower_bitmap[prio / 32].set(@intCast(LowerPrio, prio % 32));
            p_self.upper_bitmap.set(@intCast(UpperPrio, prio / 32));
        }

        /// 優先度ビットマップのクリア
        pub fn clear(p_self: *@This(), prio: Prio) void {
            assert(prio < level);
            p_self.lower_bitmap[prio / 32].clear(@intCast(LowerPrio,
                                                          prio % 32));
            if (p_self.lower_bitmap[prio / 32].bitmap == 0) {
                p_self.upper_bitmap.clear(@intCast(UpperPrio, prio / 32));
            }
        }

        /// 優先度ビットマップが空かのチェック
        pub fn isEmpty(self: @This()) bool {
            return self.upper_bitmap.isEmpty();
        }

        /// 優先度ビットマップのサーチ
        pub fn search(self: @This()) Prio {
            const upper_prio: Prio = self.upper_bitmap.search();
            return upper_prio * 32 + self.lower_bitmap[upper_prio].search();
        }

        /// 優先度ビットマップの整合性検査
        pub fn bitCheck(self: @This()) bool {
            if (!self.upper_bitmap.bitCheck()) {
                return false;
            }
            if (self.lower_bitmap[(level - 1) / 32].bitmap
                    & ~@as(BitmapType(32),
                           (1 << ((level - 1) % 32 + 1)) - 1) != 0) {
                return false;
            }

            // upper_bitmapとlower_bitmapの整合性の検査
            for (self.lower_bitmap) |*bitmap, upper_prio| {
                if (bitmap.bitmap == 0) {
                    if (self.upper_bitmap.isSet(@intCast(UpperPrio,
                                                         upper_prio))) {
                        return false;
                    }
                }
                else {
                    if (!self.upper_bitmap.isSet(@intCast(UpperPrio,
                                                          upper_prio))) {
                        return false;
                    }
                }
            }
            return true;
        }
    };
}

/// 優先度ビットマップ
pub fn PrioBitmap(comptime level: comptime_int) type {
    if (level <= 1) {
        @compileError("priority level must be larger than 1.");
    }
    else if (level <= 32) {
        // 32レベル以下の場合は1段のビットマップで実装
        return OneLevelBitmap(level);
    }
    else if (level <= 1024) {
        // 1024レベル以下の場合は2段のビットマップで実装
        return TwoLevelBitmap(level);
    }
    else {
        @compileError("unsuppored priority levels.");
    }
}

test "16-level priority bitmap test" {
    var primap: PrioBitmap(16) = undefined;

    primap.initialize();
    assert(primap.isEmpty());

    primap.set(1);
    assert(primap.bitmap == 0b10);
    assert(primap.search() == 1);

    primap.set(1);
    primap.set(2);
    assert(primap.bitmap == 0b110);
    assert(primap.search() == 1);

    primap.set(4);
    assert(primap.bitmap == 0b10110);
    assert(primap.search() == 1);

    primap.clear(2);
    assert(primap.bitmap == 0b10010);
    assert(primap.search() == 1);

    primap.clear(1);
    assert(primap.bitmap == 0b10000);
    assert(primap.search() == 4);
    assert(primap.bitCheck());
}

test "256-level priority bitmap test" {
    var primap: PrioBitmap(256) = undefined;

    primap.initialize();
    assert(primap.isEmpty());

    primap.set(10);
    assert(primap.search() == 10);

    primap.set(10);
    primap.set(20);
    assert(primap.search() == 10);

    primap.set(40);
    assert(primap.search() == 10);

    primap.clear(20);
    assert(primap.search() == 10);

    primap.clear(10);
    primap.clear(20);
    assert(primap.search() == 40);
    assert(primap.bitCheck());
}

test "200-level priority bitmap test" {
    var primap: PrioBitmap(200) = undefined;

    primap.initialize();
    assert(primap.isEmpty());

    primap.set(10);
    assert(primap.search() == 10);

    primap.set(10);
    primap.set(20);
    assert(primap.search() == 10);

    primap.set(199);
    assert(primap.search() == 10);

    primap.clear(20);
    assert(primap.search() == 10);

    primap.clear(10);
    primap.clear(20);
    assert(primap.search() == 199);
    assert(primap.bitCheck());

    // 200 = 32 * 6 + 8
    primap.upper_bitmap.bitmap |= 1;
    assert(!primap.bitCheck());
    primap.upper_bitmap.bitmap &= ~@as(BitmapType(7), 1);

    primap.lower_bitmap[0].bitmap |= 1;
    assert(!primap.bitCheck());
    primap.lower_bitmap[0].bitmap &= ~@as(BitmapType(32), 1);

    primap.lower_bitmap[6].bitmap |= (1 << 8);
    assert(!primap.bitCheck());
    primap.lower_bitmap[0].bitmap &= ~@as(BitmapType(32), 1 << 8);
}
