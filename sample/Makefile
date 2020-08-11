#
#  TOPPERS/ASP Kernel
#      Toyohashi Open Platform for Embedded Real-Time Systems/
#      Advanced Standard Profile Kernel
# 
#  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
#                              Toyohashi Univ. of Technology, JAPAN
#  Copyright (C) 2006-2020 by Embedded and Real-Time Systems Laboratory
#              Graduate School of Information Science, Nagoya Univ., JAPAN
# 
#  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
#  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
#  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
#  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
#      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
#      スコード中に含まれていること．
#  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
#      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
#      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
#      の無保証規定を掲載すること．
#  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
#      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
#      と．
#    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
#        作権表示，この利用条件および下記の無保証規定を掲載すること．
#    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
#        報告すること．
#  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
#      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
#      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
#      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
#      免責すること．
# 
#  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
#  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
#  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
#  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
#  の責任を負わない．
# 
#  $Id: Makefile 1270 2019-10-03 14:04:50Z ertl-hiro $
# 

#
#  ターゲットの指定（Makefile.targetで上書きされるのを防ぐため）
#
all:

#
#  ターゲット略称の定義
#
TARGET = @(TARGET)

#
#  プログラミング言語の定義
#
SRCLANG = @(SRCLANG)
ifeq ($(SRCLANG),c)
	LIBS = -lc
endif
ifeq ($(SRCLANG),c++)
	USE_CXX = true
	CXXLIBS = -lstdc++ -lm -lc
	CXXRTS = cxxrt.o newlibrt.o
endif
ifeq ($(SRCLANG),zig)
	USE_ZIG = true
	LIBS = -lc
endif

#
#  ソースファイルのディレクトリの定義
#
SRCDIR = @(SRCDIR)

#
#  オブジェクトファイル名の拡張子の設定
#
OBJEXT = @(OBJEXT)

#
#  カーネルライブラリ（libkernel.a）のディレクトリ名
#  （カーネルライブラリもmake対象にする時は，空に定義する）
#
KERNEL_LIB = @(KERNEL_LIB)

#
#  カーネルとコンフィギュレーションデータを一体でコンパイルするかどうかの定義
#
BIND_CFG = @(BIND_CFG)

#
#  TECSを外すかどうかの定義
#
OMIT_TECS = @(OMIT_TECS)

#
#  TECS関係ファイルのディレクトリの定義
#
TECSDIR = @(TECSDIR)

#
#  トレースログを取得するかどうかの定義
#
ENABLE_TRACE = @(ENABLE_TRACE)

#
#  開発ツール（コンパイラ等）のディレクトリの定義
#
DEVTOOLDIR = @(DEVTOOLDIR)

#
#  ユーティリティプログラムの名称
#
CFG = @(CFG)
TECSGEN = @(TECSGEN)

#
#  オブジェクトファイル名の定義
#
OBJNAME = asp
ifdef OBJEXT
	OBJFILE = $(OBJNAME).$(OBJEXT)
	CFG1_OUT = cfg1_out.$(OBJEXT)
else
	OBJFILE = $(OBJNAME)
	CFG1_OUT = cfg1_out
endif

#
#  中間オブジェクトファイルと依存関係ファイルを置くディレクトリの定義
#
OBJDIR = @(OBJDIR)
DEPDIR = @(OBJDIR)

#
#  ターゲット依存部のディレクトリの定義
#
TARGETDIR = $(SRCDIR)/target/$(TARGET)

#
#  ターゲット依存の定義のインクルード
#
include $(TARGETDIR)/Makefile.target

#
#  TECS生成ファイルのディレクトリの定義
#
TECSGENDIR = ./gen
ifndef OMIT_TECS
	TECSGEN_TIMESTAMP = $(TECSGENDIR)/tecsgen.timestamp
	INIT_TECS_COBJ = init_tecs.o
endif

#
#  TECSが生成する定義のインクルード
#
ifndef OMIT_TECS
	GEN_DIR = $(TECSGENDIR)
	-include $(TECSGENDIR)/Makefile.tecsgen
endif

