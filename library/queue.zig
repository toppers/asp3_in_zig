///
///  TOPPERS Software
///      Toyohashi Open Platform for Embedded Real-Time Systems
/// 
///  Copyright (C) 2000 by Embedded and Real-Time Systems Laboratory
///                                 Toyohashi Univ. of Technology, JAPAN
///  Copyright (C) 2006-2020 by Embedded and Real-Time Systems Laboratory
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
///  キュー操作ライブラリ
///
///  このキュー操作ライブラリでは，キューヘッダを含むリング構造のダブ
///  ルリンクキューを扱う．具体的には，キューヘッダの次エントリはキュー
///  の先頭のエントリ，前エントリはキューの末尾のエントリとする．また，
///  キューの先頭のエントリの前エントリと，キューの末尾のエントリの次
///  エントリは，キューヘッダとする．空のキューは，次エントリ，前エン
///  トリとも自分自身を指すキューヘッダであらわす．
///
const std = @import("std");
const assert = std.debug.assert;

///
///  ダブルリンクキューの構造体
///
pub const Queue = struct {
    p_next: *Queue,             // 次エントリへのポインタ
    p_prev: *Queue,             // 前エントリへのポインタ

    ///
    ///  キューの初期化
    ///
    ///  p_selfにはキューヘッダを指定する．
    ///
    pub fn initialize(p_self: *Queue) void {
        p_self.p_next = p_self;
        p_self.p_prev = p_self;
    }

    ///
    ///  キューの前エントリへの挿入
    ///
    ///  p_selfの前にp_entryを挿入する．p_selfにキューヘッダを指定した
    ///  場合には，キューの末尾にp_entryを挿入することになる．
    ///
    pub fn insertPrev(p_self: *Queue, p_entry: *Queue) void {
        p_entry.p_prev = p_self.p_prev;
        p_entry.p_next = p_self;
        p_self.p_prev.p_next = p_entry;
        p_self.p_prev = p_entry;
    }

    ///
    ///  キューの次エントリへの挿入
    ///
    ///  p_selfの次にp_entryを挿入する．p_selfにキューヘッダを指定した
    ///  場合には，キューの先頭にp_entryを挿入することになる．
    ///
    pub fn insertNext(p_self: *Queue, p_entry: *Queue) void {
        p_entry.p_prev = p_self;
        p_entry.p_next = p_self.p_next;
        p_self.p_next.p_prev = p_entry;
        p_self.p_next = p_entry;
    }

    ///
    ///  エントリの削除
    ///
    ///  p_entryをキューから削除する．
    ///
    pub fn delete(p_entry: *Queue) void {
        p_entry.p_prev.p_next = p_entry.p_next;
        p_entry.p_next.p_prev = p_entry.p_prev;
    }

    ///
    ///  キューの次エントリの取出し
    ///
    ///  p_selfの次エントリをキューから削除し，削除したエントリを返す．
    ///  p_selfにキューヘッダを指定した場合には，キューの先頭のエント
    ///  リを取り出すことになる．p_selfに空のキューを指定して呼び出し
    ///  てはならない．
    ///
    pub fn deleteNext(p_self: *Queue) *Queue {
        assert(!p_self.isEmpty());
        var p_entry: *Queue = p_self.p_next;
        p_self.p_next = p_entry.p_next;
        p_entry.p_next.p_prev = p_self;
        return p_entry;
    }

    ///
    ///  キューが空かどうかのチェック
    ///
    ///  p_selfにはキューヘッダを指定する．
    ///
    pub fn isEmpty(p_self: *const Queue) bool {
        if (p_self.p_next == p_self) {
            assert(p_self.p_prev == p_self);
            return true;
        }
        return false;
    }

    ///
    ///  キューの整合性検査
    ///
    ///  p_selfにp_entryが含まれているかを調べる．含まれていればtrue，
    ///  含まれていない場合にはfalseを返す．ダブルリンクの不整合の場合
    ///  にも，falseを返す．
    ///
    pub fn bitIncluded(p_self: *const Queue, p_entry: *const Queue) bool {
        var p_current = p_self.p_next;
        if (p_current.p_prev != p_self) {
            return false;               // ダブルリンクの不整合
        }
        while (p_current != p_self) {
            if (p_current == p_entry) {
                return true;            // p_entryが含まれていた
            }

            // キューの次の要素に進む
            const p_next = p_current.p_next;
            if (p_next.p_prev != p_current) {
                return false;           // ダブルリンクの不整合 */
            }
            p_current = p_next;
        }
        return(false);
    }
};
