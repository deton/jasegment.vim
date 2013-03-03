jasegment.vim - E,W,Bでの移動を文節単位にするスクリプト
=======================================================

概要
====

jasegment.vimは、E,W,Bでの移動を文節単位にするスクリプトです。

* 通常移動の他に、Visual modeや、dW/c2E/yB等のOperator-pending modeも対応。
* 文節単位のtext-objects選択用`<Plug>`を提供。aW/iWにmapして使用可能。
* カーソル行の文節開始位置に下線を表示(カーソル行の初回文節区切りのタイミング)

* 文節区切りは、
  [TinySegmenter](http://chasen.org/~taku/software/TinySegmenter/)
  をVimスクリプトに移植したものを使用。

* 文節区切りの学習データは、
  [TinySegmenterMaker](http://shogo82148.github.com/blog/2012/11/23/tinysegmentermaker/)
  を使って、
  [KNBコーパス](http://nlp.ist.i.kyoto-u.ac.jp/kuntt/#ga739fe2)
  から、文節区切りを学習させたもの。

使い方
======
  doc/jasegment.txt を参照してください。

その他日本語編集向け設定例
==========================

    " Jで行をつなげた時に日本語の場合はスペースを入れない
    set formatoptions+=Mm
    " 。、に移動(f<C-K>._ を打つのは少し長いので)。cf<C-U>等の使い方も可。
    map <silent> f<C-J> f<C-K>._
    map <silent> f<C-U> f<C-K>,_
    map <silent> F<C-J> F<C-K>._
    map <silent> F<C-U> F<C-K>,_
    " 前/次の「。、」の後に改行を挿入する
    nnoremap <silent> f<C-H> f<C-K>._a<CR><Esc>
    nnoremap <silent> f<C-L> f<C-K>,_a<CR><Esc>
    nnoremap <silent> F<C-H> F<C-K>._a<CR><Esc>
    nnoremap <silent> F<C-L> F<C-K>,_a<CR><Esc>
    nnoremap <silent> f<C-M> :call search('[、。]')<CR>a<CR><Esc>
    nnoremap <silent> F<C-M> :call search('[、。]', 'b')<CR>a<CR><Esc>
    " Insert modeで「。、」の後に改行を入れる。長い行を折り返すため。
    imap <C-U> <NOP>
    imap <silent> <C-U><C-H> <C-O>:call <SID>AddNewline('。')<CR>
    imap <silent> <C-U><C-L> <C-O>:call <SID>AddNewline('、')<CR>
    imap <silent> <C-U><C-M> <C-O>:call <SID>AddNewline('[、。]')<CR>
    function! s:AddNewline(ch)
      if search(a:ch, 'b', line('.')) > 0
	let pos = getpos('.')
	execute "normal! a\<CR>\<Esc>"
	let pos[1] += 1
	call setpos('.', pos)
      endif
    endfunction

関連
====

* [matchit2.vim](http://www.fenix.ne.jp/~G-HAL/soft/nosettle/#vim)

    「漢字とその後の連続するひらがな」をひとまとまりとして移動。

* [MyMoveWord.vim](https://sites.google.com/site/fudist/Home/mylib#TOC-w-b-W-E-B-)

    指定した日本語セパレータ(。、など)でW,B,Eのカーソル移動を一旦停止。

* [motion_ja.vim](https://github.com/deton/motion_ja.vim)

    E,W,Bでの移動量を、e,w,bよりも大きくするためのスクリプト。

更新履歴
========
* 1.0.0 (2013-03-XXX)
    最初のリリース。
