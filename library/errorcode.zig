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

///
///  ItronError型のエラーをC言語APIのエラーコードに変換する関数
///
usingnamespace @import("../include/t_stddef.zig");

///
///  C言語ヘッダファイルの取り込み
///
pub const c = @cImport({
    @cDefine("UINT_C(val)", "val");
    @cInclude("kernel.h");
});

///
///  C言語APIのエラーコードへの変換
///
//  コードサイズの評価を行うために，エラーコードの変換をやめる場合には，
//  以下のコードを用いる．
//
// pub fn itronErrorCode(err: ItronError) ER {
//    return -@intCast(ER, @errorToInt(err));
// }
pub noinline fn itronErrorCode(err: ItronError) ER {
    return switch (err) {
        ItronError.SystemError => c.E_SYS,
        ItronError.NotSupported => c.E_NOSPT,
        ItronError.ReservedFunction => c.E_RSFN,
        ItronError.ReservedAttribute => c.E_RSATR,
        ItronError.ParameterError => c.E_PAR,
        ItronError.IdError => c.E_ID,
        ItronError.ContextError => c.E_CTX,
        ItronError.MemoryAccessViolation => c.E_MACV,
        ItronError.ObjectAccessViolation => c.E_OACV,
        ItronError.IllegalUse => c.E_ILUSE,
        ItronError.NoMemory => c.E_NOMEM,
        ItronError.NoId => c.E_NOID,
        ItronError.NoResource => c.E_NORES,
        ItronError.ObjectStateError => c.E_OBJ,
        ItronError.NonExistent => c.E_NOEXS,
        ItronError.QueueingOverflow => c.E_QOVR,
        ItronError.ReleasedFromWaiting => c.E_RLWAI,
        ItronError.TimeoutError => c.E_TMOUT,
        ItronError.ObjectDeleted => c.E_DLT,
        ItronError.ConnectionClosed => c.E_CLS,
        ItronError.TerminationRequestRaised => c.E_RASTER,
        ItronError.WouldBlock => c.E_WBLK,
        ItronError.BufferOverflow => c.E_BOVR,
        ItronError.CommunicationError => c.E_COMM,
    };
}
