" vi:set ts=8 sts=2 sw=2 tw=0:
" plugin/textobj/jasegment.vim - Text objects for Japanese segment (Bunsetu)
scriptencoding utf-8

if exists('g:loaded_textobj_jasegment')
  finish
endif
let g:loaded_textobj_jasegment = 1
let s:save_cpo = &cpo
set cpo&vim

if !exists('textobj_jasegment_model')
  let textobj_jasegment_model = 'knbc_bunsetu'
endif

call textobj#user#plugin('jasegment', {
  \ 'bunsetu': {
    \ '*sfile*': expand('<sfile>'),
    \ 'select-a': 'aW', '*select-a-function*': 's:select_a',
    \ 'select-i': 'iW', '*select-i-function*': 's:select_i',
  \ }
\ })

function! s:select_a()
  " TODO
  return s:select_i()
endfunction

function! s:select_i()
  let segcol = jasegment#GetCurrentSegment(g:textobj_jasegment_model, getline('.'), col('.'))
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
