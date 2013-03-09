jasegment.vim - W,E,BでのWORD移動を日本語の文節単位にするスクリプト
===================================================================

概要
====

jasegment.vimは、W,E,BでのWORD移動を日本語の文節単位にするスクリプトです。
TinySegmenterを使って文節を区切っています。

Vimでは、日本語に関しては、wordとWORDで違いがないため、
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

その他日本語編集向け設定例
==========================

f,t,rで1文字だけ「。、」などの日本語文字を入力するのは、
digraphs機能を使うのが楽だと思います(例:`<C-K>wo`で「を」)。
Vimデフォルトのdigraphsにはひらがな・カタカナ・一部記号が含まれています。

ただ、「。」を入力するために`<C-K>._`と打つ必要があり、
よく使う場合は少し長いので、`f<C-J>`等にmapしておく設定例です。

    " Jで行をつなげた時に日本語の場合はスペースを入れない
    set formatoptions+=Mm
    " 。、に移動(f<C-K>._ を打つのは少し長いので)。cf<C-J>等の使い方も可。
    function! s:MapFT(key, char)
      for cmd in ['f', 'F', 't', 'T']
        execute 'noremap <silent> ' . cmd . a:key . ' ' . cmd . a:char
      endfor
    endfunction
    call <SID>MapFT('<C-J>', '。')
    call <SID>MapFT('<C-U>', '、')
    " 前/次の「。、」の後に改行を挿入する
    nnoremap <silent> f<C-H> f。a<CR><Esc>
    nnoremap <silent> f<C-L> f、a<CR><Esc>
    nnoremap <silent> F<C-H> F。a<CR><Esc>
    nnoremap <silent> F<C-L> F、a<CR><Esc>
    nnoremap <silent> f<C-M> :call search('[、。]')<CR>a<CR><Esc>
    nnoremap <silent> F<C-M> :call search('[、。]', 'b')<CR>a<CR><Esc>
    " Insert modeで「。、」の後に改行を入れる。長い行を折り返すため。
    inoremap <C-U> <NOP>
    inoremap <silent> <C-U><C-H> <C-G>u<C-O>:call <SID>AddNewline('。')<CR>
    inoremap <silent> <C-U><C-L> <C-G>u<C-O>:call <SID>AddNewline('、')<CR>
    inoremap <silent> <C-U><C-M> <C-G>u<C-O>:call <SID>AddNewline('[、。]')<CR>
    function! s:AddNewline(ch)
      if search(a:ch . '\zs.', 'b', line('.')) > 0
        let pos = col("'^")
        let len = col('.') - 1
        execute "normal! i\<CR>\<Esc>"
        call cursor(0, pos - len)
      endif
    endfunction

また、「あ」を入力するdigraphはa5ですが、
もっと打ちやすいaa等にしたい場合の設定例は以下です
(12354は「あ」のUnicodeコードポイント)。

    digraph aa 12354

このとき、digraph定義で使うUnicodeコードポイントは、
該当文字にカーソルを合わせて、:asciiもしくはgaで調べられます
(&encodingがutf-8である必要あり)。

あるいは、日本語文字で書いておいて、Unicodeコードポイントに置換するには、

    digraph aa あ

と書いた行で以下のコマンド(最後の文字をUnicodeコードポイントに置換)を実行
(&encodingがutf-8である必要あり)。

    :s/\(.\)$/\=char2nr(submatch(1))/

(なお、digraphs以外の方法として、kana keymapをsetしていれば、
f,t,rの後にそのままkana keymapに従って日本語文字入力可能ですが、
lmapオフの状態(iminsert=0)だと、
一度Insert modeに入ってlmapオンにする必要があるため、
少し使いにくい面があります)

tcodeやtutcode等の漢字直接入力keymapをdigraphに変換
---------------------------------------------------

tcodeやtutcode等の漢字直接入力keymapを使っている場合、
漢字に対応する2打鍵を:digraphsで登録しておくと便利です。
(なお、tutcodeの3打鍵以上の文字を入力したい場合は、
digraphsに登録できないのでkeymapを使う必要があります)

tcodeやtutcode keymapから、
digraph定義を生成するための操作例です。
(&encodingがutf-8である必要あり)。

    :1,/^loadkeymap/d
    :g/^"/d                              " コメント行を削除
    :%s/<Space>/ /g
    :g/^\S\{3,}/d                        " 3打鍵以上の定義を削除
    :%s/\(.\)$/\=char2nr(submatch(1))/   " 漢字をUnicodeコードポイントに変換
    :%j
    :s/^/digraph /

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
