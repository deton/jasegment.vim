jasegment.vim - 日本語文章でのWORD移動(W,E,B)を文節単位にするスクリプト
=======================================================================

概要
----

jasegment.vimは、日本語文章でのWORD移動(W,E,B)を文節単位にするスクリプトです。
CaboChaやTinySegmenterを使って文節を区切ります。

日本語文章の編集において、VimのWORD移動(W,E,B)は使いづらい機能でした。

* &encodingがeuc-jpやcp932の場合は、
  word移動(w,e,b)とWORD移動(W,E,B)で違いがないため、
  W,E,Bの存在意味がなく、使い道がありませんでした。
* &encodingがutf-8の場合は、スペースが無いと改行まで移動するため、
  日本語文章での行内移動には使えませんでした。

そこで、WORD移動を日本語の文節単位にするjasegment.vimを作りました。

以下の特徴があります。
* ひらがなが連続する中から、ひらがなで始まる文節を認識可能。
  (文字種だけを見て、
  漢字の後の連続するひらがなをWORDとみなす方法では不可能)
* 英字とその後に連続するひらがなを、WORDとして扱う。

機能:
* 通常移動(countも対応)の他に、Visual modeや、
  dW/c2E/yB等のOperator-pending modeも対応。
* text-objectsでWORD選択を行うaW/iWも、文節で選択するようにします。
* カーソル行の文節開始位置に下線を表示するオプションあり。

