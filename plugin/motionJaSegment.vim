" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" plugin/motionJaSegment.vim - E,W,Bでの移動を文節単位にするためのスクリプト。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2013-02-25
"
" Description:
" * 日本語文章上でのE,W,Bでの移動量を、文節単位にします。
"
" オプション:
"    'g:loaded_motionJaSegment'
"       このプラグインを読み込みたくない場合に次のように設定する。
"         let g:loaded_motionJaSegment = 1

if exists('g:loaded_motionJaSegment')
  finish
endif
let g:loaded_motionJaSegment = 1

if !exists('motionJaSegment_model')
  let motionJaSegment_model = 'knbc_bunsetu'
endif

noremap <silent> <Plug>MotionJaSegE :<C-U>call <SID>ExecN(function('<SID>ExecE'))<CR>
noremap <silent> <Plug>MotionJaSegW :<C-U>call <SID>ExecN(function('<SID>ExecW'))<CR>
noremap <silent> <Plug>MotionJaSegB :<C-U>call <SID>ExecN(function('<SID>ExecB'))<CR>
" 一度<Esc>で抜けてcursor posをセット
" (:<C-U>callだと、cursor posがVisual mode開始時の位置になるため、
"  cursorがselectionの先頭にあったのか末尾にあったのかわからない)
vnoremap <silent> <Plug>MotionJaSegVE <Esc>:call <SID>ExecV(function('<SID>ExecE'))<CR>
vnoremap <silent> <Plug>MotionJaSegVW <Esc>:call <SID>ExecV(function('<SID>ExecW'))<CR>
vnoremap <silent> <Plug>MotionJaSegVB <Esc>:call <SID>ExecV(function('<SID>ExecB'))<CR>

function! s:ExecN(func)
  let s:origpos = getpos('.')
  let lastcount = 0
  let cnt = v:count1
  while cnt > 0
    if cnt == 1
      let lastcount = 1
    endif
    call a:func(0, lastcount)
    let cnt -= 1
  endwhile
endfunction

function! s:ExecV(func)
  let otherpos = s:GetVisualOtherPos()
  let cnt = v:prevcount
  if cnt == 0
    let cnt = 1
  endif
  while cnt > 0
    " lastcountはOperator-pending modeのみ
    call a:func(0, 0)
    let cnt -= 1
  endwhile
  let pos = getpos('.')
  call cursor(otherpos[1], otherpos[2])
  execute 'normal! ' . visualmode()
  call cursor(pos[1], pos[2])
endfunction

function! s:ExecE(cW, dummy)
  let lnum = line('.')
  let segcols = jasegment#SegmentCol(g:motionJaSegment_model, getline(lnum))
  if empty(segcols) " 空行の場合、次行最初のsegmentの末尾に移動
    if lnum + 1 > line('$')
      normal! E
      return
    endif
    call cursor(lnum + 1, 1)
    call s:ExecE(a:cW, 0)
    return
  endif
  let curcol = col('.')
  let i = 0
  while i < len(segcols)
    let colend = segcols[i].colend
    " cWでカーソルがsegment末尾にある場合、末尾の文字を対象にする
    if colend == curcol && a:cW
      call cursor(0, colend + 1)
      return
    endif
    if colend > curcol
      " cE等の場合、+1する必要あり
      if mode(1) == 'no'
	let colend += 1
	" 移動先が行末の場合、行末までを対象にする(既に行末にいる場合は除く)
	" (+1してもcursor()で移動すると行末の文字上になって、
	" 行末の文字が対象外になるため、Visual modeで選択。|omap-info|)
	if colend >= col('$')
	  if s:AtLineEnd() && lnum + 1 < line('$')
	    " 既に行末いる && 最終行でない => 普通に移動 (最終行の場合、
	    " 普通に移動するとbeepするだけなので、Visual mode使用)
	  else
	    let colend -= 1
	    call setpos('.', s:origpos)
	    normal! v
	    call cursor(lnum, colend)
	    return
	  endif
	endif
      endif
      call cursor(0, colend)
      if col('.') > curcol
	return
      endif
      " else 既にsegment末尾にいた場合、次のsegment末尾に移動
    endif
    let i += 1
  endwhile
  " 既に行末にいた場合、次行の最初のsegmentの末尾に移動
  " 次行が無い場合(最終行)は、beep
  if lnum + 1 > line('$')
    normal! E
    return
  endif
  call cursor(lnum + 1, 1)
  call s:ExecE(a:cW, 0)
