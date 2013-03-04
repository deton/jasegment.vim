" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" plugin/jasegment.vim - E,W,Bでの移動を文節単位にするためのスクリプト。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2013-03-04
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
  command! -range JaSegmentSplit call jasegment#Split(<line1>, <line2>)
endif

nnoremap <silent> <Plug>JaSegmentMoveNE :<C-U>call jasegment#MoveN(function('jasegment#MoveE'), v:count1, mode(1) == 'no', 0, 0)<CR>
nnoremap <silent> <Plug>JaSegmentMoveNW :<C-U>call jasegment#MoveN(function('jasegment#MoveW'), v:count1, mode(1) == 'no', 0, 0)<CR>
nnoremap <silent> <Plug>JaSegmentMoveNB :<C-U>call jasegment#MoveN(function('jasegment#MoveB'), v:count1, 0, 0, 0)<CR>
onoremap <silent> <Plug>JaSegmentMoveOE :<C-U>call jasegment#MoveO(function('jasegment#MoveE'), v:count1)<CR>
onoremap <silent> <Plug>JaSegmentMoveOW :<C-U>call jasegment#MoveN(function('jasegment#MoveW'), v:count1, 1, 0, 0)<CR>
onoremap <silent> <Plug>JaSegmentMoveOB :<C-U>call jasegment#MoveN(function('jasegment#MoveB'), v:count1, 0, 0, 0)<CR>
" 一度<Esc>で抜けてcursor posをセット
" (:<C-U>callだと、cursor posがVisual mode開始時の位置になるため、
"  cursorがselectionの先頭にあったのか末尾にあったのかわからない)
vnoremap <silent> <Plug>JaSegmentMoveVE <Esc>:call jasegment#MoveV(function('jasegment#MoveE'))<CR>
vnoremap <silent> <Plug>JaSegmentMoveVW <Esc>:call jasegment#MoveV(function('jasegment#MoveW'))<CR>
vnoremap <silent> <Plug>JaSegmentMoveVB <Esc>:call jasegment#MoveV(function('jasegment#MoveB'))<CR>

onoremap <silent> <Plug>JaSegmentTextObjA :<C-U>call jasegment#select_function_wrapper('jasegment#select_a', 'o', v:count1)<CR>
vnoremap <silent> <Plug>JaSegmentTextObjVA <Esc>:call jasegment#select_function_wrapperv('jasegment#select_a', 0)<CR>
onoremap <silent> <Plug>JaSegmentTextObjI :<C-U>call jasegment#select_function_wrapper('jasegment#select_i', 'o', v:count1)<CR>
vnoremap <silent> <Plug>JaSegmentTextObjVI <Esc>:call jasegment#select_function_wrapperv('jasegment#select_i', 1)<CR>

call jasegment#EnableMapping()

hi def link JaSegment Underlined
" hi def JaSegment term=underline cterm=underline gui=underline