#
#  共通コンパイルオプションの定義
#
COPTS := -g @(COPTS) $(COPTS)
ifndef OMIT_WARNING_ALL
	COPTS := -Wall $(COPTS)
endif
ifndef OMIT_OPTIMIZATION
	COPTS := -O2 $(COPTS)
endif
ifdef OMIT_TECS
	CDEFS := -DTOPPERS_OMIT_TECS $(CDEFS)
endif
CDEFS := $(CDEFS) @(CDEFS)
INCLUDES := -I. -I$(SRCDIR)/include $(INCLUDES) -I$(SRCDIR)
LDFLAGS := $(LDFLAGS) @(LDFLAGS)
OBJ_LDFLAGS := $(OBJ_LDFLAGS) -Wl,--gc-sections 
LIBS := @(LIBS) $(LIBS) $(CXXLIBS)
CFLAGS = $(COPTS) $(CDEFS) $(INCLUDES)
ZIGOPTS := $(ZIGOPTS) -DTARGET=\"$(TARGET)\"
ZIGOPTS := $(ZIGOPTS) -DSRCDIR=\"$(SRCDIR)\"
ZIGOPTS := $(ZIGOPTS) -DTECSGENDIR=\"@(BUILDDIR)/gen\"
ifdef BIND_CFG
	ZIGOPTS := $(ZIGOPTS) -DBIND_CFG=\"$(BIND_CFG).zig\"
endif
ZIGOPTS := --main-pkg-path $(SRCDIR) -ffunction-sections $(ZIGOPTS)
ZIGOPTS := --release-@(MODE) $(ZIGOPTS)
ZIGFLAGS = $(ZIGOPTS) $(CDEFS) $(INCLUDES)

#
#  アプリケーションプログラムに関する定義
#
APPLNAME = @(APPLNAME)
APPLDIRS = @(APPLDIRS)
APPL_CDL = @(CDLFILE)

APPL_DIRS := $(APPLDIRS) $(SRCDIR)/library
APPL_ASMOBJS :=
ifdef USE_ZIG
	APPL_ZIGOBJS := @(APPLOBJS)
	APPL_COBJS :=
else
ifdef USE_CXX
	APPL_CXXOBJS := @(APPLOBJS)
	APPL_COBJS :=
else
	APPL_COBJS := @(APPLOBJS)
endif
endif
APPL_COBJS := $(APPL_COBJS) log_output.o vasyslog.o t_perror.o strerror.o
APPL_CFLAGS := $(APPL_CFLAGS)
ifdef APPLDIRS
	INCLUDES := $(INCLUDES) $(foreach dir,$(APPLDIRS),-I$(dir))
endif

#
#  システムサービスに関する定義
#
SYSSVC_DIRS := $(TECSGENDIR) $(SRCDIR)/tecs_kernel \
				$(SYSSVC_DIRS) $(SRCDIR)/syssvc
SYSSVC_ASMOBJS := $(SYSSVC_ASMOBJS)
SYSSVC_COBJS := $(SYSSVC_COBJS) @(SYSSVCOBJS) $(TECS_COBJS) \
				$(INIT_TECS_COBJ) $(CXXRTS)
SYSSVC_CFLAGS := $(SYSSVC_CFLAGS)
INCLUDES := $(INCLUDES) -I$(TECSGENDIR) -I$(SRCDIR)/tecs_kernel

#
#  トレースログ記録のサンプルコードに関する定義
#
ifdef ENABLE_TRACE
	COPTS := $(COPTS) -DTOPPERS_ENABLE_TRACE
	ZIGOPTS := $(ZIGOPTS) -DTOPPERS_ENABLE_TRACE
	SYSSVC_DIRS := $(SYSSVC_DIRS) $(SRCDIR)/arch/tracelog
endif

#
#  ターゲットファイル
#
.PHONY: all
ifndef OMIT_TECS
all: tecs
	@$(MAKE) check
#	@$(MAKE) check $(OBJNAME).bin
#	@$(MAKE) check $(OBJNAME).srec
else
all: check
#all: check $(OBJNAME).bin
#all: check $(OBJNAME).srec
endif

##### 以下は編集しないこと #####

