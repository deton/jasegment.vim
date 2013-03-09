jasegment.vim - W,E,BでのWORD移動を日本語の文節単位にするスクリプト
===================================================================

概要
====

jasegment.vimは、
日本語文字列上でのWORD移動(W,E,B)を文節単位にするスクリプトです。
TinySegmenterを使って文節を区切っています。

Vimでは、日本語に関しては、word移動(w,e,b)とWORD移動(W,E,B)で違いがないため、
W,E,Bの存在意味がなく、使い道がありませんでした。
そこで、W,E,BでのWORD移動をword移動よりも大きくし、
かつ文の構造に基づいた文節単位で移動するjasegment.vimを作りました
(といっても、文節区切りはTinySegmenterを使っているだけです)。

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

文節区切りに関しては、以下を使っています。
* 文節区切りは、
  [TinySegmenter](http://chasen.org/~taku/software/TinySegmenter/)
  をVimスクリプトに移植したものを使用。
* 文節区切りの学習データは、
  [TinySegmenterMaker](http://shogo82148.github.com/blog/2012/11/23/tinysegmentermaker/)
  を使って、
  [KNBコーパス](http://nlp.ist.i.kyoto-u.ac.jp/kuntt/#ga739fe2)
  から、文節区切りを学習させたもの。

区切り例
--------

TinySegmenterの文節区切り(knbc_bunsetuモデル):

    Vimは | 最も | たくさんの | コンピュータ/OSで | 利用できる | テキストエディタです。

TinySegmenterの単語区切り(rwcpモデル):

    Vim | は | 最も | たく | さん | の | コンピュータ | / | OS | で | 利用 | できる | テキストエディタ | です | 。

Vimのword:

    Vim | は | 最 | もたくさんの | コンピュータ | / | OS | で | 利用 | できる | テキストエディタ | です | 。

VimのWORD:

    Vim | は | 最 | もたくさんの | コンピュータ | / OS | で | 利用 | できる | テキストエディタ | です | 。

matchit2.vim:

    Vim | は | 最もたくさんの | コンピュータ | / | OS | で | 利用できる | テキストエディタ | です。

MyMoveWord.vim("。"までまるごと1つ):

    Vimは最もたくさんのコンピュータ/OSで利用できるテキストエディタです。

motion_ja.vim:

    Vim | は最もたくさんのコンピュータ | /OS | で利用できるテキストエディタです。

jvim3のWORD:

    Vim | は最もたくさんのコンピュータ | /OS | で利用できるテキストエディタです | 。

EmacsのM-f(forward-word):

    Vim | は | 最もたくさんの | コンピュータ | /OS | で | 利用できる | テキストエディタです | 。

関連
====

* [matchit2.vim](http://www.fenix.ne.jp/~G-HAL/soft/nosettle/#vim)

    「漢字とその後の連続するひらがな」をひとまとまりとして移動。

* [MyMoveWord.vim](https://sites.google.com/site/fudist/Home/mylib#TOC-w-b-W-E-B-)

    指定した日本語セパレータ(。、など)でW,B,Eのカーソル移動を一旦停止。

* [motion_ja.vim](https://github.com/deton/motion_ja.vim)

    E,W,Bでの移動量を、e,w,bよりも大きくするためのスクリプト。
    jvim3と同様に「。、」や英数字との境目まで移動。

制限事項
========

* 文節区切りが適切でない場合があります。

    例えば、現状同梱している文節区切りデータでは、
    「AもしくはB」という文字列があると、「も」の後で切られてしまいます。

    普段使う文章で文節区切りを学習し直せば改善される可能性はあります。
    (CaboChaやKNPやJ.DepPで文節区切りして、TinySegmenterMakerで学習)

* (ひらがなが連続する場合、文節区切りがぱっと見でわからないことがあるので、
  文節開始位置に下線を表示するオプションを付けましたが、
  ぱっと見での区切りのわかりやすさを考えると、
  漢字の連続+ひらがなの連続をWORDとみなす方が使いやすいのかも)
