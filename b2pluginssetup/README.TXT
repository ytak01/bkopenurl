%temp%\

bkpiinst.exe BkOpenURL

---------------------------------------------------------------------
Becky! Internet Mail Version 2 用 汎用プラグインインストーラ
---------------------------------------------------------------------

このプログラムはBecky! Internet Mail Version 2(以降B2)専用のプラグイン
簡易インストーラです。

開発コンセプトは「PC初心者にとって優しい」です。
2種類のインストーラがあり、それぞれに特徴があります。
貴方のお好みによって、どちらを使うか選択してください。

●●●●● 特徴 ●●●●●
[共通]
・初心者に優しい
・アンインストールもできる
・インストーラのメッセージは日英バイリンガル
・貴方のプラグインドキュメントが日英両方とも用意してあれば、自動的にどち
  らかを表示させることが可能

[bkpiinst.exe]
・レジストリを使用しません。
・ダイアログを使用していて取っ付きやすい。
・プラグインのアンインストールは直接 B2 インストールフォルダにある bkpiinst.
  exe を起動して行う。
・アンインストール用にプラグインインストールフォルダの親フォルダ (B2 のイン
  ストールフォルダ又はデータフォルダ) に inf ファイルの拡張子を pul に変更
  したものを作成する。

[bpisetup.exe]
・[コントロールパネル]の[アプリケーションの追加と削除]に登録される。(これ
  のために、必然的にレジストリへの書き込みが行われます。これ以外でレジス
  トリへの書き込みは行いません)
・普通にインストールする際は「はい」だけを押していけばOK。
・サイズが小さい。
・アンインストール用にB2 のインストールフォルダにinfファイルを作成する。

●●●●● 動作 ●●●●●
[共通]
まず、インストーラ起動時にB2が実行中であった場合、B2を終了させます。
B2の終了は、最長15秒間待ちます。
その後、ユーザーの指示に従ってインストール又は、解凍を行います。
インストール作業は、infファイルの記述に従って行います。

プラグインのインストール後、自分自身を B2 のインストールフォルダにコピー
します。このファイルは、手動で削除しない限り削除されません。

アンインストール用にデータ(inf又はpul)を作成します。
インストール終了後、指示があればB2を起動します。

[bkpiinst.exe]
インストール/アンインストール時、まず dll ファイルの削除を試みて失敗すれ
ば作業を中断します。
インストール終了後、指示があればデスクトップにショートカットを作成します。

[bpisetup.exe]
初めてそのプラグインをインストールする際は、データフォルダに PlugIns フォ
ルダがある場合は、B2\PlugIns または データフォルダ\PlugIns のどちらにイン
ストールするか選択できます。2回目以降は B2\PlugIns → データフォルダ
\PlugIns の順でそのプラグインがインストールされているかどうかを検索し、先
に見つかった方を自動的にアップデート(上書き)します。

●●●●● 注意事項 ●●●●●
[bkpiinst.exe]
・マルチユーザー環境下で B2 インストールフォルダ下の PlugIns フォルダに
  Plugin をインストールした場合、他のユーザーからアンインストール出来てしま
  います。
・pul ファイルはインストールに使用した、inf ファイルの拡張子を変更したもの
  になりますので inf ファイルのファイル名にはユニークな名前を使用するように
  して下さい。

[bpisetup.exe]
・B2のインストールフォルダを得るために、必ずB2がセットアッププログラムで
  正しくインストールされている必要があります。具体的には B2のアンインストー
  ル情報から、 B2のインストールフォルダを得ています。もし B2のアンインス
  トール情報がなかったらこのインストーラは解凍のみしかできません。 (手動
  でインストールする必要がある)　B2 を WinNT などの User 権限でインストー
  ルした際は、B2 のアンインストール情報は作成されません。ただし、bpisetup
  でインストールする際は、必ずしも Administrator権限である必要はありませ
  ん。(ただしアンインストール情報は当然作成されません)

●●●●● 使用条件 ●●●●●