#
#  コンフィギュレータに関する定義
#
CFG_KERNEL := --kernel asp
CFG_TABS := --api-table $(SRCDIR)/kernel/kernel_api.def \
			--symval-table $(SRCDIR)/kernel/kernel_sym.def $(CFG_TABS)
ifdef BIND_CFG
	CFGOBJ = kernel.o
else
	CFGOBJ = $(OBJDIR)/@(ZIGCFG).o
	APPL_ZIGOBJS := $(APPL_ZIGOBJS) @(ZIGCFG).o
endif
ifndef TARGET_CHECK_TRB
	TARGET_CHECK_TRB := $(TARGETDIR)/target_check.trb
endif

#
#  ソースファイルのあるディレクトリに関する定義
#
vpath %.zig $(SRCDIR)/kernel $(SYSSVC_DIRS) $(APPL_DIRS)
vpath %.c $(SYSSVC_DIRS) $(APPL_DIRS)
vpath %.S $(SYSSVC_DIRS) $(APPL_DIRS)
vpath %.cdl $(APPL_DIRS)

#
#  中間オブジェクトファイルを置くディレクトリの処理
#
APPL_ASMOBJS   := $(addprefix $(OBJDIR)/, $(APPL_ASMOBJS))
APPL_CXXOBJS   := $(addprefix $(OBJDIR)/, $(APPL_CXXOBJS))
APPL_COBJS     := $(addprefix $(OBJDIR)/, $(APPL_COBJS))
APPL_ZIGOBJS   := $(addprefix $(OBJDIR)/, $(APPL_ZIGOBJS))
SYSSVC_ASMOBJS := $(addprefix $(OBJDIR)/, $(SYSSVC_ASMOBJS))
SYSSVC_COBJS   := $(addprefix $(OBJDIR)/, $(SYSSVC_COBJS))

#
#  コンパイルのための変数の定義
#
APPL_OBJS = $(APPL_ASMOBJS) $(APPL_COBJS) $(APPL_CXXOBJS) $(APPL_ZIGOBJS)
SYSSVC_OBJS = $(SYSSVC_ASMOBJS) $(SYSSVC_COBJS)
ALL_OBJS = $(START_OBJS) $(APPL_OBJS) $(SYSSVC_OBJS) \
											$(END_OBJS) $(HIDDEN_OBJS)
ALL_LIBS = -lkernel $(LIBS)
ifdef KERNEL_LIB
	LIBS_DEP = $(KERNEL_LIB)/libkernel.a $(filter %.a,$(LIBS))
	OBJ_LDFLAGS := $(OBJ_LDFLAGS) -L$(KERNEL_LIB)
	REALCLEAN_FILES := libkernel.a $(REALCLEAN_FILES)
else
	LIBS_DEP = libkernel.a $(filter %.a,$(LIBS))
	OBJ_LDFLAGS := $(OBJ_LDFLAGS) -L.
endif

ifdef TEXT_START_ADDRESS
	LDFLAGS := $(LDFLAGS) -Wl,-Ttext,$(TEXT_START_ADDRESS)
endif
ifdef DATA_START_ADDRESS
	LDFLAGS := $(LDFLAGS) -Wl,-Tdata,$(DATA_START_ADDRESS)
endif
ifdef LDSCRIPT
	LDFLAGS := $(LDFLAGS) -Wl,-T,$(LDSCRIPT)
endif

#
#  tecsgenからCプリプロセッサを呼び出す際のオプションの定義
#
TECS_CPP = $(CC) $(CDEFS) $(INCLUDES) -D TECSGEN -E

#
#  tecsgenの呼出し
#
.PHONY: tecs
tecs $(TECSGEN_SRCS) $(TECS_HEADERS): $(TECSGEN_TIMESTAMP) ;
$(TECSGEN_TIMESTAMP): $(APPL_CDL) $(TECS_IMPORTS)
	$(TECSGEN) $< -R $(INCLUDES) --cpp "$(TECS_CPP)" -g $(TECSGENDIR)
	ruby $(SRCDIR)/cfg/genTecsCfg.rb \
		--api-table $(SRCDIR)/kernel/kernel_api.def gen/tecsgen.cfg

