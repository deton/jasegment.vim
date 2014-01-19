" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/kutoten.vim:
" 句読点までで区切る。
" (https://github.com/deton/jasentence.vimは、
" 各text object内に空白を含む場合があるが、
" このスクリプトは、空白で区切った後の文字列に対して区切りを行うので、
" 各text object内には空白は含まない)
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-19

if !exists('g:jasegment#kutoten#splitpat0')
  let g:jasegment#kutoten#splitpat0 = '[、。]\+\zs'
endif

if !exists('g:jasegment#kutoten#splitpat')
  " kutoten.vimで区切った後、jasegment.vim内でg:jasegment#splitpatで、
  " さらに区切られないようにするため空にしておく
  let g:jasegment#kutoten#splitpat = ''
endif

function! jasegment#kutoten#segment(input)
  return split(a:input, g:jasegment#kutoten#splitpat0)
endfunction
