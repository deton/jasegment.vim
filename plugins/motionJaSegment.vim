" vi:set ts=8 sts=2 sw=2 tw=0:
"
" plugins/motionJaSegment.vim - E,W,Bでの移動を文節単位にするためのスクリプト。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2013-02-17

scriptencoding euc-jp

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

noremap <silent> <Plug>MotionJaSegE :call <SID>ExecE()<CR>
noremap <silent> <Plug>MotionJaSegW :call <SID>ExecW()<CR>
noremap <silent> <Plug>MotionJaSegB :call <SID>ExecB()<CR>

function! s:ExecE()
  let lnum = line('.')
  let segcols = s:SegmentCol(getline(lnum))
  if empty(segcols) " 空行の場合、次行最初のsegmentの末尾に移動
    if lnum + 1 >= line('$')
      normal! E
      return
    endif
    call cursor(lnum + 1, 1)
    call s:ExecE()
    return
  endif
  let curcol = col('.')
  let [dummy, spcol] = searchpos('[^[:space:]　][[:space:]　]', 'n', lnum)
  if spcol == 0
    let spcol = col('$')
  endif
  let i = 0
  while i < len(segcols)
    let colend = segcols[i].colend
    if colend > curcol
      " 空白文字が、segment末尾より前にあれば、空白文字の前に移動
      if spcol < colend
	call cursor(0, spcol)
	return
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
  if lnum + 1 >= line('$')
    normal! E
    return
  endif
  call cursor(lnum + 1, 1)
  call s:ExecE()
endfunction

function! s:ExecW()
  let lnum = line('.')
  let segcols = s:SegmentCol(getline(lnum))
  if empty(segcols)
    normal! W
    return
  endif
  let curcol = col('.')
  let [dummy, spcol] = searchpos('[[:space:]　]\zs[^[:space:]　]', 'n', lnum)
  if spcol == 0
    let spcol = col('$')
  endif
  let i = 0
  while i < len(segcols)
    let col = segcols[i].col
    if col > curcol
      " 空白文字が、次segment開始より前にあれば、空白文字の後に移動
      if spcol < col
	call cursor(0, spcol)
	return
      endif
      call cursor(0, col)
      return
    endif
    let i += 1
  endwhile
  " 行の最後のsegmentにいる。
  " 空白文字が、行末より前にあれば、空白文字の後に移動
  if spcol < col('$')
    call cursor(0, spcol)
    return
  endif
  " 次行の最初のsegmentに移動
  let lnum += 1
  " 次行が無い場合(最終行)は、beep
  if lnum >= line('$')
    normal! W
    return
  endif
  call cursor(lnum, 1)
  " 空白以外の文字まで移動
  call search('[^[:space:]　]', 'c', lnum)
endfunction

function! s:ExecB()
  let lnum = line('.')
  let segcols = s:SegmentCol(getline(lnum))
  " 空行でない && 現位置より前に空白以外がある場合
  if !empty(segcols) && search('[^[:space:]　]', 'bn', lnum) > 0
    let curcol = col('.')
    let [dummy, spcol] = searchpos('[[:space:]　]\zs[^[:space:]　]', 'bn', lnum)
    let i = len(segcols) - 1
    while i >= 0
      let col = segcols[i].col
      if col < curcol
	" 空白文字が、segment開始位置より後にあれば、空白文字の後に移動
	if spcol > col
	  call cursor(0, spcol)
	  return
	endif
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
  let [dummy, spcol] = searchpos('[[:space:]　]\zs[^[:space:]　]', 'bn', lnum)
  let segcols = s:SegmentCol(getline(lnum))
  if empty(segcols) " 空行
    call cursor(lnum, 1)
    return
  endif
  let col = segcols[len(segcols) - 1].col
  " 空白文字が、segment開始位置より後にあれば、空白文字の後に移動
  if spcol > col
    call cursor(lnum, spcol)
    return
  endif
  call cursor(lnum, col)
endfunction

" 行をsegmentに分割して、各segmentの文字列と開始col、終了colの配列を返す。
" 'segmentStr1segmentStr2...'
" => [{'segment':'segmentStr1','col':1,'colend':11},
"     {'segment':'segmentStr2','col':12,'colend':22},...]
function! s:SegmentCol(line)
  let segs = tinysegmenter#{g:motionJaSegment_model}#segment(a:line)
  if empty(segs)
    return []
  endif
  let segcols = []
  let col = 1
  let i = 0
  while i < len(segs)
    let nextcol = col + strlen(segs[i])
    call add(segcols, {'segment': segs[i], 'col': col, 'colend': nextcol - 1})
    let col = nextcol
    let i += 1
  endwhile
  return segcols
endfunction