#
#  kernel_cfg.hの生成
#
kernel_cfg.h: $(CFGOBJ)
	$(OBJCOPY) -j .TOPPERS.id $(CFGOBJ) id_defs.o
	$(NM) -n id_defs.o > id_defs.syms
	$(OBJCOPY) -O srec -S id_defs.o id_defs.srec
	ruby $(SRCDIR)/cfg/genIdDefs.rb id_defs

#
#  カーネルライブラリファイルの生成
#
.PHONY: libkernel.a
libkernel.a kernel.o: $(SRCDIR)/kernel/c_api.zig
	zig build-lib --name kernel $(ZIGFLAGS) $<
	$(RANLIB) libkernel.a

#
#  kernel_cfg.hに対する依存関係
#
$(filter-out $(CFGOBJ), $(APPL_OBJS) $(SYSSVC_OBJS)): kernel_cfg.h

#
#  特別な依存関係の定義
#
$(OBJDIR)/@(BANNEROBJ): $(filter-out $(OBJDIR)/@(BANNEROBJ),$(ALL_OBJS)) \
																$(LIBS_DEP)

#
#  全体のリンク
#
$(OBJFILE): $(ALL_OBJS) $(LIBS_DEP)
	$(LINK) $(CFLAGS) $(LDFLAGS) $(OBJ_LDFLAGS) -o $(OBJFILE) \
			$(START_OBJS) $(APPL_OBJS) $(SYSSVC_OBJS) \
			$(ALL_LIBS) $(END_OBJS)

#
#  シンボルファイルの生成
#
$(OBJNAME).syms: $(OBJFILE)
	$(NM) -n $(OBJFILE) > $(OBJNAME).syms

#
#  バイナリファイルの生成
#
$(OBJNAME).bin: $(OBJFILE)
	$(OBJCOPY) -O binary -S $(OBJFILE) $(OBJNAME).bin

#
#  Sレコードファイルの生成
#
$(OBJNAME).srec: $(OBJFILE)
	$(OBJCOPY) -O srec -S $(OBJFILE) $(OBJNAME).srec

#
#  エラーチェック処理
#
.PHONY: check
check: check.timestamp ;
check.timestamp: $(CFGOBJ) $(OBJNAME).syms $(OBJNAME).srec
	$(OBJCOPY) -j .TOPPERS.check $(CFGOBJ) check_defs.o
	$(NM) -n check_defs.o > check_defs.syms
	$(OBJCOPY) -O srec -S check_defs.o check_defs.srec
	ruby $(SRCDIR)/cfg/checkConfig.rb check_defs \
				$(INCLUDES) -T $(TARGET_CHECK_TRB) \
				--rom-symbol $(OBJNAME).syms --rom-image $(OBJNAME).srec
	@echo "configuration check passed"

#
#  コンパイル結果の消去
#
.PHONY: clean
clean:
	rm -f \#* *~ $(OBJDIR)/*.o $(DEPDIR)/*.d $(CLEAN_FILES) check.timestamp
	rm -f $(OBJFILE) $(OBJNAME).syms $(OBJNAME).srec $(OBJNAME).bin
	rm -f id_defs.o id_defs.syms id_defs.srec kernel_cfg.h
	rm -f check_defs.o check_defs.syms check_defs.srec
	rm -rf $(TECSGENDIR) zig-cache kernel.o
ifndef KERNEL_LIB
	rm -f libkernel.a
endif

.PHONY: realclean
realclean: clean
	rm -f $(REALCLEAN_FILES)

