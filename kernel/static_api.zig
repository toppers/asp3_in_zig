///
///  静的APIの処理
///
const std = @import("std");
usingnamespace @import("kernel_impl.zig");

///
///  コンパイルオプションによるマクロ定義の取り込み
///
const opt = @cImport({});
const USE_EXTERNAL_ID = @hasDecl(opt, "USE_EXTERNAL_ID");

///
///  使用するライブラリ
///
const strerror = @import("../library/strerror.zig");

///
///  静的APIのエラーの報告
///
fn reportError(comptime api: []const u8, comptime err: ItronError) noreturn {
  @compileError(api ++ " returns " ++ strerror.itronErrorString(err) ++ ".");
}

///
///  タスクのコンフィギュレーションデータ
///
const T_TSK = struct {
    name: []const u8,
    inib: task.TINIB,
    p_next: ?*T_TSK,
};

///
///  セマフォのコンフィギュレーションデータ
///
const T_SEM = struct {
    name: []const u8,
    inib: semaphore.SEMINIB,
    p_next: ?*T_SEM,
};

///
///  イベントフラグのコンフィギュレーションデータ
///
const T_FLG = struct {
    name: []const u8,
    inib: eventflag.FLGINIB,
    p_next: ?*T_FLG,
};

///
///  データキューのコンフィギュレーションデータ
///
const T_DTQ = struct {
    name: []const u8,
    inib: dataqueue.DTQINIB,
    p_next: ?*T_DTQ,
};

///
///  優先度データキューのコンフィギュレーションデータ
///
const T_PDQ = struct {
    name: []const u8,
    inib: pridataq.PDQINIB,
    p_next: ?*T_PDQ,
};

///
///  ミューテックスのコンフィギュレーションデータ
///
const T_MTX = struct {
    name: []const u8,
    inib: mutex.MTXINIB,
    p_next: ?*T_MTX,
};

///
///  固定長メモリプールのコンフィギュレーションデータ
///
const T_MPF = struct {
    name: []const u8,
    inib: mempfix.MPFINIB,
    p_next: ?*T_MPF,
};

///
///  周期通知のコンフィギュレーションデータ
///
const T_CYC = struct {
    name: []const u8,
    inib: cyclic.CYCINIB,
    p_next: ?*T_CYC,
};

///
///  アラーム通知のコンフィギュレーションデータ
///
const T_ALM = struct {
    name: []const u8,
    inib: alarm.ALMINIB,
    p_next: ?*T_ALM,
};

///
///  オーバランハンドラのコンフィギュレーションデータ
///
const T_OVR = struct {
    inib: overrun.OVRINIB,
};

///
///  割込み要求ラインのコンフィギュレーションデータ
///
const T_INT = struct {
    inib: interrupt.INTINIB,
    p_next: ?*T_INT,
};

///
///  割込みハンドラのコンフィギュレーションデータ
///
const T_INH = struct {
    inib: interrupt.INHINIB,
    p_next: ?*T_INH,
};

///
///  割込みサービスルーチンのコンフィギュレーションデータ
///
const T_ISR = struct {
    name: []const u8,
    cfg: interrupt.ISRCFG,
    p_next: ?*T_ISR,
};

///
///  CPU例外ハンドラのコンフィギュレーションデータ
///
const T_EXC = struct {
    inib: exception.EXCINIB,
    p_next: ?*T_EXC,
};

///
///  非タスクコンテキスト用のスタック領域のコンフィギュレーションデータ
///
const T_ICS = struct {
    dics: T_DICS,
};

///
///  初期化ルーチンのコンフィギュレーションデータ
///
const T_INIRTN = struct {
    inib: startup.INIRTNB,
    p_next: ?*T_INIRTN,
};

///
///  終了処理ルーチンのコンフィギュレーションデータ
///
const T_TERRTN = struct {
    inib: startup.TERRTNB,
    p_next: ?*T_TERRTN,
};

