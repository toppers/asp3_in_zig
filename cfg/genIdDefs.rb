#!/usr/bin/env ruby -Eutf-8 -w
# -*- coding: utf-8 -*-

if $0 == __FILE__
  TOOL_ROOT = File.expand_path(File.dirname(__FILE__)) + "/"
  $LOAD_PATH.unshift(TOOL_ROOT)
end

require "pp"
require "optparse"
require "GenFile.rb"
require "SRecord.rb"

#
#  定数定義
#
ID_DEFS_MAGIC_NUM = "id.TOPPERS_magic_number"

#
#  オプションの処理
#
OptionParser.new("Usage: getIdDefs.rb [options] OBJ-NAME", 40) do |opt|
  opt.on("-h", "--help", "show help (this)") do
    puts(opt.help)
    exit(0)
  end
  opt.parse!(ARGV)
end
$objectName = ARGV[0]

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
#  オブジェクトファイルの読み込み
#
$objectSymbol = ReadSymbolFile($objectName + ".syms")
$objectImage = SRecord.new($objectName + ".srec")

#
#  エンディアンの判定
#
magicNumberAddress = $objectSymbol[ID_DEFS_MAGIC_NUM]
unless magicNumberAddress
  abort("`#{ID_DEFS_MAGIC_NUM}' not found")
end
magicNumberData = $objectImage.get_data(magicNumberAddress, 4)
if (magicNumberData == "12345678")
  $endianLittle = false
elsif (magicNumberData == "78563412")
  $endianLittle = true
else
  abort("`TOPPERS_magic_number' is invalid in `#{objectName}'")
end

#
#  kernel_cfg.hの先頭部分生成
#
$kernelCfgH = GenFile.new("kernel_cfg.h")
$kernelCfgH.add(<<EOS)
/* kernel_cfg.h */
#ifndef TOPPERS_KERNEL_CFG_H
#define TOPPERS_KERNEL_CFG_H
EOS

#
#  ID等のマクロ定義の生成
#
$objectSymbol.each do |symbol, address|
  if symbol =~ /^id\.(.+)$/ && symbol != ID_DEFS_MAGIC_NUM
    name = $1
    id = $objectImage.get_value(address, 4, false)
    $kernelCfgH.add("#define #{name} #{id}");
  end
end

#
#  kernel_cfg.hの末尾部分の生成
#
$kernelCfgH.append(<<EOS)

#endif /* TOPPERS_KERNEL_CFG_H */
EOS

#
#  作成したすべてのファイルを出力する
#
GenFile.output
