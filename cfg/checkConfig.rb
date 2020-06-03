#!/usr/bin/env ruby -Eutf-8 -w
# -*- coding: utf-8 -*-

if $0 == __FILE__
  TOOL_ROOT = File.expand_path(File.dirname(__FILE__)) + "/"
  $LOAD_PATH.unshift(TOOL_ROOT)
end

require "pp"
require "optparse"
require "SRecord.rb"

#
#  タイムスタンプファイルの指定
#
$timeStampFileName = "check.timestamp"

#
#  定数定義
#
CHECK_DEFS_MAGIC_NUM = "check.TOPPERS_magic_number"

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

#
#  インクルードパスからファイルを探す
#
def SearchFilePath(fileName)
  if File.exist?(fileName)
    # 指定したファイルパスに存在する
    return fileName
  elsif /^\./ =~ fileName
    # 相対パスを指定していて見つからなかった場合，存在しないものとする
    #（意図しないファイルが対象となることを防止）
    return nil
  else
    # 各インクルードパスからファイル存在チェック
    $includeDirectories.each do |includeDirectory|
      path = includeDirectory + "/" + fileName
      # 見つかったら相対パスを返す
      if File.exist?(path)
        return path
      end
    end
    return nil
  end
end

#
#  指定した生成スクリプト（trbファイル）を検索してloadする
#
def IncludeTrb(fileName)
  filePath = SearchFilePath(fileName)
  if filePath.nil?
    error_exit("`#{fileName}' not found")
  else
    load(filePath)
  end
end

#
#  グローバル変数の初期化
#
$includeDirectories = []
$trbFileNames = []
$romImageFileName = nil
$romSymbolFileName = nil

#
#  オプションの処理
#
OptionParser.new("Usage: checkConfig.rb [options] OBJ-NAME CHECK-NAME",
																40) do |opt|
  opt.on("-I DIRECTORY", "--include-directory DIRECTORY",
										"include directory") do |val|
    $includeDirectories.push(val)
  end
  opt.on("-T TRB-FILE", "--trb-file TRB-FILE",
         "generation script (trb file)") do |val|
    $trbFileNames.push(val)
  end
  opt.on("--rom-image SREC-FILE", "rom image file (s-record)") do |val|
    $romImageFileName = val
  end
  opt.on("--rom-symbol SYMS-FILE", "rom symbol table file (nm)") do |val|
    $romSymbolFileName = val
  end
  opt.on("-h", "--help", "show help (this)") do
    puts(opt.help)
    exit(0)
  end
  opt.parse!(ARGV)
end
$checkName = ARGV[0]

#
#  シンボルファイルの読み込み
#
#  以下のメソッドは，GNUのnmが生成するシンボルファイルに対応している．
#  別のツールに対応する場合には，このメソッドを書き換えればよい．
#
def ReadSymbolFile(symbolFileName)
  begin
    symbolFile = File.open(symbolFileName)
  rescue Errno::ENOENT, Errno::EACCES => ex
    abort(ex.message)
  end

  symbolAddress = {}
  symbolFile.each do |line|
    # スペース区切りで分解
    fields = line.split(/\s+/)

    # 3列になっていない行は除外
    if fields.size == 3
      symbolAddress[fields[2]] = fields[0].hex
    end
  end
  symbolFile.close
  return(symbolAddress)
end

#
#  生成スクリプト（trbファイル）向けの関数
#
def SYMBOL(symbol, contFlag = false)
  if !$romSymbol.nil? && $romSymbol.has_key?(symbol)
    return $romSymbol[symbol]
  elsif contFlag
    return nil
  else
    error_exit("E_SYS: symbol `#{symbol}' not found")
  end
end

def BCOPY(fromAddress, toAddress, size)
  if !$romImage.nil?
    copyData = $romImage.get_data(fromAddress, size)
    if !copyData.nil?
      $romImage.set_data(toAddress, copyData)
    end
  end
end

def BZERO(address, size)
  if !$romImage.nil?
    $romImage.set_data(address, "00" * size)
  end
end

def PEEK(address, size, signed=false)
  if !$romImage.nil?
    return $romImage.get_value(address, size, signed)
  else
    return nil
  end
end

#
#  チェック記述ファイルの読み込み
#
$checkSymbol = ReadSymbolFile($checkName + ".syms")
$checkImage = SRecord.new($checkName + ".srec")

#
#  エンディアンの判定
#
magicNumberAddress = $checkSymbol[CHECK_DEFS_MAGIC_NUM]
unless magicNumberAddress
  abort("`#{CHECK_DEFS_MAGIC_NUM}' not found")
end
magicNumberData = $checkImage.get_data(magicNumberAddress, 4)
if (magicNumberData == "12345678")
  $endianLittle = false
elsif (magicNumberData == "78563412")
  $endianLittle = true
else
  abort("`TOPPERS_magic_number' is invalid in `#{checkName}'")
end

#
#  チェック記述ファイルからの定義の取り込み
#
$checkSymbol.each do |symbol, address|
  if symbol =~ /^check\.(.+)$/ && symbol != CHECK_DEFS_MAGIC_NUM
    name = $1
    value = $checkImage.get_value(address, 4, false)
    eval("$#{name} = #{value}")
  end
end

#
#  指定されたシンボルファイルの読み込み
#
if !$romSymbolFileName.nil?
  if File.exist?($romSymbolFileName)
    $romSymbol = ReadSymbolFile($romSymbolFileName)
  else
    error_exit("`#{$romSymbolFileName}' not found")
  end
end

#
#  指定されたSレコードファイルの読み込み
#
if !$romImageFileName.nil?
  if File.exist?($romImageFileName)
    $romImage = SRecord.new($romImageFileName)
  else
    error_exit("`#{$romImageFileName}' not found")
  end
end

#
#  生成スクリプト（trbファイル）を実行する
#
$trbFileNames.each do |trbFileName|
  IncludeTrb(trbFileName)
end

# エラー発生時はabortする
if $errorFlag
  abort()
end

# 
#  タイムスタンプファイルの生成
# 
if !$timeStampFileName.nil?
  File.open($timeStampFileName, "w").close
end
