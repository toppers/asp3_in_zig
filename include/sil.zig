///
///  TOPPERS Software
///      Toyohashi Open Platform for Embedded Real-Time Systems
/// 
///  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
///                                 Toyohashi Univ. of Technology, JAPAN
///  Copyright (C) 2004-2020 by Embedded and Real-Time Systems Laboratory
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
///  システムインタフェースレイヤ
///

///
///  コンフィギュレーションオプションの取り込み
///
const option = @import("../include/option.zig");

///
///  Zigの標準ライブラリ
///
const builtin = @import("builtin");
const endian = builtin.endian;
const Endian = builtin.Endian;

///
///  ターゲット依存部
///
const target = @import("../target/" ++ option.TARGET ++ "/target_sil.zig");

///
///  全割込みロック状態の制御
///
pub const PRE_LOC = target.PRE_LOC;
pub const LOC_INT = target.LOC_INT;
pub const UNL_INT = target.UNL_INT;

///
///  微少時間待ち
///
pub const dly_nse = target.dly_nse;

///
///  メモリ空間アクセス関数
///

///
///  指定された型の単位の読出し／書込み
///
fn readMemory(comptime T: type, mem: *const T) T {
    return @ptrCast(*const volatile T, mem).*;
}

fn writeMemory(comptime T: type, mem: *T, data: T) void {
    @ptrCast(*volatile T, mem).* = data;
}

///
///  8ビット単位の読出し／書込み
///
pub fn reb_mem(mem: *const u8) u8 {
    if (@hasDecl(target, "reb_mem")) {
        return target.reb_mem(mem);
    }
    else {
        return readMemory(u8, mem);
    }
}

pub fn wrb_mem(mem: *u8, data: u8) void {
    if (@hasDecl(target, "wrb_mem")) {
        target.wrb_mem(mem, data);
    }
    else {
        writeMemory(u8, mem, data);
    }
}

///
///  16ビット単位の読出し／書込み
///
pub fn reh_mem(mem: *const u16) u16 {
    if (@hasDecl(target, "reh_mem")) {
        return target.reh_mem(mem);
    }
    else {
        return readMemory(u16, mem);
    }
}

pub fn wrh_mem(mem: *u16, data: u16) void {
    if (@hasDecl(target, "wrh_mem")) {
        target.wrh_mem(mem, data);
    }
    else {
        writeMemory(u16, mem, data);
    }
}

pub fn reh_bem(mem: *const u16) u16 {
    if (@hasDecl(target, "reh_bem")) {
        return target.reh_bem(mem);
    }
    else {
        return switch (endian) {
            Endian.Big => readMemory(u16, mem),
            Endian.Little => @byteSwap(u16, readMemory(u16, mem)),
        };
    }
}

pub fn wrh_bem(mem: *u16, data: u16) void {
    if (@hasDecl(target, "wrh_bem")) {
        target.wrh_bem(mem, data);
    }
    else {
        switch (endian) {
            Endian.Big => writeMemory(u16, mem, data),
            Endian.Little => writeMemory(u16, mem, @byteSwap(u16, data)),
        }
    }
}

pub fn reh_lem(mem: *const u16) u16 {
    if (@hasDecl(target, "reh_lem")) {
        return target.reh_lem(mem);
    }
    else {
        return switch (endian) {
            Endian.Big => @byteSwap(u16, readMemory(u16, mem)),
            Endian.Little => readMemory(u16, mem),
        };
    }
}

pub fn wrh_lem(mem: *u16, data: u16) void {
    if (@hasDecl(target, "wrh_lem")) {
        target.wrh_lem(mem, data);
    }
    else {
        switch (endian) {
            Endian.Big => writeMemory(u16, mem, @byteSwap(u16, data)),
            Endian.Little => writeMemory(u16, mem, data),
        }
    }
}

///
///  32ビット単位の読出し／書込み
///
pub fn rew_mem(mem: *const u32) u32 {
    if (@hasDecl(target, "rew_mem")) {
        return target.rew_mem(mem);
    }
    else {
        return readMemory(u32, mem);
    }
}

pub fn wrw_mem(mem: *u32, data: u32) void {
    if (@hasDecl(target, "wrw_mem")) {
        target.wrw_mem(mem, data);
    }
    else {
        writeMemory(u32, mem, data);
    }
}

pub fn rew_bem(mem: *const u32) u32 {
    if (@hasDecl(target, "rew_bem")) {
        return target.rew_bem(mem);
    }
    else {
        return switch (endian) {
            Endian.Big => readMemory(u32, mem),
            Endian.Little => @byteSwap(u32, readMemory(u32, mem)),
        };
    }
}

pub fn wrw_bem(mem: *u32, data: u32) void {
    if (@hasDecl(target, "wrw_bem")) {
        target.wrw_bem(mem, data);
    }
    else {
        switch (endian) {
            Endian.Big => writeMemory(u32, mem, data),
            Endian.Little => writeMemory(u32, mem, @byteSwap(u32, data)),
        }
    }
}

pub fn rew_lem(mem: *const u32) u32 {
    if (@hasDecl(target, "rew_lem")) {
        return target.rew_lem(mem);
    }
    else {
        return switch (endian) {
            Endian.Big => @byteSwap(u32, readMemory(u32, mem)),
            Endian.Little => readMemory(u32, mem),
        };
    }
}

pub fn wrw_lem(mem: *u32, data: u32) void {
    if (@hasDecl(target, "wrw_lem")) {
        target.wrw_lem(mem, data);
    }
    else {
        switch (endian) {
            Endian.Big => writeMemory(u32, mem, @byteSwap(u32, data)),
            Endian.Little => writeMemory(u32, mem, data),
        }
    }
}

///
///  8ビット単位の同期書込み
///
pub fn swrb_mem(mem: *u8, data: u8) void {
    if (@hasDecl(target, "swrb_mem")) {
        target.swrb_mem(mem, data);
    }
    else {
        wrb_mem(mem, data);
        target.write_sync();
    }
}

///
///  16ビット単位の同期書込み
///
pub fn swrh_mem(mem: *u16, data: u16) void {
    if (@hasDecl(target, "swrh_mem")) {
        target.swrh_mem(mem, data);
    }
    else {
        wrh_mem(mem, data);
        target.write_sync();
    }
}

pub fn swrh_bem(mem: *u16, data: u16) void {
    if (@hasDecl(target, "swrh_bem")) {
        target.swrh_bem(mem, data);
    }
    else {
        wrh_bem(mem, data);
        target.write_sync();
    }
}

pub fn swrh_lem(mem: *u16, data: u16) void {
    if (@hasDecl(target, "swrh_lem")) {
        target.swrh_lem(mem, data);
    }
    else {
        wrh_lem(mem, data);
        target.write_sync();
    }
}

///
///  32ビット単位の同期書込み
///
pub fn swrw_mem(mem: *u32, data: u32) void {
    if (@hasDecl(target, "swrw_mem")) {
        target.swrw_mem(mem, data);
    }
    else {
        wrw_mem(mem, data);
        target.write_sync();
    }
}

pub fn swrw_bem(mem: *u32, data: u32) void {
    if (@hasDecl(target, "swrw_bem")) {
        target.swrw_bem(mem, data);
    }
    else {
        wrw_bem(mem, data);
        target.write_sync();
    }
}

pub fn swrw_lem(mem: *u32, data: u32) void {
    if (@hasDecl(target, "swrw_lem")) {
        target.swrw_lem(mem, data);
    }
    else {
        wrw_lem(mem, data);
        target.write_sync();
    }
}
