jasegment.vim - W,E,BでのWORD移動を日本語の文節単位にするスクリプト
===================================================================

概要
====

jasegment.vimは、W,E,BでのWORD移動を日本語の文節単位にするスクリプトです。
TinySegmenterを使って文節を区切っています。

Vimでは、日本語に関しては、wordとWORDで違いがないため、
W,E,Bの存在意義がなく、使い道がありませんでした。
そこで、W,E,BでのWORD移動をword移動よりも大きくし、
かつ文の構造に基づいた文節単位で移動するjasegment.vimを作りました。

以下の特徴があります。
* ひらがなが連続する中から、ひらがなで始まる文節を認識可能。
  (文字種だけを見て、
  漢字の後の連続するひらがなをWORDとみなす方法(Emacs等)では不可能)
  (ただし、ひらがなが連続する場合は誤認識する可能性も高い)
* 英字とその後に連続するひらがなを、WORDとして扱う。

機能:
* 通常移動(countも対応)の他に、Visual modeや、
  dW/c2E/yB等のOperator-pending modeも対応。
* text-objectsでWORD選択を行うaW/iWも、文節で選択するようにします。
* カーソル行の文節開始位置に下線を表示するオプションあり。

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

jvim3のWORD:
    Vim | は最もたくさんのコンピュータ | /OS | で利用できるテキストエディタです | 。

EmacsのM-f(forward-word):

    Vim | は | 最もたくさんの | コンピュータ | /OS | で | 利用できる | テキストエディタです | 。

その他日本語編集向け設定例
==========================

f,t,rで「。、」やひらがな・カタカナを直接指定したい場合、
kana keymapをsetして、lmapオンの状態であればできますが
(tcodeやtutcode keymapなら漢字も可)、
lmapオフの状態だと、
一度Insert modeに入ってlmapオンにしないといけなくて面倒なので、
`f<C-J>`等にmapする例です。

なお、mapしていない文字も、digraphs機能で入力可能です(例:`<C-K>wo`で「を」)。
Vimデフォルトのdigraphsにはひらがな・カタカナ・一部記号あり。
(tcodeやtutcodeを使っている場合、
漢字に対応する2ストロークを:digraphに登録すると便利)

    " Jで行をつなげた時に日本語の場合はスペースを入れない
    set formatoptions+=Mm
    " 。、に移動(f<C-K>._ を打つのは少し長いので)。cf<C-J>等の使い方も可。
    noremap <silent> f<C-J> f。
    noremap <silent> f<C-U> f、
    noremap <silent> F<C-J> F。
    noremap <silent> F<C-U> F、
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

参考: tcodeやtutcode keymapから、
digraph定義を生成するためのRubyスクリプト(漢字をUnicodeコードポイント化)。
入力ファイルの各行が、「rk あ」のような形式であることを想定しています。

    while gets
        puts 'digraph ' + $_[0..2] + $_[3].ord.to_s
    end

関連
====

* [matchit2.vim](http://www.fenix.ne.jp/~G-HAL/soft/nosettle/#vim)

    「漢字とその後の連続するひらがな」をひとまとまりとして移動。

* [MyMoveWord.vim](https://sites.google.com/site/fudist/Home/mylib#TOC-w-b-W-E-B-)

    指定した日本語セパレータ(。、など)でW,B,Eのカーソル移動を一旦停止。

* [motion_ja.vim](https://github.com/deton/motion_ja.vim)

    E,W,Bでの移動量を、e,w,bよりも大きくするためのスクリプト。
    「。、」や英数字との境目まで移動。