///
///  コンフィギュレーションデータのリストの型
///
///  末尾への挿入を効率化するために，先頭の要素と末尾の要素を管理する
///  リストを用いる．
///
fn LIST(comptime T: type) type {
    return struct {
        head: ?*T = null,
        tail: ?*T = null,
        length: usize = 0,
    };
}

///
///  カーネルのコンフィギュレーションデータ
///
pub const CfgData = struct {
    // 各オブジェクトのコンフィギュレーションデータ
    tsk_list: LIST(T_TSK) = LIST(T_TSK){},
    sem_list: LIST(T_SEM) = LIST(T_SEM){},
    flg_list: LIST(T_FLG) = LIST(T_FLG){},
    dtq_list: LIST(T_DTQ) = LIST(T_DTQ){},
    pdq_list: LIST(T_PDQ) = LIST(T_PDQ){},
    mtx_list: LIST(T_MTX) = LIST(T_MTX){},
    mpf_list: LIST(T_MPF) = LIST(T_MPF){},
    cyc_list: LIST(T_CYC) = LIST(T_CYC){},
    alm_list: LIST(T_ALM) = LIST(T_ALM){},
    p_ovr: ?*T_OVR = null,
    int_list: LIST(T_INT) = LIST(T_INT){},
    inh_list: LIST(T_INH) = LIST(T_INH){},
    isr_list: LIST(T_ISR) = LIST(T_ISR){},
    exc_list: LIST(T_EXC) = LIST(T_EXC){},
    p_ics: ?*T_ICS = null,
    inirtn_list: LIST(T_INIRTN) = LIST(T_INIRTN){},
    terrtn_list: LIST(T_TERRTN) = LIST(T_TERRTN){},

    // コンフィギュレーションデータの追加
    fn addItem(comptime T: type, comptime p_list: *LIST(T)) *T {
        comptime var item: T = undefined;
        item.p_next = null;
        if (p_list.tail) |tail| {
            tail.p_next = &item;
        }
        else {
            p_list.head = &item;
        }
        p_list.tail = &item;
        p_list.length += 1;
        return &item;
    }

    // オブジェクトIDの取得
    fn getId(comptime list: var, comptime name: []const u8) ID {
        comptime var id: ID = 1;
        comptime var p_item = list.head;
        inline while (p_item) |item| : (p_item = item.p_next) {
            if (std.mem.eql(u8, name, item.name)) {
                return id;
            }
            id += 1;
        }
        @compileError("ID not found.");
    }

    // オブジェクトの初期化ブロックの生成
    fn genIniB(comptime INIB: type, comptime list: var) []INIB {
        comptime var inib_table: [list.length]INIB = undefined;
        comptime var i: usize = 0;
        comptime var p_item = list.head;
        inline while (p_item) |item| : (p_item = item.p_next) {
            inib_table[i] = item.inib;
            i += 1;
        }
        return &inib_table;
    }

    // タスクの生成
    pub fn CRE_TSK(comptime p_self: *CfgData, comptime tsk_name: []const u8,
                   comptime ctsk: T_CTSK) void {
        comptime var p_tsk = addItem(T_TSK, &p_self.tsk_list);
        p_tsk.name = tsk_name;
        p_tsk.inib = comptime task.cre_tsk(ctsk)
            catch |err| reportError("CRE_TSK", err);
    }

    // タスクIDの取得
    pub fn getTskId(comptime self: CfgData, comptime tsk_name: []const u8) ID {
        return getId(self.tsk_list, tsk_name);
    }

    // タスク初期化ブロックの生成
    fn genTIniB(comptime self: CfgData) []task.TINIB {
        return genIniB(task.TINIB, self.tsk_list);
    }

    // タスク順序テーブルの生成
    fn genTorderTable(comptime self: CfgData) []ID {
        comptime var torder_table: [self.tsk_list.length]ID = undefined;
        comptime var i: usize = 0;
        comptime var p_item = self.tsk_list.head;
        inline while (p_item) |item| : (p_item = item.p_next) {
            torder_table[i] = @intCast(ID, i + 1);
            i += 1;
        }
        return &torder_table;
    }

    // セマフォの生成
    pub fn CRE_SEM(comptime p_self: *CfgData, comptime sem_name: []const u8,
                   comptime csem: T_CSEM) void {
        comptime var p_sem = addItem(T_SEM, &p_self.sem_list);
        p_sem.name = sem_name;
        p_sem.inib = comptime semaphore.cre_sem(csem)
            catch |err| reportError("CRE_SEM", err);
    }

    // セマフォIDの取得
    pub fn getSemId(comptime self: CfgData, comptime sem_name: []const u8) ID {
        return getId(self.sem_list, sem_name);
    }

    // セマフォ初期化ブロックの生成
    fn genSemIniB(comptime self: CfgData) []semaphore.SEMINIB {
        return genIniB(semaphore.SEMINIB, self.sem_list);
    }

    // イベントフラグの生成
    pub fn CRE_FLG(comptime p_self: *CfgData, comptime flg_name: []const u8,
                   comptime cflg: T_CFLG) void {
        comptime var p_flg = addItem(T_FLG, &p_self.flg_list);
        p_flg.name = flg_name;
        p_flg.inib = comptime eventflag.cre_flg(cflg)
            catch |err| reportError("CRE_FLG", err);
    }

    // イベントフラグIDの取得
    pub fn getFlgId(comptime self: CfgData, comptime flg_name: []const u8) ID {
        return getId(self.flg_list, flg_name);
    }

    // イベントフラグ初期化ブロックの生成
    fn genFlgIniB(comptime self: CfgData) []eventflag.FLGINIB {
        return genIniB(eventflag.FLGINIB, self.flg_list);
    }

    // データキューの生成
    pub fn CRE_DTQ(comptime p_self: *CfgData, comptime dtq_name: []const u8,
                   comptime cdtq: T_CDTQ) void {
        comptime var p_dtq = addItem(T_DTQ, &p_self.dtq_list);
        p_dtq.name = dtq_name;
        p_dtq.inib = comptime dataqueue.cre_dtq(cdtq)
            catch |err| reportError("CRE_DTQ", err);
    }

    // データキューIDの取得
    pub fn getDtqId(comptime self: CfgData, comptime dtq_name: []const u8) ID {
        return getId(self.dtq_list, dtq_name);
    }

    // データキュー初期化ブロックの生成
    fn genDtqIniB(comptime self: CfgData) []dataqueue.DTQINIB {
        return genIniB(dataqueue.DTQINIB, self.dtq_list);
    }

    // 優先度データキューの生成
    pub fn CRE_PDQ(comptime p_self: *CfgData, comptime pdq_name: []const u8,
                   comptime cpdq: T_CPDQ) void {
        comptime var p_pdq = addItem(T_PDQ, &p_self.pdq_list);
        p_pdq.name = pdq_name;
        p_pdq.inib = comptime pridataq.cre_pdq(cpdq)
            catch |err| reportError("CRE_PDQ", err);
    }

    // 優先度データキューIDの取得
    pub fn getPdqId(comptime self: CfgData, comptime pdq_name: []const u8) ID {
        return getId(self.pdq_list, pdq_name);
    }

    // 優先度データキュー初期化ブロックの生成
    fn genPdqIniB(comptime self: CfgData) []pridataq.PDQINIB {
        return genIniB(pridataq.PDQINIB, self.pdq_list);
    }

    // ミューテックスの生成
    pub fn CRE_MTX(comptime p_self: *CfgData, comptime mtx_name: []const u8,
                   comptime cmtx: T_CMTX) void {
        comptime var p_mtx = addItem(T_MTX, &p_self.mtx_list);
        p_mtx.name = mtx_name;
        p_mtx.inib = comptime mutex.cre_mtx(cmtx)
            catch |err| reportError("CRE_MTX", err);
    }

    // ミューテックスIDの取得
    pub fn getMtxId(comptime self: CfgData, comptime mtx_name: []const u8) ID {
        return getId(self.mtx_list, mtx_name);
    }

    // ミューテックス初期化ブロックの生成
    fn genMtxIniB(comptime self: CfgData) []mutex.MTXINIB {
        return genIniB(mutex.MTXINIB, self.mtx_list);
    }

    // 固定長メモリプールの生成
    pub fn CRE_MPF(comptime p_self: *CfgData, comptime mpf_name: []const u8,
                   comptime cmpf: T_CMPF) void {
        comptime var p_mpf = addItem(T_MPF, &p_self.mpf_list);
        p_mpf.name = mpf_name;
        p_mpf.inib = comptime mempfix.cre_mpf(cmpf)
            catch |err| reportError("CRE_MPF", err);
    }

    // 固定長メモリプールIDの取得
    pub fn getMpfId(comptime self: CfgData, comptime mpf_name: []const u8) ID {
        return getId(self.mpf_list, mpf_name);
    }

    // 固定長メモリプール初期化ブロックの生成
    fn genMpfIniB(comptime self: CfgData) []mempfix.MPFINIB {
        return genIniB(mempfix.MPFINIB, self.mpf_list);
    }

    // 周期通知の生成
    pub fn CRE_CYC(comptime p_self: *CfgData, comptime cyc_name: []const u8,
                   comptime ccyc: T_CCYC) void {
        comptime var p_cyc = addItem(T_CYC, &p_self.cyc_list);
        p_cyc.name = cyc_name;
        p_cyc.inib = comptime cyclic.cre_cyc(ccyc)
            catch |err| reportError("CRE_CYC", err);
    }

    // 周期通知初期化ブロックの生成
    fn genCycIniB(comptime self: CfgData) []cyclic.CYCINIB {
        return genIniB(cyclic.CYCINIB, self.cyc_list);
    }

    // アラーム通知の生成
    pub fn CRE_ALM(comptime p_self: *CfgData, comptime alm_name: []const u8,
                   comptime calm: T_CALM) void {
        comptime var p_alm = addItem(T_ALM, &p_self.alm_list);
        p_alm.name = alm_name;
        p_alm.inib = comptime alarm.cre_alm(calm)
            catch |err| reportError("CRE_ALM", err);
    }

    // アラーム通知初期化ブロックの生成
    fn genAlmIniB(comptime self: CfgData) []alarm.ALMINIB {
        return genIniB(alarm.ALMINIB, self.alm_list);
    }

    // オーバランハンドラの定義
    pub fn DEF_OVR(comptime p_self: *CfgData, comptime dovr: T_DOVR) void {
        if (!TOPPERS_SUPPORT_OVRHDR) {
            reportError("DEF_OVR", ItronError!NotSupported);
        }
        else if (p_self.p_ovr != null) {
            // 静的API「DEF_OVR」が複数ある場合（E_OBJ）［NGKI2619］
            reportError("DEF_OVR", ItronError!ObjectStateError);
        }
        else {
            comptime var ovr: T_OVR = undefined;
            p_self.p_ovr = &ovr;
            ovr.inib = comptime overrun.defineOverrun(dovr)
                catch |err| reportError("DEF_OVR", err);
        }
    }

    // 割込み要求ラインの設定
    pub fn CFG_INT(comptime p_self: *CfgData, comptime intno: INTNO,
                   comptime cint: T_CINT) void {
        comptime var p_int = addItem(T_INT, &p_self.int_list);
        p_int.inib = comptime interrupt.cfg_int(intno, cint)
            catch |err| reportError("CFG_INT", err);
    }

    // 割込み要求ライン初期化ブロックの生成
    fn genIntIniB(comptime self: CfgData) []interrupt.INTINIB {
        return genIniB(interrupt.INTINIB, self.int_list);
    }

    // 割込み要求ラインの設定の取得
    pub fn referIntIniB(comptime self: CfgData, comptime intno: INTNO)
                                                        ?interrupt.INTINIB {
        comptime var p_int = self.int_list.head;
        inline while (p_int) |int| : (p_int = int.p_next) {
            if (int.inib.intno == intno) {
                return int.inib;
            }
        }
        return null;
    }

    // 割込みハンドラの定義
    pub fn DEF_INH(comptime p_self: *CfgData, comptime inhno: INHNO,
                   comptime dinh: T_DINH) void {
        comptime var p_inh = addItem(T_INH, &p_self.inh_list);
        p_inh.inib =
            comptime interrupt.def_inh(inhno, dinh, p_self)
            catch |err| reportError("DEF_INH", err);
    }
    
    // 割込みハンドラ初期化ブロックの生成
    fn genInhIniB(comptime self: CfgData) []interrupt.INHINIB {
        return genIniB(interrupt.INHINIB, self.inh_list);
    }

    // 割込みハンドラの定義の取得
    pub fn referInhIniB(comptime self: CfgData, comptime inhno: INHNO)
                                                        ?interrupt.INHINIB {
        comptime var p_inh = self.inh_list.head;
        inline while (p_inh) |inh| : (p_inh = inh.p_next) {
            if (inh.inib.inhno == inhno) {
                return inh.inib;
            }
        }
        return null;
    }

    // 割込みサービスルーチンの生成
    pub fn CRE_ISR(comptime p_self: *CfgData, comptime isr_name: []const u8,
                   comptime cisr: T_CISR) void {
        comptime var p_isr = addItem(T_ISR, &p_self.isr_list);
        p_isr.name = isr_name;
        p_isr.cfg.cisr = comptime interrupt.cre_isr(cisr, p_self)
            catch |err| reportError("CRE_ISR", err);
        p_isr.cfg.isrid = comptime @intCast(ID, p_self.isr_list.length);
        p_isr.cfg.genflag = false;
    }

    // 割込みサービスルーチンの生成情報の取得
    pub fn referCreIsr(comptime self: CfgData, comptime intno: INTNO)
                                                        ?interrupt.ISRCFG {
        comptime var p_isr = self.isr_list.head;
        inline while (p_isr) |isr| : (p_isr = isr.p_next) {
            if (isr.cfg.cisr.intno == intno) {
                return isr.cfg;
            }
        }
        return null;
    }

    // 割込みサービスルーチンを呼び出す割込みハンドラの登録
    pub fn addInh(comptime p_self: *CfgData,
                  comptime inhinib: interrupt.INHINIB) void {
        comptime var p_inh = addItem(T_INH, &p_self.inh_list);
        p_inh.inib = inhinib;
    }

    // CPU例外ハンドラの定義
    pub fn DEF_EXC(comptime p_self: *CfgData, comptime excno: EXCNO,
                   comptime dexc: T_DEXC) void {
        comptime var p_exc = addItem(T_EXC, &p_self.exc_list);
        p_exc.inib = comptime exception.def_exc(excno, dexc)
            catch |err| reportError("DEF_EXC", err);
    }

    // CPU例外ハンドラ初期化ブロックの生成
    fn genExcIniB(comptime self: CfgData) []exception.EXCINIB {
        return genIniB(exception.EXCINIB, self.exc_list);
    }

    // 非タスクコンテキスト用スタック領域の定義
    pub fn DEF_ICS(comptime p_self: *CfgData, comptime dics: T_DICS) void {
        if (p_self.p_ics != null) {
            // 非タスクコンテキスト用スタック領域が設定済みの場合（E_OBJ）
            // ［NGKI3216］
            reportError("DEF_ICS", ItronError!ObjectStateError);
        }
        else {
            comptime var ics: T_ICS = undefined;
            p_self.p_ics = &ics;
            ics.dics = comptime startup.defineInterruptStack(dics)
                catch |err| reportError("DEF_ICS", err);
        }
    }

    // 初期化ルーチンの追加
    pub fn ATT_INI(comptime p_self: *CfgData, comptime aini: T_AINI) void {
        comptime var p_inirtn = addItem(T_INIRTN, &p_self.inirtn_list);
        p_inirtn.inib = comptime startup.attachInitializeRoutine(aini)
            catch |err| reportError("ATT_INI", err);
    }

    // 初期化ルーチンブロックの生成
    fn genIniRtnB(comptime self: CfgData) []startup.INIRTNB {
        return genIniB(startup.INIRTNB, self.inirtn_list);
    }

    // 終了処理ルーチンの追加
    pub fn ATT_TER(comptime p_self: *CfgData, comptime ater: T_ATER) void {
        comptime var p_terrtn = addItem(T_TERRTN, &p_self.terrtn_list);
        p_terrtn.inib = comptime startup.attachTerminateRoutine(ater)
            catch |err| reportError("ATT_TER", err);
    }

    // 終了処理ルーチンブロックの生成
    fn genTerRtnB(comptime self: CfgData) []startup.TERRTNB {
        const length = self.terrtn_list.length;
        comptime var table: [length]startup.TERRTNB = undefined;
        comptime var i: usize = length;
        comptime var p_terrtn = self.terrtn_list.head;
        inline while (p_terrtn) |terrtn| : (p_terrtn = terrtn.p_next) {
            i -= 1;
            table[i] = terrtn.inib;
        }
        return &table;
    }

    // コンフィギュレーションデータの加工処理
    pub fn process(comptime p_self: *CfgData) void {
        // タスクが1つも登録されていない場合［NGKI0033］
        if (p_self.tsk_list.head == null) {
            @compileError("no task is registered.");
        }

        // 割込みサービスルーチンを呼び出す割込みハンドラの生成
        comptime var isrcfg_table: [p_self.isr_list.length]interrupt.ISRCFG
                                                                = undefined;
        comptime var i: usize = 0;
        comptime var p_isr = p_self.isr_list.head;
        inline while (p_isr) |isr| : (p_isr = isr.p_next) {
            isrcfg_table[i] = isr.cfg;
            i += 1;
        }
        interrupt.generateInhForIsr(&isrcfg_table, p_self);
    }
};