#
#  依存関係ファイルのインクルード
#
-include $(DEPDIR)/*.d

#
#  開発ツールのコマンド名の定義
#
ifeq ($(TOOL),gcc)
	#
	#  GNU開発環境用
	#
	ifdef GCC_TARGET
		GCC_TARGET_PREFIX = $(GCC_TARGET)-
	else
		GCC_TARGET_PREFIX =
	endif
	CC := $(GCC_TARGET_PREFIX)gcc
	CXX := $(GCC_TARGET_PREFIX)g++
	AS := $(GCC_TARGET_PREFIX)as
	LD := $(GCC_TARGET_PREFIX)ld
	AR := $(GCC_TARGET_PREFIX)ar
	NM := $(GCC_TARGET_PREFIX)nm
	RANLIB := $(GCC_TARGET_PREFIX)ranlib
	OBJCOPY := $(GCC_TARGET_PREFIX)objcopy
	OBJDUMP := $(GCC_TARGET_PREFIX)objdump
endif

ifdef DEVTOOLDIR
	CC := $(DEVTOOLDIR)/$(CC)
	CXX := $(DEVTOOLDIR)/$(CXX)
	AS := $(DEVTOOLDIR)/$(AS)
	LD := $(DEVTOOLDIR)/$(LD)
	AR := $(DEVTOOLDIR)/$(AR)
	NM := $(DEVTOOLDIR)/$(NM)
	RANLIB := $(DEVTOOLDIR)/$(RANLIB)
	OBJCOPY := $(DEVTOOLDIR)/$(OBJCOPY)
	OBJDUMP := $(DEVTOOLDIR)/$(OBJDUMP)
endif

ifdef USE_CXX
	LINK = $(CXX)
else
	LINK = $(CC)
endif

#
#  コンパイルルールの定義
#
.PHONY: $(APPL_ZIGOBJS)
$(APPL_ZIGOBJS): $(OBJDIR)/%.o: %.zig
	zig build-obj --name $(OBJDIR)/$* $(ZIGFLAGS) $<

$(SYSSVC_COBJS): $(OBJDIR)/%.o: %.c
	$(CC) -c -o $@ -MD -MP -MF $(DEPDIR)/$*.d $(CFLAGS) $(SYSSVC_CFLAGS) $<

$(SYSSVC_COBJS:$(OBJDIR)/%.o=%.s): %.s: %.c
	$(CC) -S -o $@ $(CFLAGS) $(SYSSVC_CFLAGS) $<

$(SYSSVC_ASMOBJS): $(OBJDIR)/%.o: %.S
	$(CC) -c -o $@ -MD -MP -MF $(DEPDIR)/$*.d $(CFLAGS) $(SYSSVC_CFLAGS) $<

$(APPL_COBJS): $(OBJDIR)/%.o: %.c
	$(CC) -c -o $@ -MD -MP -MF $(DEPDIR)/$*.d $(CFLAGS) $(APPL_CFLAGS) $<

$(APPL_COBJS:$(OBJDIR)/%.o=%.s): %.s: %.c
	$(CC) -S -o $@ $(CFLAGS) $(APPL_CFLAGS) $<

$(APPL_CXXOBJS): $(OBJDIR)/%.o: %.cpp
	$(CXX) -c -o $@ -MD -MP -MF $(DEPDIR)/$*.d $(CFLAGS) $(APPL_CFLAGS) $<

$(APPL_CXXOBJS:$(OBJDIR)/%.o=%.s): %.s: %.cpp
	$(CXX) -S -o $@ $(CFLAGS) $(APPL_CFLAGS) $<

$(APPL_ASMOBJS): $(OBJDIR)/%.o: %.S
	$(CC) -c -o $@ -MD -MP -MF $(DEPDIR)/$*.d $(CFLAGS) $(APPL_CFLAGS) $<

#
#  デフォルトコンパイルルールを上書き
#
$(OBJDIR)/%.o: %.c
	@echo "*** Default compile rules should not be used."
	$(CC) -c -o $@ -MD -MP -MF $(DEPDIR)/$*.d $(CFLAGS) $<

%.s: %.c
	@echo "*** Default compile rules should not be used."
	$(CC) -S -o $@ $(CFLAGS) $<

$(OBJDIR)/%.o: %.cpp
	@echo "*** Default compile rules should not be used."
	$(CXX) -c -o $@ -MD -MP -MF $(DEPDIR)/$*.d $(CFLAGS) $<

%.s: %.cpp
	@echo "*** Default compile rules should not be used."
	$(CXX) -S -o $@ $(CFLAGS) $<

$(OBJDIR)/%.o: %.S
	@echo "*** Default compile rules should not be used."
	$(CC) -c -o $@ -MD -MP -MF $(DEPDIR)/$*.d $(CFLAGS) $<
