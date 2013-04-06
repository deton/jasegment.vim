" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" plugin/jasegment.vim - E,W,Bでの移動を文節単位にするためのスクリプト。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2013-04-06
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

nnoremap <silent> <Plug>JaSegmentMoveNE :<C-U>call jasegment#MoveN(g:jasegment#model, 'jasegment#MoveE', v:count1, 0, 0, 0)<CR>
nnoremap <silent> <Plug>JaSegmentMoveNW :<C-U>call jasegment#MoveN(g:jasegment#model, 'jasegment#MoveW', v:count1, 0, 0, 0)<CR>
nnoremap <silent> <Plug>JaSegmentMoveNB :<C-U>call jasegment#MoveN(g:jasegment#model, 'jasegment#MoveB', v:count1, 0, 0, 0)<CR>
onoremap <silent> <Plug>JaSegmentMoveOE :<C-U>call jasegment#MoveO(g:jasegment#model, 'jasegment#MoveE', v:count1)<CR>
onoremap <silent> <Plug>JaSegmentMoveOW :<C-U>call jasegment#MoveN(g:jasegment#model, 'jasegment#MoveW', v:count1, 1, 0, 0)<CR>
onoremap <silent> <Plug>JaSegmentMoveOB :<C-U>call jasegment#MoveN(g:jasegment#model, 'jasegment#MoveB', v:count1, 0, 0, 0)<CR>
" 一度<Esc>で抜けてcursor posをセット
" (:<C-U>callだと、cursor posがVisual mode開始時の位置になるため、
"  cursorがselectionの先頭にあったのか末尾にあったのかわからない)
vnoremap <silent> <Plug>JaSegmentMoveVE <Esc>:call jasegment#MoveV(g:jasegment#model, 'jasegment#MoveE')<CR>
vnoremap <silent> <Plug>JaSegmentMoveVW <Esc>:call jasegment#MoveV(g:jasegment#model, 'jasegment#MoveW')<CR>
vnoremap <silent> <Plug>JaSegmentMoveVB <Esc>:call jasegment#MoveV(g:jasegment#model, 'jasegment#MoveB')<CR>

onoremap <silent> <Plug>JaSegmentTextObjA :<C-U>call jasegment#select_function_wrapper(g:jasegment#model, 'jasegment#select_a', 'o', v:count1)<CR>
vnoremap <silent> <Plug>JaSegmentTextObjVA <Esc>:call jasegment#select_function_wrapperv(g:jasegment#model, 'jasegment#select_a', 0)<CR>
onoremap <silent> <Plug>JaSegmentTextObjI :<C-U>call jasegment#select_function_wrapper(g:jasegment#model, 'jasegment#select_i', 'o', v:count1)<CR>
vnoremap <silent> <Plug>JaSegmentTextObjVI <Esc>:call jasegment#select_function_wrapperv(g:jasegment#model, 'jasegment#select_i', 1)<CR>

if !get(g:, 'jasegment_no_default_key_mappings', 0)
  nmap <silent> E <Plug>JaSegmentMoveNE
  nmap <silent> W <Plug>JaSegmentMoveNW
  nmap <silent> B <Plug>JaSegmentMoveNB
  omap <silent> E <Plug>JaSegmentMoveOE
  omap <silent> W <Plug>JaSegmentMoveOW
  omap <silent> B <Plug>JaSegmentMoveOB
  xmap <silent> E <Plug>JaSegmentMoveVE
  xmap <silent> W <Plug>JaSegmentMoveVW
  xmap <silent> B <Plug>JaSegmentMoveVB
  omap <silent> aW <Plug>JaSegmentTextObjA
  omap <silent> iW <Plug>JaSegmentTextObjI
  xmap <silent> aW <Plug>JaSegmentTextObjVA
  xmap <silent> iW <Plug>JaSegmentTextObjVI
endif

hi def link JaSegment Underlined
" hi def JaSegment term=underline cterm=underline gui=underline

" 文節開始位置にunderlineを付けるかどうか
if !exists('g:jasegment#highlight')
  let g:jasegment#highlight = 0
endif

if g:jasegment#highlight >= 2
  " Insert modeを抜けた時にhighlight表示を更新する
  augroup JaSegment
  autocmd!
  autocmd InsertLeave * call jasegment#OnInsertLeave()
  augroup END
endif
