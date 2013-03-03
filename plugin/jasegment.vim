" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" plugin/jasegment.vim - E,W,Bでの移動を文節単位にするためのスクリプト。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2013-03-03
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

onoremap <silent> <Plug>JaSegmentTextObjA :<C-U>call <SID>select_function_wrapper('<SID>select_a', 'o', v:count1)<CR>
vnoremap <silent> <Plug>JaSegmentTextObjVA <Esc>:call <SID>select_function_wrapperv('<SID>select_a', 0)<CR>
onoremap <silent> <Plug>JaSegmentTextObjI :<C-U>call <SID>select_function_wrapper('<SID>select_i', 'o', v:count1)<CR>
vnoremap <silent> <Plug>JaSegmentTextObjVI <Esc>:call <SID>select_function_wrapperv('<SID>select_i', 1)<CR>

" from vim-textobj-user
function! s:select_function_wrapper(function_name, previous_mode, count1)
  let ORIG_POS = getpos('.')
  " call s:prepare_selection(a:previous_mode) " countがクリアされるので省略

  let _ = function(a:function_name)(a:count1)
  if _ is 0
    if a:previous_mode ==# 'v'
      normal! gv
    else  " if a:previous_mode ==# 'o'
      call setpos('.', ORIG_POS)
    endif
  else
    let [motion_type, start_position, end_position] = _
    execute 'normal!' motion_type
    call setpos('.', start_position)
    normal! o
    call setpos('.', end_position)
  endif
endfunction

function! s:pos_lt(pos1, pos2)  " less than
  return a:pos1[1] < a:pos2[1] || a:pos1[1] == a:pos2[1] && a:pos1[2] < a:pos2[2]
endfunction

" Visual modeでのcount指定に対応するために一部変更。
function! s:select_function_wrapperv(function_name, inner)
  let cnt = v:prevcount
  if cnt == 0
    let cnt = 1
  endif
  " 何も選択されていない場合、textobj選択
  let pos = getpos('.')
  execute 'normal! gvo' . "\<Esc>"
  let otherpos = getpos('.')
  execute 'normal! gvo' . "\<Esc>"
  if pos == otherpos
    call s:select_function_wrapper(a:function_name, 'v', cnt)
    return
  endif
  " 選択済の場合、E or Bで移動後、"aW"の場合は隣接する連続空白を含める
  " TODO: iWの場合に、単語間の連続空白をcountに含める
  if s:pos_lt(pos, otherpos)
    call jasegment#MoveN(function('jasegment#MoveB'), cnt, 0, 0, 1)
    if !a:inner
      call search('[[:space:]　]\+\%' . col('.') . 'c', 'bc', line('.'))
    endif
  else
    call jasegment#MoveN(function('jasegment#MoveE'), cnt, 0, 0, 0)
    if !a:inner
      call search('\%' . col('.') . 'c.[[:space:]　]\+', 'ce', line('.'))
    endif
  endif
  let newpos = getpos('.')
  normal! gv
  call setpos('.', newpos)
endfunction

function! s:select_a(count1)
  let spincluded = 0
  let line = getline('.')
  if line == '' || match(line, '\%' . col('.') . 'c[[:space:]　]') != -1
    " 空白上の場合は、空白開始位置以降を対象に含める
    if search('[^[:space:]　]\zs[[:space:]　]', 'bc', line('.')) == 0
      call cursor(0, 1)
    endif
    let spincluded = 1
  else
    " segment開始位置以降を対象に含める
    let segcol = jasegment#GetCurrentSegment(g:jasegment#model, line, col('.'))
    if empty(segcol)
      return 0
    endif
    call cursor(0, segcol.col)
  endif
  let st = getpos('.')
  call jasegment#MoveN(function('jasegment#MoveE'), a:count1, 0, 1, 0)
  " 空白上でなかった場合、segment終了位置直後の連続する空白を対象に含める
  if !spincluded
    if search('\%' . col('.') . 'c.[[:space:]　]\+', 'ce', line('.')) == 0
      " segment終了位置直後に空白が無い場合、開始位置直前に空白があれば含める
      let ed = getpos('.')
      call setpos('.', st)
      call search('[[:space:]　]\+\%' . segcol.col . 'c.', 'bc', line('.'))
      let st = getpos('.')
      call setpos('.', ed)
    endif
  endif
  let ed = getpos('.')
  return ['v', st, ed]
endfunction

function! s:select_i(count1)
  let cnt = a:count1
  let line = getline('.')
  if line == '' || match(line, '\%' . col('.') . 'c[[:space:]　]') != -1
    " 空白上の場合は、空白開始位置以降を対象に含める
    if search('[^[:space:]　]\zs[[:space:]　]', 'bc', line('.')) == 0
      call cursor(0, 1)
    endif
    let cnt -= 1
    if cnt <= 0
      " 連続する空白のみを対象にする
      let st = getpos('.')
      if search('[[:space:]　]\+\ze[^[:space:]　]', 'ce', line('.')) == 0
	call cursor(0, col('$'))
      endif
      let ed = getpos('.')
      return ['v', st, ed]
    endif
  else
    " segment開始位置以降を対象に含める
    let segcol = jasegment#GetCurrentSegment(g:jasegment#model, line, col('.'))
    if empty(segcol)
      return 0
    endif
    call cursor(0, segcol.col)
  endif
  let st = getpos('.')
  call jasegment#MoveN(function('jasegment#MoveE'), cnt, 0, 1, 1)
  let ed = getpos('.')
  return ['v', st, ed]
endfunction