extern fn _kernel_initialize_task() void;
extern fn _kernel_initialize_semaphore() void;
extern fn _kernel_initialize_eventflag() void;
extern fn _kernel_initialize_dataqueue() void;
extern fn _kernel_initialize_pridataq() void;
extern fn _kernel_initialize_mutex() void;
extern fn _kernel_initialize_mempfix() void;
extern fn _kernel_initialize_cyclic() void;
extern fn _kernel_initialize_alarm() void;
extern fn _kernel_initialize_interrupt() void;
extern fn _kernel_initialize_exception() void;

///
///  IDのexport
///
fn exportConst(comptime target: var, comptime name: []const u8) void {
    _ = struct {
        var placeholder = target;
        comptime { @export(placeholder, .{ .name = name,
                                           .section = ".rodata", }); }
    }.placeholder;
}

fn exportIdSymbol(comptime target: var, comptime name: []const u8) void {
    _ = struct {
        var placeholder = target;
        comptime { @export(placeholder, .{ .name = "id." ++ name,
                                           .section = ".TOPPERS.id", }); }
    }.placeholder;
}

fn exportId(comptime list: var) void {
    comptime var id: ID = 1;
    comptime var p_item = list.head;
    inline while (p_item) |item| : (p_item = item.p_next) {
        exportIdSymbol(id, item.name);
        if (USE_EXTERNAL_ID) {
            exportConst(id, item.name);
        }
        id += 1;
    }
}

