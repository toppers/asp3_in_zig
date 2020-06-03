                        README
           Xilnx SDK用プロジェクト（ZYBO-Z7)

        2017-2019 (C) Shinya Honda honda@ertl.jp

----------------
About
----------------
本フォルダはXilinx SDKによりZYBO向けにFMP3をビルドして実行するための手
順をまとめたものである．

----------------
Host environment
----------------
動作確認したホストOSのバージョンは次の通りである．

  - Windows 10 64bit
  
  
動作確認したXilinx SDKのバージョンは次の通りである．  

  - Xilinx SDK 2019.1

----------------
Board Settig
----------------
Xilinx SDK で動作させるため，ボードは次の設定とする．

  - JP5 : JTAG

----------------
Board Selection
----------------
ディフォルトではZybo-Z7-10をターゲットとしている．Zybo-Z7-20を使用する
場合には，フォルダzybo_z7_hwの名前をzybo_z7_10_hw と変更し，フォルダ
zybo_z7_20_hwの名前をzybo_z7_hwに変更すること．

----------------
Build instructions
----------------
FMP3カーネルのダウンロードと展開．

ワークスペースの作成
 - Xilinx SDKを起動してワークスペースを新規に作成する．
 - File -> Import... を選択
 - General -> Existing Projects int Workspace を選択
 - Select root directoryに本フォルダを指定．
 - sample1/zybo_z7_hw/ca9_1/ca9_0_bsp/ca9_1_bspをインポート

ビルド
 - Project Exploer から sample1 を選択
 - Build Projectを選択
   - ビルドが開始される

デバッグ
 - ボードのPROG UARTとPCを接続
 - sample1のツリーを展開
 - sample1のツリーにある sample1.launchを右クリックして，
   Debug as -> fmp_sample1 を選択
   - 2回目以降はデバッグアイコンからから可能
 - ロード終了後 APU を選択して，Resumeボタンにより実行

----------------
各プロジェクトの説明
----------------
sample1
・サンプルプロジェクトのビルド用プロジェクト
ca9_0_bsp
・Cortex-A9コア0用のダミーBSP
zybo_z7_hw
・Hardware Platform Specification (Vivadoからexportしたsystem.hdfから生成)

ca9_0_bsp/ca9_1_bspはデバッガでCortex-A9コア0/Cortex-A9コア1にロードす
るプロジェクトを選択するために用意している．

ca9_1はデバッガでCortex-A9コア1にロードするためのダミーのプロジェクト
であり，sample1でビルドfmp.elfがsample1の一つ上のフォルダにコピーされ
るため，このファイルをca9_1以下にコピーしてロードする．

----------------
新規プロジェクトの作成
----------------

1. sample1と同じ階層にフォルダを作成してsample1以下のMakefileとその他必要
   なファイルをコピーする．
      
2. プロジェクトの新規作成を行い，Makefile Project with Existing Code 
   により作成したフォルダを指定する．
   
3. 作成したプロジェクトのプロパティを変更してca9_0に関連づける．

4. ビルド後デバッグのコンフィギュレーションを作成して，Cortex-A9コア0
   に作成したプロジェクトとその下のfmp.elfを指定し，Cortex-A9コア1に
   ca9_1を指定して，その下fmp.elfを指定する．

------------------
Change Log
------------------
- 2019/08/28
 - Zybo Z7 対応
 - Xilinx SDK 2019.1 で動作確認
 
- 2017/12/15
 - Xilinx SDK 2017.3 対応

- 2017/02/18
 - 新規作成