![下線表示スクリーンショット](http://deton.github.com/jasegment.vim/jasegment.png)

文節区切り方法は、以下から選択可能です。
デフォルトは'knbc_bunsetu'。

* 外部プログラム使用
 * 'cabocha': [CaboCha](http://code.google.com/p/cabocha/)を使って文節区切り
```
区切りの | 違いは | 「最大データ数」など、 | カタカナ・記号・ASCII境界あたりでしか | わからない | ことが | あります。
```
 * ('mecab': 単語区切り: [MeCab](http://mecab.sourceforge.net/)を使用)
* [TinySegmenter](http://chasen.org/~taku/software/TinySegmenter/)
  をVimスクリプトに移植したものを使用。
  TinySegmenter用区切りデータは、
  [TinySegmenterMaker](http://shogo82148.github.com/blog/2012/11/23/tinysegmentermaker/)
  を使って学習。
 * 'knbc_bunsetu':
   [KNBコーパス](http://nlp.ist.i.kyoto-u.ac.jp/kuntt/#ga739fe2)から、
   文節区切りを学習させたデータ。
```
区切りの | 違いは | 「最大データ数」など、 | カタカナ・記号・ASCII境界あたりでしかわからないことが | あります。
```
 * 'wpci_bunsetu':
   Wikipediaデータの一部をCaboChaで文節区切りしたものを学習させたデータ。
```
区切りの | 違いは | 「最大データ数」など、 | カタカナ・記号・ASCII境界あたりでしかわから | ない | ことが | あります。
```
 * ('jeita': 単語区切り: TinySegmenterMakerに含まれる単語区切りデータ)
 * ('rwcp': 単語区切り: TinySegmenterに含まれる単語区切りデータ)
* Vimスクリプトで文字種をもとに区切り
 * 'endhira': ひらがなを終端とする文字列として分割
```
区切りの | 違いは | 「最大データ数」など、 | カタカナ・記号・ASCII境界あたりでしかわからないことがあります。
```
 * 'endhira_mbb': 'endhira'の分割に加え、ASCII文字との境界でも分割
```
区切りの | 違いは | 「最大データ数」など、 | カタカナ・記号・ | ASCII | 境界あたりでしかわからないことがあります。
```
 * 'nvi_m17n': nvi-m17nと同様の区切り
```
区切りの | 違いは「 | 最大データ | 数」 | など、 | カタカナ・ | 記号・ | ASCII | 境界あたりでしかわからないことがあります。
```
 * 'jvim3': jvim3と同様の区切り
```
区切りの違いは | 「 | 最大データ数 | 」 | など | 、 | カタカナ | ・ | 記号 | ・ | ASCII | 境界あたりでしかわからないことがあります | 。
```
 * 'mbboundary': ASCII文字とマルチバイト文字の境界で区切る
```
区切りの違いは「最大データ数」など、カタカナ・記号・ | ASCII | 境界あたりでしかわからないことがあります。
```
 * 'kutoten': 句読点を終端とする文字列として分割
```
区切りの違いは「最大データ数」など、 | カタカナ・記号・ASCII境界あたりでしかわからないことがあります。
```
 * 'nonblank': 英文のWORDと同様に、空白文字(全角空白含む)で区切る
```
区切りの違いは「最大データ数」など、カタカナ・記号・ASCII境界あたりでしかわからないことがあります。
```


### 区切り例

jasegment.vimの文節区切り(knbc_bunsetuモデル):

    Vimは | 最も | たくさんの | コンピュータ/OSで | 利用できる | テキストエディタです。

jasegment.vimで、ひらがなを終端とする文字列として分割する場合(TinySegmenter不使用。`let g:jasegment#model = 'endhira'`):

    Vimは | 最もたくさんの | コンピュータ/OSで | 利用できる | テキストエディタです。

jasegment.vimの単語区切り(rwcpモデル):

    Vim | は | 最も | たく | さん | の | コンピュータ | / | OS | で | 利用 | できる | テキストエディタ | です | 。

Vimのword:

    Vim | は | 最 | もたくさんの | コンピュータ | / | OS | で | 利用 | できる | テキストエディタ | です | 。

VimのWORD(&encodingがeuc-jpやcp932の場合):

    Vim | は | 最 | もたくさんの | コンピュータ | / OS | で | 利用 | できる | テキストエディタ | です | 。

VimのWORD(&encoding=utf-8の場合。改行までまるごと1つ):

    Vimは最もたくさんのコンピュータ/OSで利用できるテキストエディタです。

matchit2.vim:

    Vim | は | 最もたくさんの | コンピュータ | / | OS | で | 利用できる | テキストエディタ | です。

MyMoveWord.vim("。"までまるごと1つ):

    Vimは最もたくさんのコンピュータ/OSで利用できるテキストエディタです。

motion_ja.vim:

    Vim | は最もたくさんのコンピュータ | /OS | で利用できるテキストエディタです。

jvim3のWORD:

    Vim | は最もたくさんのコンピュータ | /OS | で利用できるテキストエディタです | 。

nvi-m17nのWORD:

    Vim | は | 最もたくさんの | コンピュータ | /OS | で | 利用できる | テキストエディタです。

EmacsのM-f(forward-word):

    Vim | は | 最もたくさんの | コンピュータ | /OS | で | 利用できる | テキストエディタです | 。

ファイル一覧
------------

* README.markdown: このファイル
* plugin/jasegment.vim: map定義等
* autoload/jasegment.vim: カーソル移動関係の処理
* autoload/jasegment/
 * cabocha.vim: CaboChaを使って文節区切りを行うスクリプト。
 * mecab.vim: MeCabを使って単語区切りを行うスクリプト。
 * tinysegmenter.vim: TinySegmenterの移植。単語や文節区切り処理
 * knbc_bunsetu.vim: KNBコーパスから文節区切りを学習させたデータ
 * wpci_bunsetu.vim:
   Wikipediaデータの一部をCaboChaで文節区切りしたものを学習させたデータ。
   knbc_bunsetu.vimよりも少し細かい区切りになる傾向。
 * jeita.vim: TinySegmenterMakerに含まれる単語区切りデータ
 * rwcp.vim: TinySegmenterに含まれる単語区切りデータ
 * endhira.vim: ひらがなを終端とする文字列として分割するスクリプト
 * endhira_mbb.vim:
   endhira.vimの分割に加え、ASCII文字との境界でも分割するスクリプト
 * nvi_m17n.vim: nvi-m17nと同様の区切りを行うスクリプト
 * jvim3.vim: jvim3と同様の区切りを行うスクリプト
 * mbboundary.vim: ASCII文字とマルチバイト文字の境界で区切る
 * kutoten.vim: 句読点を終端とする文字列として分割
 * nonblank.vim: 英文のWORDと同様に、空白文字(全角空白含む)で区切る
* autoload/vital*: vital.vimのProcessManager。cabocha.vimとmecab.vimで使用
* doc/jasegment.jax: ドキュメント
* knbc_bunsetu.model: KNBコーパスから文節区切りを学習させた
  TinySegmenterMakerモデルファイル(再学習用)
* knbc2bunsetu.awk: KNBコーパスから、TinySegmenterMaker用の文節区切り学習用の
  入力形式に変換するAWKスクリプト

knbc_bunsetu.modelとknbc2bunsetu.awkは、
knbc_bunsetu.vimの生成時に使用したファイルなので、
jasegment.vimの動作時には不要です。

参考: 英文のWORDと同様に、スペースで区切られた日本語を対象とするtext-object
---------------------------------------------------------------------------

文節でなく、スペースで区切られた日本語部分を対象として
操作したい場合があるので。

Vimでは、どのtext-objectを使うかをユーザが簡単に選べるので、
様々なtext-objectを用意して選択肢を増やしておくと利便性が高まると思います。

### 方法1: 同梱のnonblank.vimを使う例

```vim
call jasegment#define('nonblank', {
  \ 'move-n': 'gW',
  \ 'move-p': 'gB',
  \ 'move-N': 'gE',
  \ 'select-i': 'iE',
  \ 'select-a': 'aE',
\ })
```

(注: 上記設定例では、組み込みの`gE`を上書きしています)

### 方法2: textobj-userを使用する例

&encoding=utf-8でない環境向けに、
&encoding=utf-8の場合のiWと同様の動作を、
[textobj-user](https://github.com/kana/vim-textobj-user)を使って、
iEにmapする例です。
(&encoding=utf-8の場合は、onoremap iE iWとxnoremap iE iWすればOK)

```vim
call textobj#user#plugin('nonblankchars', {
  \ 'nonblankchars': {
    \ '*pattern*': '\%(^\|\s\)\zs\S*\ze\%(\s\|$\)',
    \ 'select': 'iE',
  \ }
\ })
```

### 方法3: &encoding=utf-8の場合のaWとiWと同様の動作をするプラグイン

https://github.com/deton/textobj-nonblankchars.vim

参考: 日本語での移動を改善する同様のスクリプト
----------------------------------------------

* [matchit2.vim](http://www.fenix.ne.jp/~G-HAL/soft/nosettle/#vim)

    「漢字とその後の連続するひらがな」をひとまとまりとして移動。

* [MyMoveWord.vim](https://sites.google.com/site/fudist/Home/mylib#TOC-w-b-W-E-B-)

    指定した日本語セパレータ(。、など)でW,B,Eのカーソル移動を一旦停止。

* [motion_ja.vim](https://github.com/deton/motion_ja.vim)

    E,W,Bでの移動量を、e,w,bよりも大きくするためのスクリプト。
    jvim3と同様に「。、」や英数字との境目まで移動
    (ただし、&encoding=utf-8の場合は移動量が多すぎ)。

関連
----

* [jasentence.vim](https://github.com/deton/jasentence.vim)

    `)`や`(`キーによるsentence移動時に"、。"も文の終わりとみなすスクリプト。

* [句読点に移動するmap](https://gist.github.com/deton/5138905#ftr-1)

    f,tを使った「。、」への移動を、`f<C-J>`等にmapしておく設定例

* [textobj-mbboundary.vim](https://github.com/deton/textobj-mbboundary.vim)

    ASCII文字とマルチバイト文字の境界を区切りとするtext-object

制限事項
--------

* 文節区切りが適切でない場合があります。

    例えば、現状同梱しているTinySegmenter用文節区切りデータでは、
    「AもしくはB」という文字列があると、「も」の後で切られてしまいます。

    普段使う文章で文節区切りを学習し直せば改善される可能性はあります。
    (CaboChaやKNPやJ.DepPで文節区切りして、TinySegmenterMakerで学習)

* (ひらがなが連続する場合、文節区切りがぱっと見でわからないことがあるので、
  文節開始位置に下線を表示するオプションを付けましたが、
  ぱっと見での区切りのわかりやすさを考えると、
  漢字の連続+ひらがなの連続をWORDとみなす方が使いやすいのかも。
  ということで、TinySegmenterを使用せず、
  ひらがなを終端とする文字列として分割するendhira.vimを追加しました。)

更新履歴
--------

* 1.2.0 (2014-01-25)
  * CaboChaを使って文節区切りを行うcabocha.vimを追加。
  * MeCabを使って単語区切りを行うmecab.vimを追加。
  * nvi-m17nと同様の区切りを行うnvi_m17n.vimを追加。
  * jvim3同様の区切りを行うjvim3.vimを追加。
  * ひらがなを終端とする文字列として分割し、さらにASCII文字との境界でも分割する
    endhira_mbb.vimを追加。
    (nvi-m17nと似た区切りができるように。ただし「漢字列カタカナ漢字列」に対し
    2番目の漢字列で分割されないなどの違いあり)
  * ASCII文字とマルチバイト文字の境界で区切るmbboundary.vimを追加。
  * 句読点を終端とする文字列として分割するkutoten.vimを追加。
  * endhira.vimで、「、。」の前後がひらがなの場合に分割されないバグ修正
  * autoload/tinysegmenter/をautoload/jasegment/に変更。
    tinysegmenterを使用しない区切り用ファイルをいくつか入れているので。
    これにともない、オプション名も変更。
    g:jasegment#endhira#splitpat0とg:jasegment#nonblank#splitpat
  * doc/jasegment.txtをdoc/jasegment.jaxに名前変更。
  * Wikipediaデータの一部をCaboChaで文節区切りしたものをTinySegmenterMakerで
    学習させたwpci_bunsetu.vimを追加。
    knbc_bunsetu.vimよりも少し細かい区切りになる傾向。

knbc_bunsetu.vim:

    文節区切りが | ぱっと | 見でわからないことが | あるので、

wpci_bunsetu.vim:

    文節区切りが | ぱっと | 見でわから | ない | ことが | あるので、

* 1.1.0 (2013-05-18)
  * TinySegmenterを使わないで、ひらがなを終端とする文字列として分割する
    autoload/jasegment/endhira.vimを追加。
  * 英文のWORDと同様に、空白文字(全角空白含む)で区切る
    autoload/jasegment/nonblank.vimを追加(TinySegmenter不使用)。
  * デフォルトの文節区切りによる移動・選択(W,E,B,aW,iW)を使いつつ、
    別の区切りによる移動・選択を行うmapも登録するための関数
    jasegment#define()を追加。

* 1.0.0 (2013-03-12)
  * 最初のリリース
