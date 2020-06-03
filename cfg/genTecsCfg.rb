#!/usr/bin/env ruby -Eutf-8 -w
# -*- coding: utf-8 -*-

#
#		tecsgenが生成したシステムコンフィギュレーションファイルを
#		Zigでの記述に変換するユーティリティ
#
# 制限事項
# ・INCLUDEディレクティブには対応していない
# ・tecsgenが生成する（と思われる）静的APIにしか対応していない

if $0 == __FILE__
  TOOL_ROOT = File.expand_path(File.dirname(__FILE__)) + "/"
  $LOAD_PATH.unshift(TOOL_ROOT)
end

require "pp"
require "csv"
require "optparse"
require "GenFile.rb"

#
#  エラー発生有無フラグ
#
$errorFlag = false

#
#  エラー／警告表示関数
#
# 一般的なエラー表示（処理を中断）
def error_exit(message, location = "")
  location += " " if location != ""
  abort("#{location}error: #{message}")
end

# 一般的なエラー表示（処理を継続）
def error(message, location = "")
  location += " " if location != ""
  STDERR.puts("#{location}error: #{message}")
  $errorFlag = true
end

# 一般的な警告表示
def warning(message, location = "")
  location += " " if location != ""
  STDERR.puts("#{location}warning: #{message}")
end

# システムコンフィギュレーションファイルの構文解析時のエラー
$noParseError = 0
def parse_error(cfgFile, message)
  error(message, "#{cfgFile.getFileName}:#{cfgFile.getLineNo}:")
  if ($noParseError += 1) >= 10
    abort("too many errors emitted, stopping now")
  end
end

# システムコンフィギュレーションファイルの構文解析時の警告
def parse_warning(cfgFile, message)
  warning(message, "#{cfgFile.getFileName}:#{cfgFile.getLineNo}:")
end

#
#  Stringクラスの拡張（二重引用符で囲まれた文字列の作成／展開）
#
class String
  #
  #  二重引用符で囲まれた文字列の作成
  #
  def quote
    result = ""
    self.chars do |c|
      case c
      when "'"
        result += "\\\'"
      when "\""
        result += "\\\""
      when "\0"
        result += "\\0"
      when "\a"
        result += "\\a"
      when "\b"
        result += "\\b"
      when "\f"
        result += "\\f"
      when "\n"
        result += "\\n"
      when "\r"
        result += "\\r"
      when "\t"
        result += "\\t"
      when "\v"
        result += "\\v"
      when "\\"
        result += "\\\\"
      else
        result += c
      end
    end
    return("\"" + result + "\"")
  end

  #
  #  二重引用符で囲まれた文字列の展開
  #
  def unquote
    if /^\"(.*)\"$/m =~ self
      str = $1
      result = ""
      while (/^(.*)\\(.*)$/m =~ str)
        result += $1
        str = $2
        case str
        when /^[aA](.*)$/m
          result += "\a"
          str = $1
        when /^[bB](.*)$/m
          result += "\b"
          str = $1
        when /^[fF](.*)$/m
          result += "\f"
          str = $1
        when /^[nN](.*)$/m
          result += "\n"
          str = $1
        when /^[rR](.*)$/m
          result += "\r"
          str = $1
        when /^[tT](.*)$/m
          result += "\t"
          str = $1
        when /^[vV](.*)$/m
          result += "\v"
          str = $1
        when /^[xX]([0-9a-fA-F][0-9a-fA-F]?)(.*)$/m
          result += $1.hex
          str = $2
        when /^([0-7][0-7]?[0-7]?)(.*)$/m
          result += $1.oct
          str = $2
        when /^\\(.*)$/m
          result += "\\"
          str = $1
        end
      end
      return(result + str)
    else
      return(self.dup)
    end
  end
end

#
#  グローバル変数の初期化
#
$kernel = nil
$apiTableFileNames = []
$supportDomain = false
$supportClass = false
$apiDefinition = {}

