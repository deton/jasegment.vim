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
  if line == '' || match(line, '\%' . col('.') . 'c[[:space:]　]') != -1
    " 空白上の場合は、空白開始位置以降を対象に含める
    if search('[^[:space:]　]\zs[[:space:]　]', 'bce', line('.')) == 0
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
  call jasegment#MoveN(function('jasegment#MoveE'), 0)
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
