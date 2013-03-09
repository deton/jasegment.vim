" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment.vim - TinySegmenterを使って、日本語を文節や単語で分割
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2013-03-05

if !exists('g:jasegment#model')
  let g:jasegment#model = 'knbc_bunsetu'
endif
if !exists('g:jasegment#model_word')
  let g:jasegment#model_word = 'rwcp'
endif
" 指定した文字(パターン)の後に強制的に文節区切りを入れる
if !exists('g:jasegment#splitpat')
  let g:jasegment#splitpat = '[^[:space:]　][?!、。]\+\zs'
endif
" :JaSegmentSplitで分かち書きする際の区切り文字列
if !exists('g:jasegment#splitsep')
  let g:jasegment#splitsep = ' '
endif

function! jasegment#Split(line1, line2)
  let hlsave = g:jasegment#highlight
  " 分割すると開始位置は必ずずれるので下線表示はオフにする
  if hlsave && s:hl_id != 0
    silent! call matchdelete(s:hl_id)
  endif
  let g:jasegment#highlight = 0

  for lnum in range(a:line1, a:line2)
    let segcols = jasegment#SegmentCol(g:jasegment#model, lnum)
    let segs = map(copy(segcols), 'get(v:val, "segment", "")')
    call setline(lnum, join(segs, g:jasegment#splitsep))
  endfor

  if hlsave
    " 最終行のキャッシュが残ってるとW等で移動しても下線表示されないのでクリア
    let s:cache[g:jasegment#model] = {'line': '', 'segcols': []}
  endif
  let g:jasegment#highlight = hlsave
endfunction

" Move{E,W,B}をcountに対応させるためのラッパ
" @param stay MoveE用。現位置がsegment末尾の場合、
"  次segmentに移動したくない場合に1を指定。textobj用。
" @param countspace iW用に、空白もcountに含める
function! jasegment#MoveN(func, cnt, omode, stay, countspace)
  let s:origpos = getpos('.')
  let stay = a:stay
  let islast = 0
  let cnt = a:cnt
  while cnt > 0
    if cnt == 1
      let islast = 1
    endif
    let endcol = function(a:func)(stay, islast, a:omode)
    let stay = 0
    let cnt -= 1
    if a:countspace && endcol > 0 && cnt > 0
      call cursor(0, endcol)
      let cnt -= 1
    endif
  endwhile
endfunction

" MoveEをOperator-pending modeに対応させるためのラッパ
function! jasegment#MoveO(func, cnt)
  normal! v
  call jasegment#MoveN(a:func, a:cnt, 1, 0, 0)
endfunction

" Move{E,W,B}をVisual modeに対応させるためのラッパ
function! jasegment#MoveV(func)
  let cnt = v:prevcount
  if cnt == 0
    let cnt = 1
  endif
  while cnt > 0
    " islastはOperator-pending modeのみ
    call function(a:func)(0, 0, 0)
    let cnt -= 1
  endwhile
  let pos = getpos('.')
  normal! gv
  call cursor(pos[1], pos[2])
endfunction

function! jasegment#MoveE(stay, dummy, dummy2)
  let lnum = line('.')
  let segcols = jasegment#SegmentCol(g:jasegment#model, lnum)
  if empty(segcols) " 空行の場合、次行最初のsegmentの末尾に移動
    if lnum + 1 > line('$')
      normal! E
      return 0
    endif
    call cursor(lnum + 1, 1)
    return jasegment#MoveE(1, 0, 0)
  endif
  let curcol = col('.')
  let i = 0
  while i < len(segcols)
    let colend = segcols[i].colend
    if colend == curcol && a:stay
      call cursor(0, colend)
      return s:EndcolIncludeSpaces(segcols, i)
    endif
    if colend > curcol
      call cursor(0, colend)
      if col('.') > curcol
	return s:EndcolIncludeSpaces(segcols, i)
      endif
      " else 既にsegment末尾にいた場合
      if a:stay
	" 前行から移動してきた場合は、これ以上移動すると余分。
	" cWでカーソルがsegment末尾にある場合は、末尾の文字を対象にする。
	return s:EndcolIncludeSpaces(segcols, i)
      endif
      " else 次のsegment末尾に移動
    endif
    let i += 1
  endwhile
  " 既に行末にいた場合、次行の最初のsegmentの末尾に移動
  " 次行が無い場合(最終行)は、beep
  if lnum + 1 > line('$')
    normal! E
    return 0
  endif
  call cursor(lnum + 1, 1)
  return jasegment#MoveE(1, 0, 0)
endfunction

" segment末尾の空白を含めた、segment終了位置を返す。
" 末尾に空白が無い場合は0。
" (textobjの|iW|向けに、空白を含めてcountできるようにするため)
function! s:EndcolIncludeSpaces(segcols, idx)
  let colend = a:segcols[a:idx].colend
  if a:idx + 1 < len(a:segcols)
    let nextcol = a:segcols[a:idx + 1].col
  else
    let nextcol = col('$')
  endif
  if colend + 1 >= nextcol
    return 0 " 末尾に空白無し
  endif
  return nextcol - 1
endfunction

function! jasegment#MoveW(dummy, islast, omode)
  if a:islast && a:omode && v:operator == 'c' && match(getline('.'), '\%' . col('.') . 'c[[:space:]　]') == -1 && !s:AtLineEnd()
    " cWはsegment末尾の空白は対象に入れない。cEと同じ動作。|cW|
    " ただし、空白文字上でない場合。|WORD|
    " 行末の文字上の場合は、cEと違って行末までを対象にする。|WORD|
    let curpos = getpos('.')
    call setpos('.', s:origpos)
    normal! v
    call setpos('.', curpos)
    return jasegment#MoveE(1, 0, 0)
  endif
  let lnum = line('.')
  let segcols = jasegment#SegmentCol(g:jasegment#model, lnum)
  if empty(segcols)
    normal! W
    return 0
  endif
  let curcol = col('.')
  let i = 0
  while i < len(segcols)
    let col = segcols[i].col
    if col > curcol
      call cursor(0, col)
      return 0
    endif
    let i += 1
  endwhile
  " 行の最後のsegmentにいる。
  " dW等の場合、次行の最初のsegmentでなく、行末までを対象にする。|WORD|
  if a:omode && a:islast
    call setpos('.', s:origpos)
    normal! v
    call cursor(0, col('$') - 1)
    return 0
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
    return 0
  endif
  call cursor(lnum, 1)
  " 空白以外の文字まで移動
  call search('[^[:space:]　]', 'c', lnum)
endfunction

function! jasegment#MoveB(dummy, dummy2, dummy3)
  let lnum = line('.')
  let segcols = jasegment#SegmentCol(g:jasegment#model, lnum)
  " 空行でない && 現位置より前に空白以外がある場合
  if !empty(segcols) && search('[^[:space:]　]', 'bn', lnum) > 0
    let curcol = col('.')
    let i = len(segcols) - 1
    while i >= 0
      let col = segcols[i].col
      if col < curcol
	call cursor(0, col)
	return 0
      endif
      let i -= 1
    endwhile
  endif
  " 行の最初のsegmentの場合、前行最後のsegmentの開始位置に移動
  " 前行が無い場合(先頭行)は、beep
  if lnum <= 1
    normal! B
    return 0
  endif
  let lnum -= 1
  let segcols = jasegment#SegmentCol(g:jasegment#model, lnum)
  if empty(segcols) " 空行
    call cursor(lnum, 1)
    return 0
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

" from vim-textobj-user
function! jasegment#select_function_wrapper(function_name, previous_mode, count1)
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
function! jasegment#select_function_wrapperv(function_name, inner)
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
    call jasegment#select_function_wrapper(a:function_name, 'v', cnt)
    return
  endif
  " 選択済の場合、E or Bで移動後、"aW"の場合は隣接する連続空白を含める
  " TODO: iWの場合に、単語間の連続空白をcountに含める
  if s:pos_lt(pos, otherpos)
    call jasegment#MoveN('jasegment#MoveB', cnt, 0, 0, 1)
    if !a:inner
      call search('[[:space:]　]\+\%' . col('.') . 'c', 'bc', line('.'))
    endif
  else
    call jasegment#MoveN('jasegment#MoveE', cnt, 0, 0, 0)
    if !a:inner
      call search('\%' . col('.') . 'c.[[:space:]　]\+', 'ce', line('.'))
    endif
  endif
  let newpos = getpos('.')
  normal! gv
  call setpos('.', newpos)
endfunction

function! jasegment#select_a(count1)
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
    let segcol = jasegment#csegment(g:jasegment#model, line('.'), col('.'))
    if empty(segcol)
      return 0
    endif
    call cursor(0, segcol.col)
  endif
  let st = getpos('.')
  call jasegment#MoveN('jasegment#MoveE', a:count1, 0, 1, 0)
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

function! jasegment#select_i(count1)
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
    let segcol = jasegment#csegment(g:jasegment#model, line('.'), col('.'))
    if empty(segcol)
      return 0
    endif
    call cursor(0, segcol.col)
  endif
  let st = getpos('.')
  call jasegment#MoveN('jasegment#MoveE', cnt, 0, 1, 1)
  let ed = getpos('.')
  return ['v', st, ed]
endfunction


" 直前に分割したsegmentをキャッシュ
let s:cache = {}
let s:hl_id = 0

" 行をsegmentに分割して、各segmentの文字列と開始col、終了colの配列を返す。
" 'segmentStr1segmentStr2...'
" => [{'segment':'segmentStr1','col':1,'colend':12},
"     {'segment':'segmentStr2','col':13,'colend':24},...]
function! jasegment#SegmentCol(model_name, lnum)
  let line = getline(a:lnum)
  let cache = get(s:cache, a:model_name, {})
  if !empty(cache) && line ==# cache.line
    return cache.segcols
  endif
  if s:hl_id != 0
    silent! call matchdelete(s:hl_id)
  endif
  " まずスペース区切りのsegmentに分割
  let spsegs = split(line, '[[:space:]　]\+\zs')
  if empty(spsegs)
    let s:cache[a:model_name] = {'line': line, 'segcols': []}
    return []
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
	call map(js, 'split(v:val, ''' . g:jasegment#splitpat . ''')')
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
  if g:jasegment#highlight
    call s:showmark(segcols, a:lnum)
  endif
  let s:cache[a:model_name] = {'line': line, 'segcols': segcols}
  return segcols
endfunction

" segment開始位置にunderlineを付ける
function! s:showmark(segcols, lnum)
  let marks = []
  for segcol in a:segcols
    let col = segcol.col
    call add(marks, '\%' . a:lnum . 'l\%' . col . 'c')
  endfor
  let s:hl_id = matchadd('JaSegment', join(marks, '\|'))
endfunction

function! jasegment#OnInsertLeave()
  call jasegment#SegmentCol(g:jasegment#model, line('.'))
endfunction

" col位置のsegmentを取得する
function! jasegment#csegment(model_name, lnum, col)
  let segcols = jasegment#SegmentCol(a:model_name, a:lnum)
  let idx = jasegment#index(segcols, a:col)
  if idx == -1
    return {}
  endif
  return segcols[idx]
endfunction

" col位置のsegmentのindex番号を取得する
function! jasegment#index(segcols, col)
  if empty(a:segcols)
    return -1
   endif
  let i = 0
  while i < len(a:segcols)
    if a:segcols[i].col > a:col
      return i - 1
    endif
    let i += 1
  endwhile
  return i - 1
endfunction

" カーソル位置の文節文字列を取得する
function! jasegment#cWORD()
  let segcol = jasegment#csegment(g:jasegment#model, line('.'), col('.'))
  if empty(segcol)
    return ''
  endif
  return segcol.segment
endfunction

" カーソル位置の単語文字列を取得する
function! jasegment#cword()
  let segcol = jasegment#csegment(g:jasegment#model_word, line('.'), col('.'))
  if empty(segcol)
    return ''
  endif
  return segcol.segment
endfunction