#
#  オプションの処理
#
OptionParser.new("Usage: genTecsCfg.rb [options] CONFIG-FILE", 40) do |opt|
  opt.on("-k KERNEL", "--kernel KERNEL", "kernel profile name") do |val|
    $kernel = val
  end
  opt.on("--api-table API-TABLE-FILE", "static API table file") do |val|
    $apiTableFileNames.push(val)
  end
  opt.on("--enable-domain", "enable DOMAIN support") do
    $supportDomain = true
  end
  opt.on("--enable-class", "enable CLASS support") do
    $supportClass = true
  end
  opt.on("-h", "--help", "show help (this)") do
    puts(opt.help)
    exit(0)
  end
  opt.parse!(ARGV)
end
$configFileNames = ARGV

#
#  カーネルオプションの処理
#
case $kernel
when /^hrp/
  $supportDomain = true
when /^fmp/
  $supportClass = true
when /^hrmp/
  $supportDomain = true
  $supportClass = true
end

#
#  静的APIテーブルの読み込み
#
def ReadApiTableFile
  $apiTableFileNames.each do |apiTableFileName|
    if /^(.+):(\w+)$/ =~ apiTableFileName
      apiTableFileName = $1
      apiPhase = $2.to_sym
    end

    if !File.exist?(apiTableFileName)
      error_exit("`#{apiTableFileName}' not found")
      next
    end

    apiFile = File.open(apiTableFileName)
    apiFile.each do |line|
      next if /^#/ =~ line			# コメントをスキップ

      fields = line.split(/\s+/)	# フィールドに分解

      apiName = fields.shift		# API名の取り出し
      if /^(.+)\[(.+)\]$/ =~ apiName
        apiName = $1
        apiDef = { APINAME: apiName, API: $2 }
      else
        apiDef = { APINAME: apiName, API: apiName }
      end
      if !apiPhase.nil?
        apiDef[:PHASE] = apiPhase
      end

      apiParams = []
      fields.each do |param|
        case param
        when /^(\W*)(\w+)(\W*)$/
          prefix = $1
          name = $2
          postfix = $3
          apiParam = { :NAME => name }

          case prefix
          when "#"					# オブジェクト識別名（定義）
            apiParam[:ID_DEF] = true
          when "%"					# オブジェクト識別名（参照）
            apiParam[:ID_REF] = true
          when "."					# 符号無し整数定数式パラメータ
            apiParam[:EXPTYPE] = "unsigned_t"
          when "+"					# 符号付き整数定数式パラメータ
            apiParam[:EXPTYPE] = "signed_t"
            apiParam[:SIGNED] = true
          when "^"					# ポインタ整数定数式パラメータ
            apiParam[:EXPTYPE] = "uintptr_t"
            apiParam[:INTPTR] = true
          when "&"					# 一般整数定数式パラメータ
            # do nothing
          when "$"					# 文字列定数式パラメータ
            apiParam[:STRING] = true
            apiParam[:EXPTYPE] = "char *"
          else
            error_exit("`#{param}' is invalid")
          end

          case postfix
          when "*"					# キーを決めるパラメータ
            apiDef[:KEYPAR] = name
          when "?"					# オプションパラメータ
            apiParam[:OPTIONAL] = true
          when "\.\.\."				# リストパラメータ
            apiParam[:LIST] = true
          end
        
        when "{"					# {
          apiParam = { :BRACE => "{" }
        when "{?"					# {?
          apiParam = { :BRACE => "{", :OPTBRACE => true }

        when "}"					# }
          apiParam = { :BRACE => "}" }

        else
          error_exit("`#{param}' is invalid")
        end
        apiParams.push(apiParam)
      end
      apiDef[:PARAM] = apiParams
      $apiDefinition[apiName] = apiDef
    end
    apiFile.close
  end
end

