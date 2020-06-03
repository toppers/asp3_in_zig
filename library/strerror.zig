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
///  エラーメッセージ文字列を返す関数
///
usingnamespace @import("../include/t_stddef.zig");

pub fn itronErrorString(err: ?ItronError) []const u8 {
    if (err) |ercd| {
        return switch (ercd) {
            ItronError.SystemError => "E_SYS",
            ItronError.NotSupported => "E_NOSPT",
            ItronError.ReservedFunction => "E_RSFN",
            ItronError.ReservedAttribute => "E_RSATR",
            ItronError.ParameterError => "E_PAR",
            ItronError.IdError => "E_ID",
            ItronError.ContextError => "E_CTX",
            ItronError.MemoryAccessViolation => "E_MACV",
            ItronError.ObjectAccessViolation => "E_OACV",
            ItronError.IllegalUse => "E_ILUSE",
            ItronError.NoMemory => "E_NOMEM",
            ItronError.NoId => "E_NOID",
            ItronError.NoResource => "E_NORES",
            ItronError.ObjectStateError => "E_OBJ",
            ItronError.NonExistent => "E_NOEXS",
            ItronError.QueueingOverflow => "E_QOVR",
            ItronError.ReleasedFromWaiting => "E_RELWAI",
            ItronError.TimeoutError => "E_TMOUT",
            ItronError.ObjectDeleted => "E_DLT",
            ItronError.ConnectionClosed => "E_CLS",
            ItronError.TerminationRequestRaised => "E_RASTER",
            ItronError.WouldBlock => "E_WBLK",
            ItronError.BufferOverflow => "E_BOVR",
            ItronError.CommunicationError => "E_COMM",
        };
    }
    else {
        return "E_OK";
    }
}