endfunction

function! s:ExecW(dummy, lastcount)
  if a:lastcount && mode(1) == 'no' && v:operator == 'c' && match(getline('.'), '\%' . col('.') . 'c[[:space:]　]') == -1 && !s:AtLineEnd()
    " cWはsegment末尾の空白は対象に入れない。cEと同じ動作。|cW|
    " ただし、空白文字上でない場合。|WORD|
    " 行末の文字上の場合は、cEと違って行末までを対象にする。|WORD|
    return s:ExecE(1, 0)
  endif
  let lnum = line('.')
  let segcols = jasegment#SegmentCol(g:motionJaSegment_model, getline(lnum))
  if empty(segcols)
    normal! W
    return
  endif
  let curcol = col('.')
  let i = 0
  while i < len(segcols)
    let col = segcols[i].col
    if col > curcol
      call cursor(0, col)
      return
    endif
    let i += 1
  endwhile
  " 行の最後のsegmentにいる。
  " dW等の場合、次行の最初のsegmentでなく、行末までを対象にする。|WORD|
  if mode(1) == 'no' && a:lastcount
    call setpos('.', s:origpos)
    normal! v
    call cursor(0, col('$') - 1)
    return
  endif
  " 次行の最初のsegmentに移動
  let lnum += 1
  " 次行が無い場合(最終行)は、beep
  if lnum > line('$')
    normal! W
    return
  endif
  call cursor(lnum, 1)
  " 空白以外の文字まで移動
  call search('[^[:space:]　]', 'c', lnum)
endfunction

function! s:ExecB(dummy, dummy2)
  let lnum = line('.')
  let segcols = jasegment#SegmentCol(g:motionJaSegment_model, getline(lnum))
  " 空行でない && 現位置より前に空白以外がある場合
  if !empty(segcols) && search('[^[:space:]　]', 'bn', lnum) > 0
    let curcol = col('.')
    let i = len(segcols) - 1
    while i >= 0
      let col = segcols[i].col
      if col < curcol
	call cursor(0, col)
	return
      endif
      let i -= 1
    endwhile
  endif
  " 行の最初のsegmentの場合、前行最後のsegmentの開始位置に移動
  " 前行が無い場合(先頭行)は、beep
  if lnum <= 1
    normal! B
    return
  endif
  let lnum -= 1
  let segcols = jasegment#SegmentCol(g:motionJaSegment_model, getline(lnum))
  if empty(segcols) " 空行
    call cursor(lnum, 1)
    return
  endif
  let col = segcols[len(segcols) - 1].col
  call cursor(lnum, col)
endfunction

" ビジュアルモードのother endの位置を取得
function s:GetVisualOtherPos()
  let ed = getpos("'>")
  " Visual modeで$で移動すると、'>はcol('$')になる
  if s:IsCurrentPos(ed)
    return getpos("'<")
  endif
  return ed
endfunction

function! s:IsCurrentPos(pos)
  let cur = getpos('.')
  if a:pos == cur
    return 1
  endif
  if a:pos[1] != cur[1]
    return 0
  endif
  " posがcol('$')の場合、行末の文字上の位置にして比較(curは行末の文字上なので)
  if a:pos[2] != col('$')
    return 0
  endif
  let lastchar = matchstr(getline(a:pos[1]), '.$')
  if lastchar == ''
    return 0
  endif
  return a:pos[2] - strlen(lastchar) == cur[2]
endfunction

" 行末にカーソルがあるかどうか
function! s:AtLineEnd()
  let curcol = col('.')
  if curcol == col('$') " 'virtualedit'の場合
    return 1
  endif
  let line = getline('.')
  if line == ''
    return 1
  endif
  let lastchar = matchstr(line, '.$')
  return curcol == col('$') - strlen(lastchar)
endfunction
