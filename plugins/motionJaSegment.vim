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

if !exists('motionJaSeg_model')
  let motionJaSeg_model = 'knbc_bunsetu'
endif

noremap <silent> <Plug>MotionJaSegE :call <SID>ExecE()<CR>
noremap <silent> <Plug>MotionJaSegW :call <SID>ExecW()<CR>
noremap <silent> <Plug>MotionJaSegB :call <SID>ExecB()<CR>

function! s:ExecE()
  let lnum = line('.')
  let segcols = s:SegmentCol(getline(lnum))
  if empty(segcols)
    normal! E
    return
  endif
  let curcol = col('.')
  let i = 0
  while i < len(segcols)
    let col = segcols[i].col
    if col > curcol
      call cursor(0, col - 1)
      if col('.') == curcol " 既に文節末尾にいる場合
	let i += 1
	continue
      endif
      return
    endif
    let i += 1
  endwhile
  if lnum + 1 >= line('$')
    normal! E
    return
  endif
  call cursor(lnum + 1, 1)
  call s:ExecE()
endfunction

function! s:ExecW()
  let curcol = col('.')
  let segcols = s:SegmentCol(getline('.'))
  if empty(segcols)
    normal! W
    return
  endif
  let col = 1
  let i = 0
  while i < len(segcols)
    let col = segcols[i].col
    if col > curcol
      call cursor(0, col)
      if col('.') == curcol
	" 行末の場合
	normal! W
      endif
      return
    endif
    let i += 1
  endwhile
  normal! W
endfunction

function! s:ExecB()
  let lnum = line('.')
  let segcols = s:SegmentCol(getline(lnum))
  if empty(segcols)
    normal! B
    return
  endif
  let curcol = col('.')
  let col = 1
  let i = 0
  while i < len(segcols)
    let col = segcols[i].col
    if col >= curcol
      if i > 0
	call cursor(0, segcols[i-1].col)
	if col('.') < curcol
	  return
	endif
      endif
      " 行の最初の文節の場合、前の行の最後の文節に移動
      if lnum <= 1
	normal! B
	return
      endif
      let prevsegcols = s:SegmentCol(getline(lnum - 1))
      if empty(prevsegcols)
	normal! B
	return
      endif
      call cursor(lnum - 1, prevsegcols[len(prevsegcols) - 1].col)
      return
    endif
    let i += 1
  endwhile
  let prevsegcols = s:SegmentCol(getline(lnum - 1))
  if empty(prevsegcols)
    normal! B
    return
  endif
  call cursor(lnum - 1, prevsegcols[len(prevsegcols) - 1].col)
endfunction

" 行をsegmentに分割して、各segmentの文字列と開始colの配列を返す。
" 'segmentStr1segmentStr2...'
" => [{'segment':'segmentStr1','col':1},
"     {'segment':'segmentStr2','col':12},...]
function! s:SegmentCol(line)
  let segs = tinysegmenter#{g:motionJaSeg_model}#segment(a:line)
  if empty(segs)
    return []
  endif
  let segcols = []
  let col = 1
  let i = 0
  while i < len(segs)
    call add(segcols, {'segment': segs[i], 'col': col})
    let col += strlen(segs[i])
    let i += 1
  endwhile
  return segcols
endfunction
