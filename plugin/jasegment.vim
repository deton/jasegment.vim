" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" plugin/jasegment.vim - E,W,Bでの移動を文節単位にするためのスクリプト。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2013-03-01
"
" Description:
" * 日本語文章上でのE,W,Bでの移動量を、文節単位にします。
"
" オプション:
"    'g:loaded_jasegment'
"       このプラグインを読み込みたくない場合に次のように設定する。
"         let g:loaded_jasegment = 1

if exists('g:loaded_jasegment')
  finish
endif
let g:loaded_jasegment = 1

" 指定行を、文節で分かち書きした内容に置換する。
" (なお、連続する複数個のタブやスペースは全て1つのスペースに置換。
" 主に文節区切り再学習用データ作成用)
if !exists(":JaSegmentSplit")
  command! -range JaSegmentSplit call <SID>Split(<line1>, <line2>)
endif

function! s:Split(line1, line2)
  for lnum in range(a:line1, a:line2)
    let segcols = jasegment#SegmentCol(g:jasegment#model, getline(lnum))
    call map(segcols, 'get(v:val, "segment", "")')
    call setline(lnum, join(segcols))
  endfor
endfunction

noremap <silent> <Plug>JaSegmentMoveE :<C-U>call jasegment#MoveN(function('jasegment#MoveE'))<CR>
noremap <silent> <Plug>JaSegmentMoveW :<C-U>call jasegment#MoveN(function('jasegment#MoveW'))<CR>
noremap <silent> <Plug>JaSegmentMoveB :<C-U>call jasegment#MoveN(function('jasegment#MoveB'))<CR>
" 一度<Esc>で抜けてcursor posをセット
" (:<C-U>callだと、cursor posがVisual mode開始時の位置になるため、
"  cursorがselectionの先頭にあったのか末尾にあったのかわからない)
vnoremap <silent> <Plug>JaSegmentMoveVE <Esc>:call jasegment#MoveV(function('jasegment#MoveE'))<CR>
vnoremap <silent> <Plug>JaSegmentMoveVW <Esc>:call jasegment#MoveV(function('jasegment#MoveW'))<CR>
vnoremap <silent> <Plug>JaSegmentMoveVB <Esc>:call jasegment#MoveV(function('jasegment#MoveB'))<CR>
