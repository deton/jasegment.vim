" vi:set ts=8 sts=2 sw=2 tw=0:
" plugin/textobj/jasegment.vim - Text objects for Japanese segment (Bunsetu)
scriptencoding utf-8

if exists('g:loaded_textobj_jasegment')
  finish
endif
let g:loaded_textobj_jasegment = 1
let s:save_cpo = &cpo
set cpo&vim

call textobj#user#plugin('jasegment', {
  \ 'bunsetu': {
    \ '*sfile*': expand('<sfile>'),
    \ 'select-a': 'aW', '*select-a-function*': 's:select_a',
    \ 'select-i': 'iW', '*select-i-function*': 's:select_i',
  \ }
\ })

function! s:select_a()
  let spincluded = 0
  let line = getline('.')
  if line == '' || match(line, '\%' . col('.') . 'c[[:space:]$B!!(B]') != -1
    " $B6uGr>e$N>l9g$O!"6uGr3+;O0LCV0J9_$rBP>]$K4^$a$k(B
    if search('[^[:space:]$B!!(B]\zs[[:space:]$B!!(B]', 'bce', line('.')) == 0
      call cursor(0, 1)
    endif
    let spincluded = 1
  else
    " segment$B3+;O0LCV0J9_$rBP>]$K4^$a$k(B
    let segcol = jasegment#GetCurrentSegment(g:jasegment#model, line, col('.'))
    if empty(segcol)
      return 0
    endif
    call cursor(0, segcol.col)
  endif
  let st = getpos('.')
  call jasegment#MoveN(function('jasegment#MoveE'), 0)
  " $B6uGr>e$G$J$+$C$?>l9g!"(Bsegment$B=*N;0LCVD>8e$NO"B3$9$k6uGr$rBP>]$K4^$a$k(B
  if !spincluded
    if search('\%' . col('.') . 'c.[[:space:]$B!!(B]\+', 'ce', line('.')) == 0
      " segment$B=*N;0LCVD>8e$K6uGr$,L5$$>l9g!"3+;O0LCVD>A0$K6uGr$,$"$l$P4^$a$k(B
      let ed = getpos('.')
      call setpos('.', st)
      call search('[[:space:]$B!!(B]\+\%' . segcol.col . 'c.', 'bc', line('.'))
      let st = getpos('.')
      call setpos('.', ed)
    endif
  endif
  let ed = getpos('.')
  return ['v', st, ed]
endfunction

function! s:select_i()
  let segcol = jasegment#GetCurrentSegment(g:jasegment#model, getline('.'), col('.'))
  if empty(segcol)
    return 0
  endif
  call cursor(0, segcol.col)
  let st = getpos('.')
  call cursor(0, segcol.colend)
  let ed = getpos('.')
  return ['v', st, ed]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
