" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment.vim - TinySegmenterを使って、日本語を文節や単語で分割
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2013-03-01

if !exists('g:jasegment#model')
  let g:jasegment#model = 'knbc_bunsetu'
endif

function! jasegment#MoveN(func)
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

function! jasegment#MoveV(func)
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
  normal! gv
  call cursor(pos[1], pos[2])
endfunction

function! jasegment#MoveE(cW, dummy)
  let lnum = line('.')
  let segcols = jasegment#SegmentCol(g:jasegment#model, getline(lnum))
  if empty(segcols) " 空行の場合、次行最初のsegmentの末尾に移動
    if lnum + 1 > line('$')
      normal! E
      return
    endif
    call cursor(lnum + 1, 1)
    call s:MoveE(a:cW, 0)
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
  call s:MoveE(a:cW, 0)
endfunction

function! jasegment#MoveW(dummy, lastcount)
  if a:lastcount && mode(1) == 'no' && v:operator == 'c' && match(getline('.'), '\%' . col('.') . 'c[[:space:]　]') == -1 && !s:AtLineEnd()
    " cWはsegment末尾の空白は対象に入れない。cEと同じ動作。|cW|
    " ただし、空白文字上でない場合。|WORD|
    " 行末の文字上の場合は、cEと違って行末までを対象にする。|WORD|
    return s:MoveE(1, 0)
  endif
  let lnum = line('.')
  let segcols = jasegment#SegmentCol(g:jasegment#model, getline(lnum))
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
  " 次行が無い場合(最終行)は、行末に移動。既に行末の場合はbeep
  if lnum > line('$')
    if !s:AtLineEnd()
      call cursor(0, col('$'))
    else
      normal! W
    endif
    return
  endif
  call cursor(lnum, 1)
  " 空白以外の文字まで移動
  call search('[^[:space:]　]', 'c', lnum)
endfunction

function! jasegment#MoveB(dummy, dummy2)
  let lnum = line('.')
  let segcols = jasegment#SegmentCol(g:jasegment#model, getline(lnum))
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
  let segcols = jasegment#SegmentCol(g:jasegment#model, getline(lnum))
  if empty(segcols) " 空行
    call cursor(lnum, 1)
    return
  endif
  let col = segcols[len(segcols) - 1].col
  call cursor(lnum, col)
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

" 直前に分割したsegmentをキャッシュ
let s:cache = {}

" 行をsegmentに分割して、各segmentの文字列と開始col、終了colの配列を返す。
" 'segmentStr1segmentStr2...'
" => [{'segment':'segmentStr1','col':1,'colend':12},
"     {'segment':'segmentStr2','col':13,'colend':24},...]
function! jasegment#SegmentCol(model_name, line)
  let cache = get(s:cache, a:model_name, {})
  if !empty(cache) && a:line ==# cache.line
    return cache.segcols
  endif
  let s:lastline = a:line
  " まずスペース区切りのsegmentに分割
  let spsegs = split(a:line, '[[:space:]　]\+\zs')
  if empty(spsegs)
    let s:lastsegcols = []
    return s:lastsegcols
  endif
  let spsegcols = []
  let col = 1
  " スペース区切りの各segment内に日本語が含まれていたら、文節区切り
  for i in range(len(spsegs))
    let seglen = strlen(spsegs[i])
    let nextcol = col + seglen
    let spseg = substitute(spsegs[i], '[[:space:]　]', '', 'g')
    if spseg != ''
      if spseg =~ '[^[:graph:]]'
	let js = tinysegmenter#{a:model_name}#segment(spseg)
	" TinySegmenterで"。"の後で切ってくれないことがあるので自分で分割
	call map(js, 'split(v:val, ''[^[:space:]　][?!、。]\+\zs'')')
	let segs = []
	for ar in js
	  call extend(segs, ar)
	endfor
      else
	let segs = [spseg]
      endif
      call add(spsegcols, {'segment': segs, 'col': col})
    endif
    let col = nextcol
  endfor
  " スペース区切りsegment内の文節区切りを展開する。
  "    [{'segment':['jaSeg1','jaSeg2'],'col':1},
  "     {'segment':['enSeg'],'col':13},...]
  " => [{'segment':'jaSeg1','col':1,'colend':6},
  "     {'segment':'jaSeg2','col':7,'colend':12},
  "     {'segment':'enSeg','col':13,'colend':17},...]
  let segcols = []
  let i = 0
  while i < len(spsegcols)
    let seg = spsegcols[i].segment
    let col = spsegcols[i].col
    let j = 0
    while j < len(seg)
      let nextcol = col + strlen(seg[j])
      call add(segcols, {'segment': seg[j], 'col': col, 'colend': nextcol - 1})
      let col = nextcol
      let j += 1
    endwhile
    let i += 1
  endwhile
  let s:cache[a:model_name] = {'line': a:line, 'segcols': segcols}
  return segcols
endfunction

" col位置のsegmentを取得する
function! jasegment#GetCurrentSegment(model_name, linestr, col)
  let segcols = jasegment#SegmentCol(a:model_name, a:linestr)
  if empty(segcols)
    return {}
  endif
  let i = 0
  while i < len(segcols)
    if segcols[i].col > a:col
      return segcols[i - 1]
    endif
    let i += 1
  endwhile
  return segcols[i - 1]
endfunction
