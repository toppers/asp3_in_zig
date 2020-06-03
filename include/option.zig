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
///  コンフィギュレーションオプション
///

///
///  コンパイルオプションによるマクロ定義の取り込み
///
const opt = @cImport({});
pub const TARGET = opt.TARGET;
pub const NDEBUG = @hasDecl(opt, "NDEBUG");
pub const SUPPORT_OVRHDR = @hasDecl(opt, "SUPPORT_OVRHDR");
pub const TOPPERS_OMIT_TECS = @hasDecl(opt, "TOPPERS_OMIT_TECS");
pub const BIND_CFG: ?[]const u8 =
    if (@hasDecl(opt, "BIND_CFG")) opt.BIND_CFG else null;
const TOPPERS_ENABLE_TRACE = @hasDecl(opt, "TOPPERS_ENABLE_TRACE");

///
///  トレースログ機能
///
pub const log = if (TOPPERS_ENABLE_TRACE)
        @import("../arch/tracelog/trace_option.zig")
    else struct {
        pub const TraceExportDefs = struct {};
    };

///
///  ターゲット依存部
///
pub const target = @import("../target/" ++ TARGET ++ "/target_option.zig");
