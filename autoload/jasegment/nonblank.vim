" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/nonblank.vim:
" 英文のWORDと同様に、空白文字(全角空白含む)で区切る。
" TinySegmenter不使用。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-12

if !exists('g:jasegment#nonblank#splitpat')
  let g:jasegment#nonblank#splitpat = ''
endif

function! jasegment#nonblank#segment(input)
  " a:inputはautoload/jasegment.vim内で空白文字で区切られた後なのでそのまま返す
  return [a:input]
endfunction