何もありません。(^^; ご自由にお使いください。
私たちに使用許諾の連絡を入れる必要もありませんし、貴方のプラグインのドキュ
メントに記述する義務もありません。
もちろん「インストーラに関しての質問を受けたくない」ということで、私たち
の連絡先を入れても構いません。その際は、貴方の使用したインストーラによっ
て、下記のどちらかを書いていただければ結構です。(^^;
・bkpiinst.exe …… 上村亮 mailto:auemura@abox4.so-net.ne.jp
・bpisetup.exe …… しののん mailto:shinonon@par.allnet.ne.jp

●●●●● インストーラの作成 ●●●●●
貴方のプラグインのインストーラを作るには、infファイルを作成する必要があり
ます。infファイルの書式については、inf.txtを参照して下さい。
infファイルは両インストーラで共通で使用可能です。

そして、そのinfファイル＋あなたのプラグインDLL＋ドキュメント類＋プラグイ
ンセットアッププログラムをまとめて自己解凍形式で圧縮し、インストーラの実
行時コマンドラインに infファイル名(拡張子は不要)を指定します。
自己解凍形式にCABを使うことにより、一時解凍ファイルを自動的に削除できるよ
うになるため、自己解凍CAB形式を選択なされる事を推奨します。

●LHMeltを使った自己解凍CAB形式LargeAttachプラグインインストーラの作り方
※LHMeltはMicco氏作のフリーウェア
※CAB32.DLLは宮内 邦昭氏作のフリーウェア
※いずれも http://www.csdinc.co.jp/archiver/ からダウンロードできます

・LHMeltを起動する
・その他→書庫の設定→CAB書庫の設定で、
  ＊圧縮形式＝LZX
  ＊圧縮レベル＝21
  ＊ボリュームサイズ＝0
・ファイル→種類を指定して新規書庫→CAB書庫、で新規CAB書庫を作成
・LargeAttach.dll,LargeAttach.txt,LargeAttach.inf,bpisetup.exe (または
  bkpiinst.exe)をエクスプローラからLHMeltのウィンドウにD&D
・編集→自己解凍書庫の作成で以下の設定をしてOKを押す
  ＊標準の解凍先フォルダの欄＝%temp%\
  ＊「解凍時に解凍先フォルダを問い合わせない」にチェック
  ＊解凍後、実行または開くファイル名＝bpisetup.exe LargeAttach
                                   or bkpiinst.exe LargeAttach
				      bkpiinst.exe BkOpenURL
  ＊「プログラム終了後、解凍されたファイルを削除する」にチェック
  ＊他の欄は空欄
・作成された 新規書庫.exe を bpilai10.exe にファイル名を変更
・あとは bpilai10.exe を実行すればインストーラが起動します。

※Easy圧縮というソフト(http://www2s.biglobe.ne.jp/~yyyy/)を使うと、さらに
  サイズを小さくすることができます。基本的に、以下の指定をするようにして
  ください。
  ・解凍先に%temp%フォルダを指定して、フォルダを問い合わせなくする
  ・bpisetup.exeを自動起動するようにして、コマンドラインにinfファイル名
    (.infなし)を指定する
  ・実行後に解凍ファイルを削除するようにする

  参考までに、BkNewsプラグインの配布形式を変えた場合の、サイズの違いを以
  下に示します。LZH,ZIP 形式は bpisetup.exe, infファイルを含まないときの
  サイズです。
    LZH(lh5)……………………………314kB
    LZH(lh7)……………………………298kB
    ZIP(レベル9)………………………303kB
    LHMelt(CAB自己解凍,LZX-21)……318kB
    Easy圧縮(CAB自己解凍,LZX-21)…293kB


[連絡先]
[bpisetup.exe]
しののん
mailto:shinonon@par.allnet.ne.jp
http://user2.allnet.ne.jp/shinoda/

[bkpiinst.exe]
上村亮
mailto:auemura@abox4.so-net.ne.jp
http://www1.kcn.ne.jp/~ufbmf001/b2pin.html