///
///  コンフィギュレーションデータの生成
///
pub fn GenCfgData(comptime cfg_data: *CfgData) type {
    // コンフィギュレーションデータの加工処理
    cfg_data.process();

    //
    //  オブジェクトIDの定義の生成
    //
    exportIdSymbol(@as(u32, 0x12345678), "TOPPERS_magic_number");
    exportIdSymbol(cfg_data.tsk_list.length, "TNUM_TSKID");
    exportId(cfg_data.tsk_list);
    exportIdSymbol(cfg_data.sem_list.length, "TNUM_SEMID");
    exportId(cfg_data.sem_list);
    exportIdSymbol(cfg_data.flg_list.length, "TNUM_FLGID");
    exportId(cfg_data.flg_list);
    exportIdSymbol(cfg_data.dtq_list.length, "TNUM_DTQID");
    exportId(cfg_data.dtq_list);
    exportIdSymbol(cfg_data.pdq_list.length, "TNUM_PDQID");
    exportId(cfg_data.pdq_list);
    exportIdSymbol(cfg_data.mtx_list.length, "TNUM_MTXID");
    exportId(cfg_data.mtx_list);
    exportIdSymbol(cfg_data.mpf_list.length, "TNUM_MPFID");
    exportId(cfg_data.mpf_list);
    exportIdSymbol(cfg_data.cyc_list.length, "TNUM_CYCID");
    exportId(cfg_data.cyc_list);
    exportIdSymbol(cfg_data.alm_list.length, "TNUM_ALMID");
    exportId(cfg_data.alm_list);
    exportIdSymbol(cfg_data.isr_list.length, "TNUM_ISRID");
    exportId(cfg_data.isr_list);
    exportIdSymbol(cfg_data.inirtn_list.length, "TNUM_INIRTN");
    exportIdSymbol(cfg_data.terrtn_list.length, "TNUM_TERRTN");

    //
    //  チェック処理用の定義の生成
    //
    exportCheck(0x12345678, "TOPPERS_magic_number");
    exportCheck(decl(u32, target_impl, "CHECK_USIZE_ALIGN", 1),
                "CHECK_USIZE_ALIGN");
    exportCheck(decl(u32, target_impl, "CHECK_USIZE_ALIGN", 1),
                "CHECK_USIZE_ALIGN");
    exportCheck(@boolToInt(isTrue(target_impl, "CHECK_USIZE_NONNULL")),
                "CHECK_USIZE_NONNULL");
    exportCheck(decl(u32, target_impl, "CHECK_FUNC_ALIGN", 1),
                "CHECK_FUNC_ALIGN");
    exportCheck(@boolToInt(isTrue(target_impl, "CHECK_FUNC_NONNULL")),
                "CHECK_FUNC_NONNULL");
    exportCheck(decl(u32, target_impl, "CHECK_STACK_ALIGN", 1),
                "CHECK_STACK_ALIGN");
    exportCheck(@boolToInt(isTrue(target_impl, "CHECK_STACK_NONNULL")),
                "CHECK_STACK_NONNULL");
    exportCheck(decl(u32, target_impl, "CHECK_MPF_ALIGN", 1),
                "CHECK_MPF_ALIGN");
    exportCheck(@boolToInt(isTrue(target_impl, "CHECK_MPF_NONNULL")),
                "CHECK_MPF_NONNULL");

    exportCheck(@sizeOf(usize), "sizeof_usize");
    exportCheck(@sizeOf(c_uint), "sizeof_UINT");
    exportCheck(@sizeOf(ID), "sizeof_ID");
    exportCheck(@sizeOf(ATR), "sizeof_ATR");
    exportCheck(@sizeOf(NFYHDR), "sizeof_NFYHDR");
    exportCheck(@sizeOf(EXINF), "sizeof_EXINF");
    exportCheck(@sizeOf(*u8), "sizeof_ptr_u8");
    exportCheck(TA_CHECK_USIZE, "TA_CHECK_USIZE");

    //
    //  コンフィギュレーションデータの生成
    //
    return struct {
        // タスクに関するコンフィギュレーションデータの生成
        usingnamespace task.ExportTskCfg(cfg_data.genTIniB(),
                                         cfg_data.genTorderTable());

        // セマフォに関するコンフィギュレーションデータの生成
        usingnamespace semaphore.ExportSemCfg(cfg_data.genSemIniB());

        // イベントフラグに関するコンフィギュレーションデータの生成
        usingnamespace eventflag.ExportFlgCfg(cfg_data.genFlgIniB());

        // データキューに関するコンフィギュレーションデータの生成
        usingnamespace dataqueue.ExportDtqCfg(cfg_data.genDtqIniB());

        // 優先度データキューに関するコンフィギュレーションデータの生成
        usingnamespace pridataq.ExportPdqCfg(cfg_data.genPdqIniB());

        // ミューテックスに関するコンフィギュレーションデータの生成
        usingnamespace mutex.ExportMtxCfg(cfg_data.genMtxIniB());

        // 固定長メモリプールに関するコンフィギュレーションデータの生成
        usingnamespace mempfix.ExportMpfCfg(cfg_data.genMpfIniB());

        // 周期通知に関するコンフィギュレーションデータの生成
        usingnamespace cyclic.ExportCycCfg(cfg_data.genCycIniB());

        // アラーム通知に関するコンフィギュレーションデータの生成
        usingnamespace alarm.ExportAlmCfg(cfg_data.genAlmIniB());

        // オーバランハンドラに関するコンフィギュレーションデータの生成
        usingnamespace if (TOPPERS_SUPPORT_OVRHDR)
            overrun.ExportOvrIniB(if (cfg_data.p_ovr) |ovr| ovr.inib else null)
        else struct {};

        // 割込みに関するコンフィギュレーションデータの生成
        usingnamespace if (comptime @hasDecl(target_impl, "ExportIntIniB"))
                           target_impl.ExportIntIniB(cfg_data.genIntIniB())
                       else interrupt.ExportIntIniB(cfg_data.genIntIniB());

        usingnamespace if (comptime @hasDecl(target_impl, "ExportInhIniB"))
                           target_impl.ExportInhIniB(cfg_data.genInhIniB())
                       else interrupt.ExportInhIniB(cfg_data.genInhIniB());

        // CPU例外に関するコンフィギュレーションデータの生成
        usingnamespace if (comptime @hasDecl(target_impl, "ExportExcIniB"))
                           target_impl.ExportExcIniB(cfg_data.genExcIniB())
                       else exception.ExportExcIniB(cfg_data.genExcIniB());

        // 非タスクコンテキスト用のスタック領域に関するコンフィギュレー
        // ションデータの生成
        const dics = if (comptime cfg_data.p_ics) |ics| ics.dics
            else T_DICS{ .istksz = target_impl.DEFAULT_ISTKSZ, .istk = null, };
        usingnamespace startup.ExportIcs(dics);

        // 初期化ルーチンに関するコンフィギュレーションデータの生成
        usingnamespace startup.ExportIniRtnB(cfg_data.genIniRtnB());

        // 終了処理ルーチンに関するコンフィギュレーションデータの生成
        usingnamespace startup.ExportTerRtnB(cfg_data.genTerRtnB());

        // タイムイベントヒープの生成
        const tnum_tmevt = cfg_data.tsk_list.length
                         + cfg_data.cyc_list.length + cfg_data.alm_list.length;
        pub export var _kernel_tmevt_heap: [tnum_tmevt]*time_event.TMEVTB
                                                                = undefined;

        // オブジェクトの初期化関数の生成
        pub export fn _kernel_initialize_object() void {
            _kernel_initialize_task();
            if (comptime cfg_data.sem_list.length > 0) {
                _kernel_initialize_semaphore();
            }
            if (comptime cfg_data.flg_list.length > 0) {
                _kernel_initialize_eventflag();
            }
            if (comptime cfg_data.dtq_list.length > 0) {
                _kernel_initialize_dataqueue();
            }
            if (comptime cfg_data.pdq_list.length > 0) {
                _kernel_initialize_pridataq();
            }
            if (comptime cfg_data.mtx_list.length > 0) {
                _kernel_initialize_mutex();
            }
            if (comptime cfg_data.mpf_list.length > 0) {
                _kernel_initialize_mempfix();
            }
            if (comptime cfg_data.cyc_list.length > 0) {
                _kernel_initialize_cyclic();
            }
            if (comptime cfg_data.alm_list.length > 0) {
                _kernel_initialize_alarm();
            }
            _kernel_initialize_interrupt();
            _kernel_initialize_exception();
        }
    };
}
