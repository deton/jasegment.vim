" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/mbboundary.vim:
" マルチバイト文字とASCII文字の境界で区切る。
" (https://github.com/deton/mbboundary.vimは、
" 各text object内に空白を含む場合があるが、
" このスクリプトは、空白で区切った後の文字列に対して区切りを行うので、
" 各text object内には空白は含まない)
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-19

if !exists('g:jasegment#mbboundary#splitpat0')
  " ASCII文字との境界で分割
  let g:jasegment#mbboundary#splitpat0 = '[\x01-\x7f]\zs[^\x01-\x7f]\@=\|[^\x01-\x7f]\zs[\x01-\x7f]\@='
endif

if !exists('g:jasegment#mbboundary#splitpat')
  " mbboundary.vimで区切った後、jasegment.vim内でg:jasegment#splitpatで、
  " さらに区切られないようにするため空にしておく
  let g:jasegment#mbboundary#splitpat = ''
endif

function! jasegment#mbboundary#segment(input)
  return split(a:input, g:jasegment#mbboundary#splitpat0)
endfunction