#
#  システムコンフィギュレーションファイルからの読み込みクラス
#
class ConfigFile
  def initialize(fileName)
    @cfgFileName = fileName
    begin
      @cfgFile = File.open(@cfgFileName)
    rescue Errno::ENOENT, Errno::EACCES => ex
      abort(ex.message)
    end
    @lineNo = 0
    @withinComment = false
  end

  def close
    @cfgFile.close
  end

  def getNextLine(withinApi)
    line = @cfgFile.gets
    return(nil) if line.nil?

	line.encode!("UTF-16BE", "UTF-8",	# 不正なバイト列を除外する
					:invalid => :replace,
					:undef => :replace,
					:replace => '?').encode!("UTF-8")
    @lineNo += 1

    line.chomp!
    if @withinComment
      case line
      when /\*\//						# C言語スタイルのコメント終了
        line.sub!(/^.*?\*\//, "")		# 最初の*/にマッチさせる */
        @withinComment = false
      else
        line = ""
      end
    end
    if !@withinComment
      line.gsub!(/\/\*.*?\*\//, "")		# C言語スタイルのコメントの除去
										# 最初の*/にマッチさせる */
      case line
      when /^\s*#/						# プリプロセッサディレクティブ
        if withinApi
          parse_error(self, \
					"preprocessor directive must not be within static API")
          line = ""
        end
      when /\/\*/						# C言語スタイルのコメント開始
        line.sub!(/\/\*.*$/, "")
        @withinComment = true
      when /\/\//						# C++言語スタイルのコメント
        line.sub!(/\/\/.*$/, "")
      end
    end
    return(line)
  end

  def getFileName
    return(@cfgFileName)
  end

  def getLineNo
    return(@lineNo)
  end
end

#
#  システムコンフィギュレーションファイルのパーサークラス
#
class CfgParser
  @@lastApiIndex = 0
  @@currentDomain = nil
  @@currentClass = nil
  @@nestDC = []

  def initialize
    @line = ""
    @skipComma = false						# 次が,であれば読み飛ばす
  end

  #
  #  文字列末まで読む
  #
  def parseString(cfgFile)
    string = ""
    begin
      case @line
      when /^([^"]*\\\\)(.*)$/				# \\まで読む
        string += $1
        @line = $2
      when /^([^"]*\\\")(.*)$/				# \"まで読む
        string += $1
        @line = $2
      when /^([^"]*\")(.*)$/				# "まで読む
        string += $1
        @line = $2
        return(string)
      else									# 行末まで読む
        string += @line + "\n"
        @line = cfgFile.getNextLine(true)
      end
    end while (@line)
    error_exit("unterminated string meets end-of-file")
    return(string)
  end

  #
  #  文字末まで読む
  #
  def parseChar(cfgFile)
    string = ""
    begin
      case @line
      when /^([^']*\\\\)(.*)$/				# \\まで読む
        string += $1
        @line = $2
      when /^([^']*\\\')(.*)$/				# \'まで読む
        string += $1
        @line = $2
      when /^([^']*\')(.*)$/				# 'まで読む
        string += $1
        @line = $2
        return(string)
      else									# 行末まで読む
        string += @line + "\n"
        @line = cfgFile.getNextLine(true)
      end
    end while (@line)
    error_exit("unterminated string meets end-of-file")
    return(string)
  end

  #
  #  改行と空白文字を読み飛ばす
  #
  def skipSpace(cfgFile, withinApi)
    loop do
      return if @line.nil?						# ファイル末であればリターン
      @line.lstrip!								# 先頭の空白を削除
      return if @line != ""						# 空行でなければリターン
      @line = cfgFile.getNextLine(withinApi)	# 次の行を読む
    end
  end

  #
  #  次の文字まで読み飛ばす
  #
  def skipToToken(cfgFile, withinApi=true)
    skipSpace(cfgFile, withinApi)
    if @line.nil?							# ファイル末であればエラー終了
      error_exit("#{cfgFile.getFileName}: unexpeced end-of-file")
    end
  end

  #
  #  パラメータを1つ読む
  #
  # @lineの先頭からパラメータを1つ読んで，それを文字列で返す．読んだパ
  # ラメータは，@lineからは削除する．パラメータの途中で行末に達した時は，
  # cfgFileから次の行を取り出す．ファイル末に達した時は，nilを返す．
  #
  def parseParam(cfgFile)
    param = ""								# 読んだ文字列
    parenLevel = 0							# 括弧のネストレベル
    skipComma = @skipComma
    @skipComma = false

    skipToToken(cfgFile)					# 次の文字まで読み飛ばす
    begin
      if parenLevel == 0
        case @line
        when /^(\s*,)(.*)$/					# ,
          @line = $2
          if param == "" && skipComma
            skipComma = false
            return(parseParam(cfgFile))		# 再帰呼び出し
          else
            return(param.strip)
          end
        when /^(\s*{)(.*)$/					# {
          if param != ""
            return(param.strip)
          else
            @line = $2
            return("{")
          end
        when /^(\s*\()(.*)$/				# (
          param += $1
          @line = $2
          parenLevel += 1
        when /^(\s*([)}]))(.*)$/			# }か)
          if param != ""
            return(param.strip)
          else
            @line = $3
            @skipComma = true if $2 == "}"
            return($2)
          end
        when /^(\s*\")(.*)$/				# "
          @line = $2
          param += $1 + parseString(cfgFile)
        when /^(\s*\')(.*)$/				# '
          @line = $2
          param += $1 + parseChar(cfgFile)
        when /^(\s*[^,{}()"'\s]+)(.*)$/		# その他の文字列
          param += $1
          @line = $2
        else								# 行末
          param += " "
          @line = cfgFile.getNextLine(true)
        end
      else
        # 括弧内の処理
        case @line
        when /^(\s*\()(.*)$/				# "("
          param += $1
          @line = $2
          parenLevel += 1
        when /^(\s*\))(.*)$/				# ")"
          param += $1
          @line = $2
          parenLevel -= 1
        when /^(\s*\")(.*)$/				# "
          @line = $2
          param += $1 + parseString(cfgFile)
        when /^(\s*\')(.*)$/				# '
          @line = $2
          param += $1 + parseChar(cfgFile)
        when /^(\s*[^()"'\s]+)(.*)$/		# その他の文字列
          param += $1
          @line = $2
        else								# 行末
          param += " "
          @line = cfgFile.getNextLine(true)
        end
      end
    end while (@line)
    return(param.strip)
  end

  def getParam(apiParam, param, cfgFile)
    if param == ""
      if !apiParam.has_key?(:OPTIONAL)
        parse_error(cfgFile, "unexpected `,'")
      end
      return(param)
    end

    if apiParam.has_key?(:ID_DEF) || apiParam.has_key?(:ID_REF)
      if (/^[A-Za-z_]\w*$/ !~ param)
        parse_error(cfgFile, "`#{param}' is illegal object ID")
      end
      return(param)
    end

    if apiParam.has_key?(:STRING_LITERAL)
      return(param.unquote)
    else
      return(param)
    end
  end

  def parseApi(cfgFile, apiName)
    # 静的APIの読み込み
    staticApi = {}
    tooFewParams = false
    skipUntilBrace = 0

    skipToToken(cfgFile)					# 次の文字まで読み飛ばす
    if (/^\((.*)$/ =~ @line)
      @line = $1

      staticApi[:APINAME] = apiName
      staticApi[:_FILE_] = cfgFile.getFileName
      staticApi[:_LINE_] = cfgFile.getLineNo
      apiDef = $apiDefinition[apiName]
      param = parseParam(cfgFile)

      apiDef[:PARAM].each do |apiParam|
        return(staticApi) if param.nil?		# ファイル末であればリターン

        if skipUntilBrace > 0
          # API定義を}までスキップ中
          if apiParam.has_key?(:BRACE)
            case apiParam[:BRACE]
            when "{"
              skipUntilBrace += 1
            when "}"
              skipUntilBrace -= 1
            end
          end
        elsif apiParam.has_key?(:OPTIONAL)
          if /^([{})])$/ !~ param
            store_param = getParam(apiParam, param, cfgFile)
            if store_param != ""
              staticApi[apiParam[:NAME]] = store_param
            end
            param = parseParam(cfgFile)
          end
        elsif apiParam.has_key?(:LIST)
          staticApi[apiParam[:NAME]] = []
          while /^([{})])$/ !~ param
            staticApi[apiParam[:NAME]].push(getParam(apiParam, param, cfgFile))
            param = parseParam(cfgFile)
            break if param.nil?				# ファイル末の場合
          end
        elsif apiParam.has_key?(:OPTBRACE)
          if param == apiParam[:BRACE]
            param = parseParam(cfgFile)
            break if param.nil?				# ファイル末の場合
          else
            if param == ""
              param = parseParam(cfgFile)
              break if param.nil?			# ファイル末の場合
            elsif /^([})])$/ !~ param
              parse_error(cfgFile, "`{...}' expected before #{param}")
            end
            skipUntilBrace += 1          	# API定義を}までスキップ
          end
        elsif !apiParam.has_key?(:BRACE)
          if /^([{})])$/ !~ param
            staticApi[apiParam[:NAME]] = getParam(apiParam, param, cfgFile)
            param = parseParam(cfgFile)
          elsif !tooFewParams
            parse_error(cfgFile, "too few parameters before `#{$1}'")
            tooFewParams = true
          end
        elsif param == apiParam[:BRACE]
          param = parseParam(cfgFile)
          tooFewParams = false
        else
          parse_error(cfgFile, "`#{apiParam[:BRACE]}' expected before #{param}")
          # )かファイル末まで読み飛ばす
          loop do
            param = parseParam(cfgFile)
            break if (param.nil? || param == ")")
          end
          break
        end
      end

      # 期待されるパラメータをすべて読んだ後の処理
      if param != ")"
        begin
          param = parseParam(cfgFile)
          return(staticApi) if param.nil?	# ファイル末であればリターン
        end while param != ")"
        parse_error(cfgFile, "too many parameters before `)'")
      end
    else
      parse_error(cfgFile, "syntax error: #{@line}")
      @line = ""
    end
    return(staticApi)
  end

  def parseOpenBrace(cfgFile)
    # {の読み込み
    skipToToken(cfgFile)					# 次の文字まで読み飛ばす
    if (/^\{(.*)$/ =~ @line)
      @line = $1
    else
      parse_error(cfgFile, "`{' expected before #{@line}")
    end
  end

  def parseFile(cfgFileName)
    cfgFiles = [ ConfigFile.new(cfgFileName) ]
    @line = ""
    loop do
      cfgFile = cfgFiles.last

      skipSpace(cfgFile, false)				# 改行と空白文字を読み飛ばす
      if @line.nil?
        # ファイル末の処理
        cfgFiles.pop.close
        if cfgFiles.empty?
          break								# パース処理終了
        else
          @line = ""						# 元のファイルに戻って続ける
        end
      elsif /^;(.*)$/ =~ @line
        # ;は読み飛ばす
        @line = $1
      elsif /^#/ =~ @line
        # プリプロセッサディレクティブを読む
        case @line
        when /^#(include|ifdef|ifndef|if|endif|else|elif)\b/
          directive = {}
          directive[:DIRECTIVE] = @line.strip
          directive[:_FILE_] = cfgFile.getFileName
          directive[:_LINE_] = cfgFile.getLineNo
          $cfgFileInfo.push(directive)
        else
          parse_error(cfgFile, "unknown preprocessor directive: #{@line}")
        end
        @line = ""
      elsif (/^([A-Z_][A-Z0-9_]*)\b(.*)$/ =~ @line)
        apiName = $1
        @line = $2

        case apiName
        when "KERNEL_DOMAIN"
          if !$supportDomain
            parse_warning(cfgFile, "`KERNEL_DOMAIN' is not supported")
          end
          if !@@currentDomain.nil?
            parse_error(cfgFile, "`DOMAIN' must not be nested")
          end
          @@currentDomain = "TDOM_KERNEL"
          parseOpenBrace(cfgFile)
          @@nestDC.push("domain")
        when "DOMAIN"
          if !$supportDomain
            parse_warning(cfgFile, "`DOMAIN' is not supported")
          end
          if !@@currentDomain.nil?
            parse_error(cfgFile, "`DOMAIN' must not be nested")
          end
          domid = parseParam(cfgFile).sub(/^\((.+)\)$/m, "\\1").strip
          if (/^[A-Za-z_]\w*$/ !~ domid)
            parse_error(cfgFile, "`#{domid}' is illegal domain ID")
          else
            if !$domainId.has_key?(domid)
              if $inputObjid.has_key?(domid)
                # ID番号入力ファイルに定義されていた場合
                $domainId[domid] = $inputObjid[domid]
                if $domainId[domid] > 32
                  error_exit("domain ID for `#{domid}' is too large")
                end
              else
                $domainId[domid] = nil
              end
            end
            @@currentDomain = domid
          end
          parseOpenBrace(cfgFile)
          @@nestDC.push("domain")
        when "CLASS"
          if !$supportClass
            parse_warning(cfgFile, "`CLASS' is not supported")
          end
          if !@@currentClass.nil?
            parse_error(cfgFile, "`CLASS' must not be nested")
          end
          @@currentClass = parseParam(cfgFile).sub(/^\((.+)\)$/m, "\\1").strip
          @@classFile = cfgFile.getFileName
          @@classLine = cfgFile.getLineNo
          parseOpenBrace(cfgFile)
          @@nestDC.push("class")
        else
          if $apiDefinition.has_key?(apiName)
            # 静的APIを1つ読む
            staticApi = parseApi(cfgFile, apiName)
            if staticApi.empty?
              # ファイル末か文法エラー
            else
              # 静的APIの処理
              if !@@currentDomain.nil?
                staticApi[:DOMAIN] = @@currentDomain
              end
              if !@@currentClass.nil?
                staticApi[:CLASS] = @@currentClass
                staticApi[:CLASS_FILE_] = @@classFile
                staticApi[:CLASS_LINE_] = @@classLine
              end
              staticApi[:INDEX] = (@@lastApiIndex += 1)
              $cfgFileInfo.push(staticApi)
            end

            # ";"を読む
            skipToToken(cfgFile, false)		# 次の文字まで読み飛ばす
            if (/^\;(.*)$/ =~ @line)
              @line = $1
            else
              parse_error(cfgFile, "`;' expected after static API")
            end
          else
            parse_error(cfgFile, "unknown static API: #{apiName}")
          end
        end
      elsif (/^\}(.*)$/ =~ @line)
        # }の処理
        if @@nestDC.size > 0
          case @@nestDC.pop
          when "domain"
            @@currentDomain = nil
          when "class"
            @@currentClass = nil
          end
        else
          error_exit("unexpected `}'")
        end
        @line = $1
      else
        parse_error(cfgFile, "syntax error: #{@line}")
        @line = ""
      end
    end
  end
end

#
#  メイン処理
#

#
#  静的APIテーブルの読み込み
#
ReadApiTableFile()

#
#  システムコンフィギュレーションファイルの読み込み
#
$cfgFileInfo = []
$domainId = { "TDOM_KERNEL" => -1, "TDOM_NONE" => -2 }
$configFileNames.each do |configFileName|
  CfgParser.new.parseFile(configFileName)
end
abort if $errorFlag					# エラー発生時はabortする

#
#  拡張情報の対応（Zigの不具合対応）
#
$exinfTables = {}
$cfgFileInfo.each do |cfgInfo|
  if cfgInfo.has_key?("exinf")
    if cfgInfo["exinf"] =~ /^\&([a-zA-Z_]+)_tab\[([0-9]+)\]$/
      cfgInfo[:exinf] = "&p_#{$1}_tab[#{$2}]"
      $exinfTables[$1] = true
    else
      cfgInfo[:exinf] = cfgInfo["exinf"].sub("NULL", "null")
    end
  end
end

#
#  Zigファイルの生成処理
#
$outputFileName = $configFileNames[0].sub(/\.cfg$/, "_cfg.zig")
$zigcfg = GenFile.new($outputFileName)

$zigcfg.append(<<EOS)
// #{$outputFileName}

usingnamespace @import("../" ++ SRCDIR ++ "/kernel/kernel_cfg.zig");

usingnamespace @cImport({
    @cDefine("UINT_C(val)", "val");
EOS

# @cInclude記述の生成
$cfgFileInfo.each do |cfgInfo|
  if cfgInfo.has_key?(:DIRECTIVE)
    if cfgInfo[:DIRECTIVE] =~ /#include (.+)$/
      $zigcfg.add("    @cInclude(#{$1});");
    end
  end
end
$zigcfg.add2("});");

# 拡張情報の対応記述の生成（Zigの不具合対応）
$exinfTables.each do |exinfTable, _|
  $zigcfg.add("const p_#{exinfTable}_tab = " \
				"importSymbol([100]#{exinfTable}, \"#{exinfTable}_tab\");")
end
$zigcfg.add
# 通知ハンドラに対する拡張情報の対応記述の生成（Zigの不具合対応）
#$nfyExinfTables.each do |nfyExinfTable, _|
#  $zigcfg.add("const p_#{nfyExinfTable} = " \
#				"importSymbol(usize, \"#{nfyExinfTable}\");")
#end
#$zigcfg.add

# 静的APIに対応する記述の生成
$zigcfg.add("pub fn configuration(comptime cfg: *CfgData) void {");
$cfgFileInfo.each do |cfgInfo|
  if cfgInfo.has_key?(:APINAME)
    $zigcfg.append("    cfg.#{cfgInfo[:APINAME]}(")
    case cfgInfo[:APINAME]
    when "CRE_TSK"
      $zigcfg.append("\"#{cfgInfo["tskid"]}\", CTSK(")
      $zigcfg.append("#{cfgInfo["tskatr"]}, ")
      $zigcfg.append("#{cfgInfo[:exinf]}, ")
      $zigcfg.append("#{cfgInfo["task"]}, ")
      $zigcfg.append("#{cfgInfo["itskpri"]}, ")
      $zigcfg.append("#{cfgInfo["stksz"]}, ")
      $zigcfg.append("#{cfgInfo["stk"].sub("NULL", "null")})")

    when "CRE_SEM"
      $zigcfg.append("\"#{cfgInfo["semid"]}\", CSEM(")
      $zigcfg.append("#{cfgInfo["sematr"]}, ")
      $zigcfg.append("#{cfgInfo["isemcnt"]}, ")
      $zigcfg.append("#{cfgInfo["maxsem"]})")

    when "CRE_FLG"
      $zigcfg.append("\"#{cfgInfo["flgid"]}\", CFLG(")
      $zigcfg.append("#{cfgInfo["flgatr"]}, ")
      $zigcfg.append("#{cfgInfo["iflgptn"]})")

    when "CRE_DTQ"
      $zigcfg.append("\"#{cfgInfo["dtqid"]}\", CDTQ(")
      $zigcfg.append("#{cfgInfo["dtqatr"]}, ")
      $zigcfg.append("#{cfgInfo["dtqcnt"]}, ")
      $zigcfg.append("#{cfgInfo["dtqmb"].sub("NULL", "null")})")

    when "CRE_PDQ"
      $zigcfg.append("\"#{cfgInfo["pdqid"]}\", CPDQ(")
      $zigcfg.append("#{cfgInfo["pdqatr"]}, ")
      $zigcfg.append("#{cfgInfo["pdqcnt"]}, ")
      $zigcfg.append("#{cfgInfo["maxdpri"]}, ")
      $zigcfg.append("#{cfgInfo["pdqmb"].sub("NULL", "null")}")

    when "CRE_MTX"
      $zigcfg.append("\"#{cfgInfo["mtxid"]}\", CMTX(")
      $zigcfg.append("#{cfgInfo["mtxatr"]}, ")
      $zigcfg.append("#{cfgInfo["ceilpri"]})")

    when "CRE_MPF"
      $zigcfg.append("\"#{cfgInfo["mpfid"]}\", CMPF(")
      $zigcfg.append("#{cfgInfo["mpfatr"]}, ")
      $zigcfg.append("#{cfgInfo["blkcnt"]}, ")
      $zigcfg.append("#{cfgInfo["blksz"]}, ")
      $zigcfg.append("#{cfgInfo["mpf"].sub("NULL", "null")}, ")
      $zigcfg.append("#{cfgInfo["mpfmb"].sub("NULL", "null")})")

    when "CRE_CYC"
      $zigcfg.append("\"#{cfgInfo["cycid"]}\", CCYC(")
      $zigcfg.append("#{cfgInfo["cycatr"]}, ")
      $zigcfg.append("NFYINFO(.{ ")
      $zigcfg.append("#{cfgInfo["nfymode"]}")
      $zigcfg.append(", #{cfgInfo["par1"]}") if cfgInfo.has_key?("par1")
      $zigcfg.append(", #{cfgInfo["par2"]}") if cfgInfo.has_key?("par2")
      $zigcfg.append(", #{cfgInfo["par3"]}") if cfgInfo.has_key?("par3")
      $zigcfg.append(", #{cfgInfo["par4"]}") if cfgInfo.has_key?("par4")
      $zigcfg.append(" }, cfg), ")
      $zigcfg.append("#{cfgInfo["cyctim"]}, ")
      $zigcfg.append("#{cfgInfo["cycphs"]})")

    when "CRE_ALM"
      $zigcfg.append("\"#{cfgInfo["almid"]}\", CALM(")
      $zigcfg.append("#{cfgInfo["almatr"]}, ")
      $zigcfg.append("NFYINFO(.{ ")
      $zigcfg.append("#{cfgInfo["nfymode"]}")
      $zigcfg.append(", #{cfgInfo["par1"]}") if cfgInfo.has_key?("par1")
      $zigcfg.append(", #{cfgInfo["par2"]}") if cfgInfo.has_key?("par2")
      $zigcfg.append(", #{cfgInfo["par3"]}") if cfgInfo.has_key?("par3")
      $zigcfg.append(", #{cfgInfo["par4"]}") if cfgInfo.has_key?("par4")
      $zigcfg.append(" }, cfg))")

    when "CFG_INT"
      $zigcfg.append("#{cfgInfo["intno"]}, CINT(")
      $zigcfg.append("#{cfgInfo["intatr"]}, ")
      $zigcfg.append("#{cfgInfo["intpri"]})")

    when "CRE_ISR"
      $zigcfg.append("\"#{cfgInfo["isrid"]}\", CISR(")
      $zigcfg.append("#{cfgInfo["isratr"]}, ")
      $zigcfg.append("#{cfgInfo[:exinf]}, ")
      $zigcfg.append("#{cfgInfo["intno"]}, ")
      $zigcfg.append("#{cfgInfo["isr"]}, ")
      $zigcfg.append("#{cfgInfo["isrpri"]})")

    when "DEF_INH"
      $zigcfg.append("#{cfgInfo["inhno"]}, DINH(")
      $zigcfg.append("#{cfgInfo["inhatr"]}, ")
      $zigcfg.append("#{cfgInfo["inthdr"]})")

    when "DEF_EXC"
      $zigcfg.append("#{cfgInfo["excno"]}, DEXC(")
      $zigcfg.append("#{cfgInfo["excatr"]}, ")
      $zigcfg.append("#{cfgInfo["exchdr"]})")

    when "DEF_ICS"
      $zigcfg.append("DICS(#{cfgInfo["istksz"]}, ")
      $zigcfg.append("#{cfgInfo["istk"].sub("NULL", "null")})")

    when "ATT_INI"
      $zigcfg.append("AINI(#{cfgInfo["iniatr"]}, ")
      $zigcfg.append("#{cfgInfo[:exinf]}, ")
      $zigcfg.append("#{cfgInfo["inirtn"]})")

    when "ATT_TER"
      $zigcfg.append("ATER(#{cfgInfo["teratr"]}, ")
      $zigcfg.append("#{cfgInfo[:exinf]}, ")
      $zigcfg.append("#{cfgInfo["terrtn"]})")

    else
      error_exit("`#{cfgInfo[:APINAME]}' is not supported")
    end
    $zigcfg.add(");")
  end
end
$zigcfg.add("}")

#
#  作成したすべてのファイルを出力する
#
GenFile.output
